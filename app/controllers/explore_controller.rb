class ExploreController < ApplicationController
  def index
    @title = t('explore.title')
    @categories = Category.with_projects.order(:name_pt).all
    @recently_viewed = get_viewed_projects
  end
end
