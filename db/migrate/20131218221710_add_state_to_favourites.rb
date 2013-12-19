class AddStateToFavourites < ActiveRecord::Migration
  def change
    add_column :favourites, :state, :text
    add_column :notifications, :favourite_id, :integer
  end
end
