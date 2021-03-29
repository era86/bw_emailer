# frozen_string_literal: true

# Service class for sending emails via spendgrid
class SpendgridEmailer < BaseEmailer
  API_KEY = ENV['SPENDGRID_API_KEY']
  API_URL = ENV['SPENDGRID_API_URL']

  def run
    uri = URI(API_URL)

    # Build request
    request = Net::HTTP::Post.new(uri)
    request_headers.each { |k, v| request[k] = v }
    request.body = JSON.generate(request_body)

    # Send request
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Handle response
    raise FailedResponseError, response.body unless response.is_a?(Net::HTTPSuccess)

    @email_message.sent!
  end

  private

  def request_headers
    {
      'Content-Type' => 'application/json',
      'X-Api-Key' => API_KEY
    }
  end

  def request_body
    {
      sender: "#{@email_message.from_name} <#{@email_message.from}>",
      recipient: "#{@email_message.to_name} <#{@email_message.to}>",
      subject: @email_message.subject,
      body: @email_message.body
    }
  end
end
