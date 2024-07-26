# frozen_string_literal: true

# This class handles the application's mailer functionality.
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
