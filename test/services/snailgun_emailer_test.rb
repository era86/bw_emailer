# frozen_string_literal: true

require 'test_helper'

class SnailgunEmailerTest < ActiveSupport::TestCase
  setup do
    @email_message = EmailMessage.create!(
      to: 'bob@test.com',
      to_name: 'bob',
      from: 'alice@test.com',
      from_name: 'alice',
      subject: 'my subject',
      body: '<h1>my body</h1>'
    )

    @id = 'snailgun123'
  end

  test 'run' do
    stub_request(:post, 'https://snailgun.com/')
      .to_return(status: 200, body: { id: @id }.to_json, headers: {})
    stub_request(:get, "https://snailgun.com/#{@id}")
      .to_return(status: 200, body: { status: 'sent' }.to_json, headers: {})

    assert @email_message.queued?

    SnailgunEmailer.run(email_message: @email_message)

    assert @email_message.reload.sent?
  end

  test 'run with API POST failure' do
    stub_request(:post, 'https://snailgun.com/')
      .to_return(status: 400, body: { id: @id }.to_json, headers: {})

    assert @email_message.queued?

    assert_raises(SnailgunEmailer::FailedResponseError) do
      SnailgunEmailer.run(email_message: @email_message)
    end
  end

  test 'run with API GET failure' do
    stub_request(:post, 'https://snailgun.com/')
      .to_return(status: 200, body: { id: @id }.to_json, headers: {})
    stub_request(:get, "https://snailgun.com/#{@id}")
      .to_return(status: 400, body: '', headers: {})

    assert @email_message.queued?

    assert_raises(SnailgunEmailer::FailedResponseError) do
      SnailgunEmailer.run(email_message: @email_message)
    end
  end

  test 'run with API GET timeout' do
    stub_request(:post, 'https://snailgun.com/')
      .to_return(status: 200, body: { id: @id }.to_json, headers: {})
    stub_request(:get, "https://snailgun.com/#{@id}")
      .to_return(status: 200, body: { status: 'queued' }.to_json, headers: {})
    stub_request(:get, "https://snailgun.com/#{@id}")
      .to_return(status: 200, body: { status: 'queued' }.to_json, headers: {})
    stub_request(:get, "https://snailgun.com/#{@id}")
      .to_return(status: 200, body: { status: 'queued' }.to_json, headers: {})

    assert @email_message.queued?

    assert_raises(SnailgunEmailer::RetryLimitError) do
      SnailgunEmailer.run(email_message: @email_message)
    end
  end
end
