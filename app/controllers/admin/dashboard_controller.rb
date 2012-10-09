class Admin::DashboardController < ApplicationController

  before_filter :require_admin
  newrelic_ignore

  helper_method :heartbeat, :nps_summary, :nps_chart_url, :petition_extremes,
    :timeframe, :extremes_count, :extremes_threshold, :nps_thresholds, :map_to_threshold

  def index
    timeframe.verify.tap {|error| flash.now[:error] = error unless not error }
    extremes_count.verify.tap {|error| flash.now[:error] = error unless not error }
    extremes_threshold.verify.tap {|error| flash.now[:error] = error unless not error }
  end

  def heartbeat
    @heartbeat ||= Admin::Heartbeat.new
    {
      last_email: @heartbeat.last_sent_email,
      last_signature: @heartbeat.last_signature,
      emails_in_queue: @heartbeat.emails_in_queue,
      emails_sent_past_week: @heartbeat.emails_sent_since(1.week.ago),
      emailable_member_count: @heartbeat.emailable_members
    }
  end

  def nps_summary
    @nps_summary ||=
    {
      nps24h: Metrics::Nps.new.aggregate(1.day.ago)[:nps],
      nps7d: Metrics::Nps.new.aggregate(1.week.ago)[:nps]
    }
  end

  def nps_chart_url
    from = "1#{timeframe.value}"
u = <<-url
http://graphite.watchdog.net/render?\
target=alias(movingAverage(stats.gauges.victorykit.nps,1440),"moving average (daily)")&\
target=alias(movingAverage(stats.gauges.victorykit.nps,60), "moving average (hourly)")&\
target=lineWidth(threshold(#{nps_thresholds["hot"]}, "hot"), 2)&\
target=lineWidth(threshold(#{nps_thresholds["warm"]}, "warm"), 1)&\
from=-#{from}&\
fontName=Helvetica&fontSize=12&title=New%20members%20per%20email%20sent&\
bgcolor=white&fgcolor=black&colorList=darkgray,red,green,orange&\
lineWidth=3&\
height=300&width=800&\
format=svg
url
u.strip
  end

  def nps_thresholds
    {
      "warm" => 0.035,
      "hot" => 0.05
    }
  end

  def timeframe
    @timeframe ||= Options.new(["month", "week", "day", "hour"], "week", params, :t)
  end

  def extremes_count
    @extremes_count ||= Options.new(["20", "10", "3"], "3", params, :x)
  end

  def extremes_threshold
    @extremes_threshold ||= Options.new(["1000", "100", "10"], "1000", params, :th)
  end

  def petition_extremes
    @extremes ||= fetch_petition_extremes(timeframe.value, extremes_count.value.to_i, extremes_threshold.value.to_i)
  end

  def fetch_petition_extremes timeframe, count, threshold
    timespan = 1.send(timeframe).ago..Time.now
    threshold = extremes_threshold.value.to_i
    nps = Metrics::Nps.new.timespan(timespan, threshold).sort_by { |n| n[:nps] }.reverse
    best = nps.first(count)
    worst = nps.last(count) - best
    {
      best: associate_petitions(best),
      worst: associate_petitions(worst)
    }
  end

  def associate_petitions stats
    ids = stats.map{ |n| n[:petition_id] }
    petitions = Petition.select("id, title").where("id in (?)", ids)
    stats.map {|s| [petitions.find {|p| p.id == s[:petition_id]}, s]}
  end

  def map_to_threshold value, thresholds
    thresholds.inject(thresholds[nil]){|result, pair| (pair[0] and value >= pair[0]) ? pair[1] : result  }
  end

  class Options

    def initialize options, default, params, param_key
      @options = options
      @default = default
      @params = params
      @param_key = param_key
    end

    def options
      @options
    end

    def verify
      error = "Option not recognized: #{value}" if not valid?
      scrub
      return error
    end

    def key
      @param_key
    end

    def value
      @params[key]
    end

    private

    def valid?
      value.nil? or options.include? value
    end

    def scrub
      @params[key] = @default if (not valid? or value.nil?)
    end

  end
end