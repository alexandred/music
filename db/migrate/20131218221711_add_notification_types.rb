class AddNotificationTypes < ActiveRecord::Migration
  def up
    execute "
    INSERT INTO notification_types (name, created_at, updated_at) VALUES ('project_about_to_expire', now(), now())
    "
  end

  def down
    execute "
    DELETE FROM notification_types WHERE name = 'project_about_to_expire';
    "
  end
end