require "test_helper"

class RecordsControllerTest < ActionDispatch::IntegrationTest
  def test_create
  post "/records", params: {"record"=>{"username"=>"edwinportilloo", "months"=>"1", "data_type"=>"artists"}}
  end
end
