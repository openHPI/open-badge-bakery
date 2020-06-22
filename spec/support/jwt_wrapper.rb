# frozen_string_literal: true

require 'jwt'

def verify_assertion(signed_assertion:, algorithm:, public_key:)
  JWT.decode(
    signed_assertion,
    OpenSSL::PKey::RSA.new(public_key),
    true,
    algorithm: algorithm
  )
  true
# there are too many openssl or jwt exception types to catch separately
# rubocop:disable Lint/RescueException
rescue Exception
  false
  # rubocop:enable Lint/RescueException
end
