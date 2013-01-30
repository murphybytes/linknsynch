class ChangeHolidayDate < ActiveRecord::Migration
  def change
    rename_column :holidays, :date, :occurance
  end
end
