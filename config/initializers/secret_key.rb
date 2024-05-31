if defined?(Devise)
  devise_key = ENV['DEVISE_SECRET_KEY']
  if devise_key.nil?
    raise "DEVISE_SECRET_KEY environment variable is not set"
  end
  if devise_key.bytesize != 16 # 16文字のキー
    raise "DEVISE_SECRET_KEY must be exactly 16 bytes"
  end
  Devise.secret_key = devise_key
end
