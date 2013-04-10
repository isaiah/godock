class Example < ActiveRecord::Base
  acts_as_versioned

  Example.versioned_class.class_eval do
    belongs_to :user
    belongs_to :examplable, polymorphic: true
  end

  belongs_to :examplable, polymorphic: true
  belongs_to :user
  
  def belongs_to?(user)
    return user_id == user.id
  end
end
