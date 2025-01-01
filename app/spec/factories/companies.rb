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
FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    url { Faker::Internet.domain_name }
  end
end
