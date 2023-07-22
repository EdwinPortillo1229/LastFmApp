class ChangeMonthsToStringInRecords < ActiveRecord::Migration[6.1]
  def change
    change_column :records, :months, :string
  end
end
