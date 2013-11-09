class RewardsController < ApplicationController
  load_and_authorize_resource
  inherit_resources
  belongs_to :project
  respond_to :html, :json

  def index
    render layout: false
  end

  def new
    render layout: false
  end

  def edit
    render layout: false
  end

  def update
    update! { project_by_slug_path(permalink: parent.permalink) }
  end

  def create
    create! { project_by_slug_path(permalink: parent.permalink) }
  end

  def destroy
    if resource.project.rewards.size == 1
      flash[:error] = t('projects.project_backers.onerequired')
      return redirect_to project_by_slug_path(permalink: resource.project.permalink)
    end
    destroy! { project_by_slug_path(permalink: resource.project.permalink) }
  end

  def sort
    resource.update_attribute :row_order_position, params[:reward][:row_order_position]

    render nothing: true
  end
end
