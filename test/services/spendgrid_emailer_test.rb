# frozen_string_literal: true

require 'test_helper'

class SpendgridEmailerTest < ActiveSupport::TestCase
  setup do
    @email_message = EmailMessage.create!(
      to: 'bob@test.com',
      to_name: 'bob',
      from: 'alice@test.com',
      from_name: 'alice',
      subject: 'my subject',
      body: '<h1>my body</h1>'
    )
  end

  test 'run' do
    stub_request(:post, 'https://spendgrid.com/')
      .to_return(status: 200, body: '', headers: {})

    assert @email_message.queued?

    SpendgridEmailer.run(email_message: @email_message)

    assert @email_message.reload.sent?
  end

  test 'run with API failure' do
    stub_request(:post, 'https://spendgrid.com/')
      .to_return(status: 400, body: '', headers: {})

    assert @email_message.queued?

    assert_raises(SpendgridEmailer::FailedResponseError) do
      SpendgridEmailer.run(email_message: @email_message)
    end
  end
end
