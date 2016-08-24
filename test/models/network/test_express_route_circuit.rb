require File.expand_path '../../test_helper', __dir__

# Test class for ExpressRouteCircuit Model
class TestExpressRouteCircuit < Minitest::Test
  def setup
    @service = Fog::Network::AzureRM.new(credentials)
    @circuit = express_route_circuit(@service)
  end

  def test_model_methods
    response = ApiStub::Models::Network::ExpressRouteCircuit.create_express_route_circuit_response
    methods = [
      :save,
      :destroy
    ]
    @service.stub :create_or_update_express_route_circuit, response do
      methods.each do |method|
        assert @circuit.respond_to? method
      end
    end
  end

  def test_model_attributes
    response = ApiStub::Models::Network::ExpressRouteCircuit.create_express_route_circuit_response
    attributes = [
      :resource_group,
      :name,
      :location,
      :tag_key1,
      :tag_key2,
      :sku_name,
      :sku_tier,
      :sku_family,
      :service_provider_name,
      :peering_location,
      :bandwidth_in_mbps,
      :peerings
    ]
    @service.stub :create_or_update_express_route_circuit, response do
      attributes.each do |attribute|
        assert @circuit.respond_to? attribute
      end
    end
  end

  def test_save_method_response
    response = ApiStub::Models::Network::ExpressRouteCircuit.create_express_route_circuit_response
    @service.stub :create_or_update_express_route_circuit, response do
      assert_instance_of Fog::Network::AzureRM::ExpressRouteCircuit, @circuit.save
    end
  end

  def test_destroy_method_response
    @service.stub :delete_express_route_circuit, true do
      assert @circuit.destroy
    end
  end
end
