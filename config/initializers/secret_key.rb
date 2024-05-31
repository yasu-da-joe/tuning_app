# Ensure the key is exactly 16 bytes
key = ENV['DEVISE_SECRET_KEY']

if key.nil? || key.length != 16
  raise "DEVISE_SECRET_KEY must be exactly 16 bytes long"
end

# Use the key for encryption
cipher = OpenSSL::Cipher::AES.new(128, :CBC)
cipher.key = key