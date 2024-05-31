if defined?(Devise)
  Devise.secret_key = ENV['DEVISE_SECRET_KEY'] || 'e4b7d3c9a0f96a8f'
end