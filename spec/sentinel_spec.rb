require 'spec_helper'

RSpec.describe RedDress::Sentinel do
  before(:each) do
    @sentinel = RedDress::Sentinel.new
    RedDress.passphrase = 'Kans4s-i$-g01ng-by3-bye'
  end

  describe "#get_routes" do
    context "When getting routes" do
      it "should unzip, process, and return four routes" do
        expect(@sentinel).to_not be_nil
        @sentinel.get_routes
        expect(@sentinel.processed_routes).to_not be_nil
        expect(@sentinel.processed_routes.count).to be == 4
      end
    end
  end

  describe "#upload_route" do
    context "When uploading route" do
      it "should upload and return a success message" do
        expect(@sentinel).to_not be_nil
        route = @sentinel.get_routes.first
        response = @sentinel.upload_route(route)
        expect(response.code.to_i).to be == 201
        expect(response.body).to include('Targeting')
      end
    end
  end
end
