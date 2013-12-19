require 'spec_helper'

describe "favourites/new" do
  before(:each) do
    assign(:favourite, stub_model(Favourite,
      :project_id => 1
    ).as_new_record)
  end

  it "renders new favourite form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", favourites_path, "post" do
      assert_select "input#favourite_project_id[name=?]", "favourite[project_id]"
    end
  end
end
