class AddMonthsToRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :records, :months, :integer
  end
end
