require 'jwt'
require 'chunky_png'

class Bakery
  attr_reader :config, :assertion, :signed_assertion, :badge_template

  def initialize(config:, assertion:, badge_template:)
    @config = config
    @assertion = assertion
    @signed_assertion = nil
    @badge_template = badge_template
  end

  def encode_assertion
    @signed_assertion = JWT.encode(
      assertion,
      OpenSSL::PKey::RSA.new(config[:private_key]),
      config[:algorithm]
    )
  end

  def verify_assertion
    return false unless signed_assertion

    JWT.decode(
      signed_assertion,
      OpenSSL::PKey::RSA.new(config[:public_key]),
      true,
      algorithm: config[:algorithm]
    )
    true
  rescue Exception => e
    logger.debug("VERIFICATION ERROR: #{e.message}")
    false
  end 

  def decode_assertion
    return unless signed_assertion

    JWT.decode(
      signed_assertion,
      nil,
      false,
      algorithm: config[:algorithm]
    )&.first
  end  

  def bake
    encode_assertion unless signed_assertion

    itxt = ChunkyPNG::Chunk::InternationalText.new('openbadges', signed_assertion)

    datastream = ChunkyPNG::Datastream.from_blob badge_template
    datastream.other_chunks << itxt
    datastream.to_blob
  end
end
