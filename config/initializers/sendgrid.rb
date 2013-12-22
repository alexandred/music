begin
  if Rails.env.production?
    ActionMailer::Base.smtp_settings = {
    address: 'smtp.mandrillapp.com',
    port: '25',
    enable_starttls_auto: true,
    authentication: :plain,
    user_name: Configuration[:mandrill_username],
    password: Configuration[:mandrill_password],
    authentication: 'login',
    domain: 'tribaltears.com'
    }
    ActionMailer::Base.delivery_method = :smtp
  end
rescue
  nil
end
