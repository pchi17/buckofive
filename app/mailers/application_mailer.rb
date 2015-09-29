class ApplicationMailer < ActionMailer::Base
  default from: "noreply@buckofive.herokuapps.com"
  private
    def mandrill_client
      @mandrill_client ||= Mandrill::API.new ENV['MANDRILL_PASSWORD']
    end
end
