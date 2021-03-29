# frozen_string_literal: true

# ActiveJob for sending an email through an email service
class EmailJob < ApplicationJob
  SERVICE_MAPPING = {
    'spendgrid' => SpendgridEmailer,
    'snailgun' => SnailgunEmailer
  }.freeze

  EMAIL_SERVICE = ENV['EMAIL_SERVICE']

  queue_as :default

  def perform(email_message_id:)
    emailer_klass = SERVICE_MAPPING.fetch(EMAIL_SERVICE, SpendgridEmailer)

    email_message = EmailMessage.find(email_message_id)
    emailer_klass.run(email_message: email_message)
  rescue StandardError => e
    email_message&.failed!
    Rails.logger.error(e.message)
    raise
  end
end
