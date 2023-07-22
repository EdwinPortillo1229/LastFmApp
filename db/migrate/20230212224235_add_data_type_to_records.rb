class AddDataTypeToRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :records, :data_type, :string
  end
end
