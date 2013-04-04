class Function < ActiveRecord::Base
  include PgSearch
  
  belongs_to :functional, polymorphic: true
  belongs_to :struct

  has_many :examples, as: :examplable
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

  # is this a function in namespace?
  def ns_func?
    functional.class == Namespace
  end

  # namespace
  def ns
    ns_func? ? functional : functional.namespace
  end

  # typeclass
  def tc
    ns_func? ? "" : functional.name
  end
  
  def href
    if ns_func?
      "/#{library.url_friendly_name}/#{ns.name}/#{name}"
    else
      "/#{library.url_friendly_name}/#{ns.name}/t/#{functional.name}/#{name}"
    end
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
  
  def self.versions_of(func)
    ns_func_sql = "select functions.id , functions.name , functions.doc, functions.arglists_comp, functions.functional_id, functions.functional_type, functions.source, functions.version, functions.url_friendly_name from functions left outer join namespaces on namespaces.id = functions.functional_id left outer join libraries on libraries.id = namespaces.library_id where functions.functional_type = 'Namespace' and libraries.url_friendly_name = ? and namespaces.name = ? and functions.name = ?"
    type_func_sql = "select functions.id , functions.name , functions.doc, functions.arglists_comp, functions.functional_id, functions.functional_type, functions.source, functions.version, functions.url_friendly_name from functions left outer join type_classes on type_classes.id  = functions.functional_id left outer join namespaces on namespaces.id = type_classes.namespace_id left outer join libraries on libraries.id = namespaces.library_id where functions.functional_type = 'TypeClass' and libraries.url_friendly_name = ? and namespaces.name = ? and functions.name = ? and type_classes.name = ?"
    func.ns_func? ? 
      self.find_by_sql([ns_func_sql, func.library.url_friendly_name, func.ns.name, func.name]) : 
      self.find_by_sql([type_func_sql, func.library.url_friendly_name, func.ns.name, func.name, func.functional.name])
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
    Function.versions_of(self).map(&:examples).flatten
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

  def self.for_namespace(name, namespace, lib, version = nil)
    sql = "select functions.id , functions.name , functions.doc, functions.arglists_comp, functions.functional_id, functions.functional_type, functions.source, functions.version from functions left outer join namespaces on namespaces.id  = functions.functional_id left outer join libraries on libraries.id = namespaces.library_id where functions.functional_type = 'Namespace' and libraries.url_friendly_name = ? and namespaces.name = ? and functions.url_friendly_name = ?"
    sql_with_version = sql + " and functions.version = ?"
    sql_without_version = sql + " and libraries.current = 't'"

    functions = if version
                   self.find_by_sql([sql_with_version, lib, namespace, name, version])
                 else
                   self.find_by_sql([sql_without_version, lib, namespace, name])
                 end
    functions.first
  end

  def self.for_type_class(name, type_class, namespace, lib, version = nil)
    sql = "select functions.id , functions.name , functions.doc, functions.arglists_comp, functions.functional_id, functions.functional_type, functions.source, functions.version from functions left outer join type_classes on type_classes.id  = functions.functional_id left outer join namespaces on namespaces.id = type_classes.namespace_id left outer join libraries on libraries.id = namespaces.library_id where functions.functional_type = 'TypeClass' and libraries.url_friendly_name = ? and namespaces.name = ? and functions.url_friendly_name = ? and type_classes.name = ?"
    sql_with_version = sql + " and functions.version = ?"
    sql_without_version = sql + " and libraries.current = 't'"

    functions = if version
                   self.find_by_sql([sql_with_version, lib, namespace, name, type_class, version])
                 else
                   self.find_by_sql([sql_without_version, lib, namespace, name, type_class])
                 end
    functions.first
  end
end
