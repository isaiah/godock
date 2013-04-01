class CreateTypes < ActiveRecord::Migration
  def change

    create_table :types do |t|
      t.string :name
      t.integer :namespace_id
      t.text :doc
      t.string :source_url
      t.string :arglists_comp
      t.string :version
      t.string :type

      t.timestamps
    end
  end
end
