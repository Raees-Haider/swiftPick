require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard" do
    get customers_dashboard_url
    assert_response :success
  end
end
