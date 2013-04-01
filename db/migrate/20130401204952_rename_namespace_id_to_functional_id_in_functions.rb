class RenameNamespaceIdToFunctionalIdInFunctions < ActiveRecord::Migration
  def change
    rename_column :functions, :namespace_id, :functional_id
  end
end
