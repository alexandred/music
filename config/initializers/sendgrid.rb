begin
  if Rails.env.production?
    ActionMailer::Base.smtp_settings = {
    address: 'smtp.gmail.com',
    port: '587',
    authentication: :plain,
    user_name: 'catarsemusic@gmail.com',#Configuration[:sendgrid_user_name],
    password: 'catarsemusic1234',#Configuration[:sendgrid],
    domain: 'gmail.com'
    }
    ActionMailer::Base.delivery_method = :smtp
  end
rescue
  nil
end
