class AddStartDateToRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :records, :start_date, :date
  end
end
