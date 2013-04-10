class AddVersioningToExamples < ActiveRecord::Migration
  def up
    remove_column :examples, :doc
    Example.create_versioned_table
  end

  def down
    add_column :examples, :doc, :string
    Example.drop_versioned_table
  end
end
