require "spec_helper"

describe FavouritesController do
  describe "routing" do

    it "routes to #index" do
      get("/favourites").should route_to("favourites#index")
    end

    it "routes to #new" do
      get("/favourites/new").should route_to("favourites#new")
    end

    it "routes to #show" do
      get("/favourites/1").should route_to("favourites#show", :id => "1")
    end

    it "routes to #edit" do
      get("/favourites/1/edit").should route_to("favourites#edit", :id => "1")
    end

    it "routes to #create" do
      post("/favourites").should route_to("favourites#create")
    end

    it "routes to #update" do
      put("/favourites/1").should route_to("favourites#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/favourites/1").should route_to("favourites#destroy", :id => "1")
    end

  end
end
