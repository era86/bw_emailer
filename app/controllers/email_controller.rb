# frozen_string_literal: true

# Controller for /email API
class EmailController < ApplicationController
  EMAIL_PARAMS = %i[to to_name from from_name subject body].freeze

  def show
    if (email_message = EmailMessage.find_by(id: params[:id]))
      render json: email_message.slice(:id, :status)
    else
      render json: {
        errors: ["email message with id=#{params[:id]} not found"]
      }, status: :not_found
    end
  end

  def create
    @email_message = EmailMessage.new(email_message_params)

    if @email_message.save
      EmailJob.perform_later(email_message_id: @email_message.id)
      render json: @email_message.slice(:id, :status), status: :created
    else
      render json: {
        errors: @email_message.errors.full_messages
      }, status: :bad_request
    end
  end

  private

  def email_message_params
    params.permit(EMAIL_PARAMS)
  end
end
