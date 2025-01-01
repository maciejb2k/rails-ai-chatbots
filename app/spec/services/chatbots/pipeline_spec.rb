# spec/services/chatbots/pipeline_spec.rb
require 'rails_helper'

RSpec.describe Chatbots::Pipeline do
  let(:company) { create(:company) }
  let(:chatbot_creation) { create(:chatbot_creation, company: company) }

  subject { described_class.new(company, chatbot_creation) }

  it 'runs scraping_step and shows output' do
    subject.send(:process_loader_step)
    puts "Current status: #{chatbot_creation.status}"
  end
end
