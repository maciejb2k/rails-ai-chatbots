# == Schema Information
#
# Table name: chatbot_creations
#
#  id                :uuid             not null, primary key
#  context           :jsonb            not null
#  is_manual         :boolean          default(FALSE)
#  process_errors    :jsonb            not null
#  scraped_content   :text
#  status            :integer          default("pending"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  chatflow_id       :string
#  company_id        :uuid             not null
#  document_store_id :string
#
# Indexes
#
#  index_chatbot_creations_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
class ChatbotCreation < ApplicationRecord
  belongs_to :company

  has_one_attached :screenshot

  enum status: {
    pending: 0,
    scraping: 1,
    creating_document_store: 2,
    loading_data: 3,
    creating_chatflow: 4,
    preparing_view: 5,
    ready: 6,
    failed: 7,
    processing_loaders: 8
  }

  scope :in_progress, -> { where(status: [ :pending, :scraping, :creating_document_store, :loading_data, :creating_chatflow, :preparing_view, :processing_loaders ]) }
  scope :completed, -> { where(status: [ :ready ]) }
  scope :failed, -> { where(status: [ :failed ]) }

  after_update_commit -> { broadcast_replace_to :chatbot_creations, target: "chatbot_creation_#{self.id}", partial: "chatbots/progress" }

  def in_progress?
    %w[pending scraping creating_document_store loading_data creating_chatflow].include?(status)
  end

  def ready?
    status == "ready"
  end

  def failed?
    status == "failed"
  end
end
