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
FactoryBot.define do
  factory :chatbot_creation do
    company
    status { :pending }
  end
end
