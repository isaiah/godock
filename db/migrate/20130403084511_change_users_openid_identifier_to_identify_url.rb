class ChangeUsersOpenidIdentifierToIdentifyUrl < ActiveRecord::Migration
  def change
    rename_column :users, :openid_identifier, :identity_url
    add_index :users, :identity_url, unique: true
  end

end
