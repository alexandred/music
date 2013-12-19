require 'spec_helper'

describe "favourites/index" do
  before(:each) do
    assign(:favourites, [
      stub_model(Favourite,
        :project_id => 1
      ),
      stub_model(Favourite,
        :project_id => 1
      )
    ])
  end

  it "renders a list of favourites" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
