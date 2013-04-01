class AddFunctionalTypeToFunctions < ActiveRecord::Migration
  def change
    add_column :functions, :functional_type, :string
  end
end
