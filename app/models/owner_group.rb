class OwnerGroup < ActiveRecord::Base
  has_many :owner_objects
  has_and_belongs_to_many :users
  has_many :approvals
end
