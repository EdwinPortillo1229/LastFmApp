class AddMonthsToRecords < ActiveRecord::Migration[7.0]
  def change
    add_column :records, :months, :integer
  end
end
