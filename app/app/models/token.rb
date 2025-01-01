# == Schema Information
#
# Table name: tokens
#
#  id         :uuid             not null, primary key
#  active     :boolean          default(TRUE), not null
#  key        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tokens_on_key  (key) UNIQUE
#
class Token < ApplicationRecord
  validates :key, presence: true, uniqueness: true
end
