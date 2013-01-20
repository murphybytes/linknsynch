class ChangeHomeProfileFieldName < ActiveRecord::Migration
  def change
    rename_column :home_profiles, :btu_required, :btu_factor
  end
end
