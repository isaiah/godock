class Namespace < ActiveRecord::Base
  belongs_to :library
  has_many :functions, :dependent => :delete_all, as: :functional
  has_many :struct_types, dependent: :delete_all
  has_many :interface_types, dependent: :delete_all
  
  #:nocov:
  #define_index do
  #   # fields
  #   indexes name
  #   indexes libraries.name, :as => :library
  #   
  #   has library_id
  # end
  #:nocov:
  
  def self.versions_of(ns)
    Namespace.find(:all, :include => :library, :conditions => {:name => ns.name, :libraries => {:name => ns.library.name}})
  end
  
  def link_opts(use_current_vs_actual_version = true)
    {:controller => 'main',
     :action     => 'ns',
     :lib        => library.url_friendly_name,
     :version    => (use_current_vs_actual_version && library.current ? nil : library.version),
     :ns         => name}
  end

  def ns_name
    name
  end

  # To be compatible with TypeClass
  def namespace
    self
  end
end
