class AddGovidToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :govid, :string
    add_column :projects, :paypal, :string
  end
end
