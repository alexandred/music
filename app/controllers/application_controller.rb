# coding: utf-8
require 'uservoice_sso'
class ApplicationController < ActionController::Base
  layout :use_catarse_boostrap
  protect_from_forgery

  before_filter :redirect_user_back_after_login, unless: :devise_controller?
  before_filter :checkcountdown
  before_filter :check_for_mobile

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  rescue_from CanCan::Unauthorized do |exception|
    session[:return_to] = request.env['REQUEST_URI']
    message = exception.message

    if current_user.nil?
      redirect_to new_user_registration_path, alert: I18n.t('devise.failure.unauthenticated')
    elsif request.env["HTTP_REFERER"]
      redirect_to :back, alert: message
    else
      redirect_to root_path, alert: message
    end
  end

  helper_method :namespace, :fb_admins, :render_facebook_sdk, :render_facebook_like, :render_twitter, :display_uservoice_sso, :mobile_device?, :store_viewed_projects, :get_viewed_projects, :render_pinterest_sdk, :render_pinit_button, :render_google_sdk, :render_plus_one
  
  before_filter :set_locale
  before_filter :force_http

  # TODO: Change this way to get the opendata
  before_filter do
    @fb_admins = [100000428222603, 547955110]
  end

  #recently viewed projects
  def store_viewed_projects(project)
    array = ActiveSupport::JSON.decode(cookies[:project_history]) unless !cookies[:project_history]
    array ||= []
    unless array.include? project.permalink
      array.delete_at(0) if array.size >= 5
      array << project.permalink
    end
    cookies[:project_history] = { value: ActiveSupport::JSON.encode(array), expires: 1.year.from_now }
  end

  def get_viewed_projects
    array = []
    cookie = ActiveSupport::JSON.decode(cookies[:project_history]) unless !cookies[:project_history]
    cookie.each { |permalink| 
    array << Project.where(permalink: permalink).first
    } if cookie
    array
  end

  #mobile device methods
  def check_for_mobile
    session[:mobile_override] = params[:mobile] if params[:mobile]
    prepare_for_mobile if mobile_device?
  end

  def prepare_for_mobile
    prepend_view_path Rails.root + 'app' + 'views_mobile'
  end

  def mobile_device?
    if session[:mobile_override]
      session[:mobile_override] == "1"
    else
      (request.user_agent =~ /Mobile|webOS/)
    end
  end


  # We use this method only to make stubing easier
  # and remove FB templates from acceptance tests
  def render_facebook_sdk
    render_to_string(partial: 'layouts/facebook_sdk').html_safe
  end

  def render_pinterest_sdk
    render_to_string(partial: 'layouts/pinterest_sdk').html_safe
  end

  def render_google_sdk
    render_to_string(partial: 'layouts/google_sdk').html_safe
  end

  def render_twitter options={}
    render_to_string(partial: 'layouts/twitter', locals: options).html_safe
  end

  def render_facebook_like options={}
    render_to_string(partial: 'layouts/facebook_like', locals: options).html_safe
  end

  def render_pinit_button options={}
    render_to_string(partial: 'layouts/pinit_button', locals: options).html_safe
  end

  def render_plus_one options={}
    render_to_string(partial: 'layouts/plus_one', locals: options).html_safe
  end

  def display_uservoice_sso
    if current_user && ::Configuration[:uservoice_subdomain] && ::Configuration[:uservoice_sso_key]
      Uservoice::Token.generate({
        guid: current_user.id, email: current_user.email, display_name: current_user.display_name,
        url: user_url(current_user), avatar_url: current_user.display_image
      })
    end
  end

  private
  def fb_admins
    @fb_admins.join(',')
  end

  def fb_admins_add(ids)
    case ids.class
    when Array
      ids.each {|id| @fb_admins << ids.to_i}
    else
      @fb_admins << ids.to_i
    end
  end

  def namespace
    names = self.class.to_s.split('::')
    return "null" if names.length < 2
    names[0..(names.length-2)].map(&:downcase).join('_')
  end

  def set_locale
    I18n.locale = "en"
#    if params[:locale]
#      I18n.locale = params[:locale]
#      current_user.update_attribute :locale, params[:locale] if current_user && params[:locale] != current_user.locale
#    elsif request.method == "GET"
#      new_locale = (current_user.locale if current_user) || I18n.default_locale
#      begin
#        return redirect_to params.merge(locale: new_locale, only_path: true)
#      rescue ActionController::RoutingError
#        logger.info "Could not redirect with params #{params.inspect} in set_locale"
#      end
#    end
  end

  def use_catarse_boostrap
    devise_controller? ? 'catarse_bootstrap' : 'application'
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def after_sign_in_path_for(resource_or_scope)
    return_to = session[:return_to]
    session[:return_to] = nil
    (return_to || root_path)
  end

  def render_404(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/not_found', layout: 'layouts/catarse_bootstrap', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def force_http
    redirect_to(protocol: 'http', host: ::Configuration[:base_domain]) if request.ssl?
  end

  def redirect_user_back_after_login
    if request.env['REQUEST_URI'].present? && !request.xhr?
      session[:return_to] = request.env['REQUEST_URI']
    end
  end

  def checkcountdown
    if Rails.env.production?
      unless (params['controller'] == "catarse_stripe/payment/stripe" and params['action'] == "ipn") || (params['controller'] == "devise/sessions" and params['action'] == "new") || (params['controller'] == "passwords")
        render template: 'static/countdown', layout: 'layouts/catarse_bootstrap' if !current_user
      end
    end
  end

end
