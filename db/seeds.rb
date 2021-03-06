# coding: utf-8

puts 'Seeding the database...'

[
  { en: 'Country', pt: 'Country'},
  { en: 'Electronic', pt: 'Electronic' },
  { en: 'Hip Hop', pt: 'Hip Hop' },
  { en: 'Jazz', pt: 'Jazz' },
  { en: 'Metal', pt: 'Metal'},
  { en: 'Pop', pt: 'Pop' },
  { en: 'R&B', pt: 'R&B' },
  { en: 'Rock', pt: 'Rock' }
].each do |name|
   category = Category.find_or_initialize_by_name_pt name[:pt]
   category.update_attributes({
     name_en: name[:en]
   })
 end

[
  'confirm_backer','payment_slip','project_success','backer_project_successful',
  'backer_project_unsuccessful','project_received', 'project_received_channel', 'updates','project_unsuccessful',
  'project_visible','processing_payment','new_draft_project', 'new_draft_channel', 'project_rejected',
  'pending_backer_project_unsuccessful', 'project_owner_backer_confirmed', 'adm_project_deadline',
  'project_in_wainting_funds', 'credits_warning', 'backer_confirmed_after_project_was_closed',
  'backer_canceled_after_confirmed', 'new_user_registration'
].each do |name|
  NotificationType.find_or_create_by_name name
end

{
  company_name: 'Jampoff',
  host: 'jampoff.com',
  base_url: "http://jampoff.com",
  email_contact: 'contato@catarse.me',
  email_payments: 'financeiro@catarse.me',
  email_projects: 'projetos@catarse.me',
  email_system: 'system@catarse.me',
  email_no_reply: 'no-reply@catarse.me',
  facebook_url: "http://facebook.com/jampoff",
  facebook_app_id: '173747042661491',
  twitter_url: 'http://twitter.com/jampoff',
  twitter_username: "jampoff",
  mailchimp_url: "http://jampoff.us3.list-manage.com/subscribe/post?u=ad4a781fb73a01a6c5fa67ba2&amp;id=19aff2ea61",
  catarse_fee: '0.13',
  support_forum: 'http://suporte.catarse.me/',
  base_domain: 'jampoff.com',
  uservoice_secret_gadget: 'change_this',
  uservoice_key: 'uservoice_key',
  faq_url: 'http://suporte.catarse.me/',
  how_url: 'http://jampoff.com/jampoff4.pdf',
  feedback_url: 'http://jampoff.com/jampoff2.pdf',
  support_url: 'http://suporte.catarse.me/',
  terms_url: 'http://jampoff.com/jampoff3.pdf',
  privacy_url: 'http://www.jampoff.com/jampoff1.pdf',
  instagram_url: 'http://instagram.com/jampoff',
  soundcloud_url: 'http://www.soundcloud/jampoff',
  google_url: 'https://plus.google.com/b/109965324337247827518/109965324337247827518/about?hl=en',
  pinterest_url: 'http://www.pinterest.com/jampoff/',
  tumblr_url: 'http://jampoff.tumblr.com/',
  myspace_url: 'https://myspace.com/jampoff',
  youtube_url: 'http://www.youtube.com/user/Jampoff',
  blog_url: "http://blog.catarse.me",
  github_url: 'http://github.com/catarse',
  contato_url: 'http://suporte.catarse.me/',
  stripe_api_key: 'pk_live_Jdh0rFPA4gsMRNw1TUflXloS',
  stripe_secret_key: 'sk_live_34DehX9uBfAAT2MCJsei4eT5',
  stripe_test: 'FALSE',
  stripe_client_id: 'ca_2uW3sMwmUUxhFX0GC4y3kPtdv6VqeG6S',
  secure_review_host: true,
  banner1: "https://s3-us-west-2.amazonaws.com/catarsemusic1/uploads/banner/1",
  banner2: "https://s3-us-west-2.amazonaws.com/catarsemusic1/uploads/banner/2",
  banner3: "https://s3-us-west-2.amazonaws.com/catarsemusic1/uploads/banner/3",
  banner4: "https://s3-us-west-2.amazonaws.com/catarsemusic1/uploads/banner/4",
  banner1_id: '5',
  banner2_id: '5',
  banner3_id: '5',
  banner4_id: '5',
  mandrill_username: 'alex.daoud@mac.com',
  mandrill_password: 'XXX',
  google_analytics_id: 'UA-48902502-1'
}.each do |name, value|
   conf = Configuration.find_or_initialize_by_name name
   conf.update_attributes({
     value: value
   }) if conf.new_record?
end


Channel.find_or_create_by_name!(
  name: "Channel name",
  permalink: "sample-permalink",
  description: "Lorem Ipsum"
)


OauthProvider.find_or_create_by_name!(
  name: 'facebook',
  key: '1420536498183067',
  secret: 'XXX',
  path: 'facebook'
)


puts
puts '============================================='
puts ' Showing all Authentication Providers'
puts '---------------------------------------------'

OauthProvider.all.each do |conf|
  a = conf.attributes
  puts "  name #{a['name']}"
  puts "     key: #{a['key']}"
  puts "     secret: #{a['secret']}"
  puts "     path: #{a['path']}"
  puts
end


puts
puts '============================================='
puts ' Showing all entries in Configuration Table...'
puts '---------------------------------------------'

Configuration.all.each do |conf|
  a = conf.attributes
  puts "  #{a['name']}: #{a['value']}"
end

puts '---------------------------------------------'
puts 'Done!'
