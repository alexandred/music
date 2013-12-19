# coding: utf-8

puts 'Seeding the database...'

[
  { en: 'Country' },
  { en: 'Electronic' },
  { en: 'Hip Hop' },
  { en: 'Jazz' },
  { en: 'Metal'},
  { en: 'Pop' },
  { en: 'R&B' },
  { en: 'Rock' }
].each do |name|
   category = Category.find_or_initialize_by_name_en name[:en]
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
  company_name: 'Catarse',
  host: 'tribaltears.com',
  base_url: "http://tribaltears.com",
  email_contact: 'contato@catarse.me',
  email_payments: 'financeiro@catarse.me',
  email_projects: 'projetos@catarse.me',
  email_system: 'system@catarse.me',
  email_no_reply: 'no-reply@catarse.me',
  facebook_url: "http://facebook.com/catarse.me",
  facebook_app_id: '173747042661491',
  twitter_url: 'http://twitter.com/catarse',
  twitter_username: "catarse",
  mailchimp_url: "http://catarse.us5.list-manage.com/subscribe/post?u=ebfcd0d16dbb0001a0bea3639&amp;id=149c39709e",
  catarse_fee: '0.13',
  support_forum: 'http://suporte.catarse.me/',
  base_domain: 'tribaltears.com',
  uservoice_secret_gadget: 'change_this',
  uservoice_key: 'uservoice_key',
  faq_url: 'http://suporte.catarse.me/',
  feedback_url: 'http://suporte.catarse.me/forums/103171-catarse-ideias-gerais',
  support_url: 'http://suporte.catarse.me/',
  terms_url: 'http://suporte.catarse.me/knowledgebase/articles/161102-terms-of-use',
  privacy_url: 'http://suporte.catarse.me/knowledgebase/articles/161104-privacy-policy',
  instagram_url: 'http://instagram.com/catarse_',
  blog_url: "http://blog.catarse.me",
  github_url: 'http://github.com/catarse',
  contato_url: 'http://suporte.catarse.me/',
  stripe_api_key: 'pk_test_Cn1EzZY1Z9JqEnRC7q6Ro3tE',
  stripe_secret_key: 'sk_test_kPcf0Yb4LTS95jqvojnNn2ls',
  stripe_test: 'TRUE',
  stripe_client_id: 'ca_2uW3Flc20I4UqjNiwOGyDyZUv3Xi8kua',
  #secure_review_host: true,
  aws_access_key: 'AKIAIDJAMCVP5M44OGGA',
  aws_secret_key: 'XXX',
  aws_bucket: 'catarsemusic'
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
  key: 'your_facebook_app_key',
  secret: 'your_facebook_app_secret',
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
