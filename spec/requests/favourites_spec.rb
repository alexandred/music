require 'spec_helper'

describe "Favourites" do
  describe "GET /favourites" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get favourites_path
      response.status.should be(200)
    end
  end
end
