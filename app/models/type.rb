class Type < ActiveRecord::Base
  attr_accessible :arglists_comp, :doc, :name, :namespace_id, :version
  has_many :functions
end
