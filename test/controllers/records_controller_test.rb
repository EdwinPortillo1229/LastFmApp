require "test_helper"

class RecordsControllerTest < ActionDispatch::IntegrationTest
  def test_create
  post "/records", params: {"record"=>{"username"=>"edwinportilloo", "months"=>"1month", "data_type"=>"artists"}}
  end
end
