class TypeClass < ActiveRecord::Base
  include PgSearch

  has_many :functions, :dependent => :delete_all, as: :functional
  has_many :examples, as: :examplable
  has_many :comments

  belongs_to :namespace
  acts_as_commentable

  pg_search_scope :quick_search, against: [:name], using: { tsearch: {prefix: true} }
 

  def self.versions_of(type_class)
    self.includes(:namespace, {:namespace => :library}).where(
      :namespaces => {:name => type_class.namespace.name},
      :libraries => {:name => type_class.library.name}, :name => type_class.name)
  end

  def library
    namespace.library
  end

  def link_opts(use_current_vs_actual_version = true)
    {:controller => 'main',
     :action     => 'type_class',
     :lib        => library.url_friendly_name,
     :version    => (use_current_vs_actual_version && library.current ? nil : version),
     :ns         => namespace.name,
     :type_class   => name}
  end
 
  def source
  end

  def arglists
    # FIXME legacy
    arglists_comp.split("|")
  end

  def all_versions_examples
    []
  end

  def all_versions_see_alsos
    []
  end

  def ns_name
    namespace.name
  end

  def href
    "/#{library.name}/#{namespace.name}/#{name}"
  end
end
