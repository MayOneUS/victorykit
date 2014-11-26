class UnsubscribesObserver < ActiveRecord::Observer
  observe Unsubscribe
  require 'nationbuilder'

  def after_create(record)
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
