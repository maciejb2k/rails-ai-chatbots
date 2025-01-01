# == Schema Information
#
# Table name: companies
#
#  id         :uuid             not null, primary key
#  name       :string
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_companies_on_url  (url) UNIQUE
#
class Company < ApplicationRecord
  has_many :chatbot_creations, dependent: :destroy

  validates :url, presence: true, uniqueness: true

  attr_accessor :is_manual

  def latest_chatbot
    chatbot_creations.completed.order(created_at: :desc).first
  end

  def active_creation
    chatbot_creations.in_progress.order(created_at: :desc).first
  end

  def failed_creation
    chatbot_creations.failed.order(created_at: :desc).first
  end

  def can_start_new_creation?
    chatbot_creations.in_progress.none?
  end

  def full_name
    url
  end
end
