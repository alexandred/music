CarrierWave.configure do |config|
  if Rails.env.production? and Configuration[:aws_access_key]
    config.root = Rails.root.join('tmp')
    config.cache_dir = 'carrierwave'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Configuration[:aws_access_key],
      aws_secret_access_key: Configuration[:aws_secret_key],
      endpoint: 'http://s3.amazonaws.com'
    }
    config.fog_directory  = Configuration[:aws_bucket]
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
    config.asset_host = "http://#{config.fog_directory}"
  else
    config.enable_processing = false if Rails.env.test? or Rails.env.cucumber?
  end
end
