class AddFavouriteToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :favourite_id, :integer
  end
end