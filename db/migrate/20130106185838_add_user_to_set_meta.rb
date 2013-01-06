class AddUserToSetMeta < ActiveRecord::Migration
  def change
    add_column :set_meta, :user_id, :integer
  end
end
