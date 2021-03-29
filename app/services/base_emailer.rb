# frozen_string_literal: true

require 'net/http'

# Base service class for emailers
class BaseEmailer
  class FailedResponseError < StandardError; end

  def self.run(email_message:)
    new(email_message: email_message).run
  end

  def initialize(email_message:)
    @email_message = email_message
  end

  def run
    raise NotImplementedError
  end
end
