# frozen_string_literal: true

# Service class for sending emails via snailgun
class SnailgunEmailer < BaseEmailer
  class RetryLimitError < StandardError; end

  TIMEOUT = Integer(ENV['SNAILGUN_CHECK_TIMEOUT'], exception: false) || 3
  LIMIT = Integer(ENV['SNAILGUN_CHECK_LIMIT'], exception: false) || 3
  API_KEY = ENV['SNAILGUN_API_KEY']
  API_URL = ENV['SNAILGUN_API_URL']

  def run
    response = send_post_request
    id = JSON.parse(response.body)['id']

    retries = 0
    loop do
      response = send_get_request(id: id)
      status = JSON.parse(response.body)['status']

      case status
      when 'sent'
        break
      when 'failed'
        raise FailedResponseError, response.body
      else
        raise RetryLimitError, 'retry limit exceeded' if retries == LIMIT

        sleep TIMEOUT
        retries += 1
      end
    end

    @email_message.sent!
  end

  def send_post_request
    uri = URI(API_URL)

    # Build request
    request = Net::HTTP::Post.new(uri)
    request_headers.each { |k, v| request[k] = v }
    request.body = JSON.generate(post_request_body)

    # Send request
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Handle response
    raise FailedResponseError, response.body unless response.is_a?(Net::HTTPSuccess)

    response
  end

  def send_get_request(id:)
    uri = URI(File.join(API_URL, id))
    # Build request
    request = Net::HTTP::Get.new(uri)
    request_headers.each { |k, v| request[k] = v }

    # Send request
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Handle response
    raise FailedResponseError, response.body unless response.is_a?(Net::HTTPSuccess)

    response
  end

  private

  def request_headers
    {
      'Content-Type' => 'application/json',
      'X-Api-Key' => API_KEY
    }
  end

  def post_request_body
    {
      from_email: @email_message.from,
      from_name: @email_message.from_name,
      to_email: @email_message.to,
      to_name: @email_message.to_name,
      subject: @email_message.subject,
      body: @email_message.body
    }
  end
end
