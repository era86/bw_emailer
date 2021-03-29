# frozen_string_literal: true

require 'test_helper'

class EmailMessageTest < ActiveSupport::TestCase
  test 'valid?' do
    email_message = EmailMessage.new(
      to: 'bob@test.com',
      to_name: 'bob',
      from: 'alice@test.com',
      from_name: 'alice',
      subject: 'my subject',
      body: '<h1>my body</h1>'
    )

    assert email_message.valid?
  end

  test 'valid? with missing attribute' do
    email_message = EmailMessage.new(
      to_name: 'bob',
      from: 'alice@test.com',
      from_name: 'alice',
      subject: 'my subject',
      body: '<h1>my body</h1>'
    )

    assert_not email_message.valid?
  end
end
