class ApplicationMailer < ActionMailer::Base
  default from: "noreply@buckofive.herokuapps.com"
  layout 'mailer'
end
