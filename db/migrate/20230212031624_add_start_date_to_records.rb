class AddStartDateToRecords < ActiveRecord::Migration[7.0]
  def change
    add_column :records, :start_date, :date
  end
end
