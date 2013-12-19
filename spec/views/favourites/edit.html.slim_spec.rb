require 'spec_helper'

describe "favourites/edit" do
  before(:each) do
    @favourite = assign(:favourite, stub_model(Favourite,
      :project_id => 1
    ))
  end

  it "renders the edit favourite form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", favourite_path(@favourite), "post" do
      assert_select "input#favourite_project_id[name=?]", "favourite[project_id]"
    end
  end
end
