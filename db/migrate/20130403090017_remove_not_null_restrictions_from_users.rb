class RemoveNotNullRestrictionsFromUsers < ActiveRecord::Migration
  def change
    change_column :users, :email, :string, null: true
    change_column :users, :persistence_token, :string, null: true
  end
end
