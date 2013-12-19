require 'spec_helper'

describe "favourites/show" do
  before(:each) do
    @favourite = assign(:favourite, stub_model(Favourite,
      :project_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
