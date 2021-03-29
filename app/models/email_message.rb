# frozen_string_literal: true

class EmailMessage < ApplicationRecord
  enum status: %i[queued failed sent]

  validates :to, :to_name, :from, :from_name, :subject, :body, presence: true
end
