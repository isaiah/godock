class Function < ActiveRecord::Base
  include PgSearch
  
  belongs_to :functional, polymorphic: true
  belongs_to :struct

  has_many :examples
  has_many :comments
  has_and_belongs_to_many :source_references, 
    :class_name => "Function", 
    :join_table => "function_references", 
    :foreign_key => "from_function_id",
    :association_foreign_key => "to_function_id"
    
  has_and_belongs_to_many :used_in, 
    :class_name => "Function", 
    :join_table => "function_references", 
    :foreign_key => "to_function_id",
    :association_foreign_key => "from_function_id"
    
  has_and_belongs_to_many :categories
    
  has_many :see_alsos, :foreign_key => "from_id"
  
  acts_as_commentable
  
  pg_search_scope :search, :against => {:name => 'A', :doc => 'B', :version => 'C'}, :using => {
                      :tsearch => {:prefix => true}
                    }

  pg_search_scope :quick_search, :against => [:name], :using => {
                      :tsearch => {:prefix => true}
                    }
  
  #:nocov:
#   define_index do
#     # fields
#     #indexes "REPLACE(name, '-', '')", :as => :name
#     set_property :enable_star => true
#     set_property :min_prefix_len => 1
#     indexes name
#     indexes doc
#     indexes '(select libraries.name from libraries where libraries.id = (select library_id from namespaces where namespaces.id = functions.namespace_id))', :as => :library
#     indexes '(select namespaces.name from namespaces where namespaces.id = namespace_id)'
# #    indexes namespace
# #    indexes functions(:namespace, :name), :as => :ns
#     indexes version
#     
#   end
  #:nocov:
  
  def arglists
    self.arglists_comp.split '|'
  end
  
  def update_weight
    self.weight = examples.count
  end
  
  def href
    "/#{library.url_friendly_name}/#{namespace.name}/#{url_friendly_name}"
  end
  
  def library
    functional.library
  end
  
  def see_alsos_sorted
    see_alsos.sort{|a,b| b.vote_score <=> a.vote_score}
  end
  
  def self.libraries
    Function.select('distinct(library),library').map(&:library).sort
  end
  
  def self.versions_of(function)
    Function.includes(:functional, {:functional => :library}).where(
      :namespaces => {:name => function.namespace.name},
      :libraries => {:name => function.library.name}, :name => function.name)
  end

  def link_opts(use_current_vs_actual_version = true)
    {:controller => 'main',
     :action     => 'function',
     :lib        => library.url_friendly_name,
     :version    => (use_current_vs_actual_version && library.current ? nil : version),
     :ns         => functional.name,
     :function   => url_friendly_name}
  end
  
  def all_versions_examples
    Function.versions_of(self).reduce([]) do |coll, f|
      coll + f.examples
    end
  end
  
  def all_versions_see_alsos
    Function.versions_of(self).reduce([]) do |coll, f|
      coll + f.see_alsos
    end.sort{|a,b| b.vote_score <=> a.vote_score}
  end
  
  def stable_version
    stable_lib = Library.find_by_name_and_current(library, true)
    if not stable_lib
      return nil
    end
    
    Function.where(:library => library, :ns => ns, :name => name, :version => stable_lib.version).first
  end
end
