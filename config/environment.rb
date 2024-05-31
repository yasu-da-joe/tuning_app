# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

require 'openssl'

key = ENV['DEVISE_SECRET_KEY']

# Ensure the key is exactly 16 bytes
if key.nil? || key.length != 16
  raise "DEVISE_SECRET_KEY must be exactly 16 bytes"
end

# Use the key for encryption
cipher = OpenSSL::Cipher::AES.new(128, :CBC)
cipher.key = key