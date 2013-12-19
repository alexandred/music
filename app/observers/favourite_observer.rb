class FavouriteObserver < ActiveRecord::Observer
  observe :favourite

  def notify_user_that_project_is_expiring(favourite)
    Notification.create_notification_once(:project_about_to_expire,
      favourite.user,
      {favourite_id: favourite.id},
      project: favourite.project, project_name: favourite.project.name)
  end
end