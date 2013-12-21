# coding: utf-8
class ProjectsController < ApplicationController
  load_and_authorize_resource only: [ :new, :create, :update, :destroy ]
  inherit_resources

  has_scope :pg_search, :by_category_id, :recent, :expiring, :successful, :recommended, :not_expired, :near_of
  respond_to :html
  respond_to :json, only: [:index, :show, :update]

  def index
    index! do |format|
      format.html do
        if request.xhr?
          @projects = apply_scopes(Project).visible.order_for_search.includes(:project_total, :user, :category).page(params[:page]).per(6)
          return render partial: 'project', collection: @projects, layout: false
        else
          @title = t("site.title")
          if current_user && current_user.recommended_projects.present?
            @recommends = current_user.recommended_projects.limit(8).shuffle
          else
            @recommends = ProjectsForHome.recommends.shuffle
          end

          @channel_projects = Project.from_channels.order_for_search.limit(3)
          @projects_near = Project.online.near_of(current_user.address_state).order("random()").limit(3) if current_user
          @expiring = ProjectsForHome.expiring
          @recent   = ProjectsForHome.recents
          @recently_viewed = get_viewed_projects
          @banner = [
            Project.find(::Configuration[:banner1_id].to_i),
            Project.find(::Configuration[:banner2_id].to_i),
            Project.find(::Configuration[:banner3_id].to_i),
            Project.find(::Configuration[:banner4_id].to_i)
          ]
        end
      end
    end
  end

  def new
    new! do
      @title = t('projects.new.title')
      @project.rewards.build
    end
  end

  def create
    @project = current_user.projects.new(params[:project])

    create!(notice: t('projects.create.success')) do |success, failure|
      success.html{ return redirect_to project_by_slug_path(@project.permalink) }
    end
    check_for_stripe_keys
  end

  def update
    update! do |success, failure|
      success.html{ return redirect_to project_by_slug_path(@project.permalink, anchor: 'edit') }
      failure.html{ return redirect_to project_by_slug_path(@project.permalink, anchor: 'edit') }
    end
  end

  def show
    @title = resource.name
    fb_admins_add(resource.user.facebook_id) if resource.user.facebook_id
    @updates_count = resource.updates.count
    @update = resource.updates.where(id: params[:update_id]).first if params[:update_id].present?
    check_for_stripe_keys
    @recently_viewed = get_viewed_projects
    store_viewed_projects(@project)
  end

  def video
    project = Project.new(video_url: params[:url])
    render json: project.video.to_json
  end

  %w(embed video_embed).each do |method_name|
    define_method method_name do
      @title = resource.name
      render layout: 'embed'
    end
  end

  def embed_panel
    @title = resource.name
    render layout: false
  end

  def refresh_stripe
    respond_to do |format|
      format.js
    end
  end

  protected

  def resource
    @project ||= (params[:permalink].present? ? Project.by_permalink(params[:permalink]).first! : Project.find(params[:id]))
  end
def check_for_stripe_keys
  if @project.stripe_userid.nil?
    [:stripe_access_token, :stripe_key, :stripe_userid].each do |field|
      @project.send("#{field.to_s}=", @project.user.send(field).dup)
    end
  elsif @project.stripe_userid != @project.user.stripe_userid
    [:stripe_access_token, :stripe_key, :stripe_userid].each do |field|
      @project.send("#{field.to_s}=", @project.user.send(field).dup)
    end
  end
  @project.save
end  
end
