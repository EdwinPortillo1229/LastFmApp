class ChangeMonthsToStringInRecords < ActiveRecord::Migration[7.0]
  def change
    change_column :records, :months, :string
  end
end
