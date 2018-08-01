require 'jwt'

def verify_assertion(signed_assertion:, algorithm:, public_key:)
  JWT.decode(
    signed_assertion,
    OpenSSL::PKey::RSA.new(public_key),
    true,
    algorithm: algorithm
  )
  true
rescue Exception => e
  false
end 