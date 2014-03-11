class FavouritesController < ApplicationController
	load_and_authorize_resource :user
	load_and_authorize_resource :favourites

	inherit_resources
	belongs_to :user
	def index
		redirect_to root_path if parent != current_user unless current_user.admin?
		@title = t('favourites.title')
		user_favourites = Project.joins(:favourites).where(favourites: {user_id: parent.id})
		@favourites_active = user_favourites.where(state: 'online')
		@favourites_expired = user_favourites.where('projects.state != ?','online')
		@user = parent
	end

	def create
		respond_to do |format|
			format.js {
				@favourite = current_user.favourites.new(user_id: params[:user_id], project_id: params[:project_id], state: :pending)
				@favourite.save!
			}
		end
	end

	def destroy
		respond_to do |format|
			format.js { 
				@favourite = Favourite.find(params[:id])
				@favourite.destroy
				render 'create'
			}
			format.html {
				@favourite = Favourite.find(params[:id])
				user = @favourite.user
				@favourite.destroy
				redirect_to user_favourites_path(user)
			}
		end
	end
end
