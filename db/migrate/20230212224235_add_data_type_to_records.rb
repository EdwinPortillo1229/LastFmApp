class AddDataTypeToRecords < ActiveRecord::Migration[7.0]
  def change
    add_column :records, :data_type, :string
  end
end
