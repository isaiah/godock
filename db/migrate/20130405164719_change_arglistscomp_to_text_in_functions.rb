class ChangeArglistscompToTextInFunctions < ActiveRecord::Migration
  def change
    change_column :functions, :arglists_comp, :text
  end

end
