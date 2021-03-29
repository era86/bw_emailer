# frozen_string_literal: true

require 'test_helper'

class EmailControllerTest < ActionDispatch::IntegrationTest
  test 'create' do
    params = {
      to: 'bob@test.com',
      to_name: 'bob',
      from: 'alice@test.com',
      from_name: 'alice',
      subject: 'my subject',
      body: '<h1>my body</h1>'
    }

    assert_difference 'EmailMessage.count', +1 do
      assert_enqueued_jobs 1, only: EmailJob do
        post email_index_url, params: params
      end
    end
    assert_response :created

    json = JSON.parse(@response.body)
    assert_equal json['id'], EmailMessage.last.id
  end

  test 'create with a missing param' do
    params = {
      to: 'bob@test.com',
      to_name: 'bob',
      from: 'alice@test.com',
      from_name: 'alice',
      body: '<h1>my body</h1>'
    }

    assert_no_difference 'EmailMessage.count' do
      post email_index_url, params: params
    end
    assert_response :bad_request

    json = JSON.parse(@response.body)
    assert_equal ["Subject can't be blank"], json['errors']
  end

  test 'show' do
    email_message = EmailMessage.create!(
      to: 'bob@test.com',
      to_name: 'bob',
      from: 'alice@test.com',
      from_name: 'alice',
      subject: 'my subject',
      body: '<h1>my body</h1>'
    )

    get email_url(id: email_message.to_param)
    assert_response :success

    json = JSON.parse(@response.body)
    assert_equal json['status'], email_message.status
  end

  test 'show with unknown resource' do
    get email_url(id: 123_123_123)
    assert_response :not_found

    json = JSON.parse(@response.body)
    assert_equal ['email message with id=123123123 not found'], json['errors']
  end
end
