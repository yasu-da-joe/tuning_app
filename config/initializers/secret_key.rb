if defined?(Devise)
  devise_key = ENV['DEVISE_SECRET_KEY']
  if devise_key.nil?
    raise "DEVISE_SECRET_KEY environment variable is not set"
  end
  if devise_key.bytesize != 32 # hexの文字数は2倍
    raise "DEVISE_SECRET_KEY must be exactly 16 bytes (32 hex characters)"
  end
  Devise.secret_key = devise_key
end
