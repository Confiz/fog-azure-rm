require File.expand_path '../../test_helper', __dir__

# Test class for ApplicationGateway Collection
class TestGateways < Minitest::Test
  def setup
    @service = Fog::ApplicationGateway::AzureRM.new(credentials)
    @gateways = Fog::ApplicationGateway::AzureRM::Gateways.new(resource_group: 'fog-test-rg', service: @service)
    @gateway_client = @service.instance_variable_get(:@network_client)
    @response = ApiStub::Models::ApplicationGateway::Gateway.create_application_gateway_response(@gateway_client)
  end

  def test_collection_methods
    methods = [
      :all,
      :get
    ]
    methods.each do |method|
      assert_respond_to @gateways, method
    end
  end

  def test_collection_attributes
    assert_respond_to @gateways, :resource_group
  end

  def test_all_method_response
    response = [@response]
    @service.stub :list_application_gateways, response do
      assert_instance_of Fog::ApplicationGateway::AzureRM::Gateways, @gateways.all
      assert @gateways.all.size >= 1
      @gateways.all.each do |application_gateway|
        assert_instance_of Fog::ApplicationGateway::AzureRM::Gateway, application_gateway
      end
    end
  end

  def test_get_method_response
    @service.stub :get_application_gateway, @response do
      assert_instance_of Fog::ApplicationGateway::AzureRM::Gateway, @gateways.get('fog-test-rg', 'gateway')
    end
  end
end
