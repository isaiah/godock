class AddExamplablePolymorphicMetaToExamples < ActiveRecord::Migration
  def change
    add_column :examples, :examplable_type, :string
    add_column :examples, :name, :string
    add_column :examples, :doc, :text
    add_column :examples, :output, :text
    rename_column :examples, :function_id, :examplable_id
  end
end
