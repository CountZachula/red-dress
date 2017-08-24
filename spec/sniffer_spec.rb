require 'spec_helper'

RSpec.describe RedDress::Sniffer do
  before(:each) do
    @sniffer = RedDress::Sniffer.new
    RedDress.passphrase = 'Kans4s-i$-g01ng-by3-bye'
  end

  describe "#get_routes" do
    context "When getting routes" do
      it "should unzip, process, and return them" do

      end
    end
  end

  describe "#upload_route" do
    context "When uploading route" do
      it "should upload and return a success message" do

      end
    end
  end
end
