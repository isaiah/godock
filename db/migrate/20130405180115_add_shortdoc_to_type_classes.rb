class AddShortdocToTypeClasses < ActiveRecord::Migration
  def change
    add_column :type_classes, :shortdoc, :text
    change_column :functions, :shortdoc, :string
  end
end
