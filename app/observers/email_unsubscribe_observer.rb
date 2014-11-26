class UnsubscribeObserver < ActiveRecord::Observer
observe Unsubscribe
require 'NationBuilder'
  def after_create(record)
    puts "JESUS PLEASE WORK"
    client = NationBuilder::Client.new('mayday', 'nationbuilderprivatekey')
    puts "in nation builder unsubscribe!"
    params = {
      person: {
        email: record.email,
        fundraising_email_subscription: false
      }
    }
  end
end
