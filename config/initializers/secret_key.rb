if defined?(Devise)
  devise_key = ENV['DEVISE_SECRET_KEY'] || 'e4b7d3c9a0f96a8f'
  raise "DEVISE_SECRET_KEY must be exactly 16 bytes" unless devise_key.bytesize == 16
  Devise.secret_key = devise_key
end
