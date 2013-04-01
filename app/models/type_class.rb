class TypeClass < ActiveRecord::Base
  attr_accessible :arglists_comp, :doc, :name, :namespace_id, :version
  has_many :functions
  belongs_to :namespace
end
