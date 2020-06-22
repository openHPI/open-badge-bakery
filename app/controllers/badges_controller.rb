# frozen_string_literal: true

class BadgesController < ApplicationController
  before_action :check_params

  def create
    logger.info("Baking for assertion #{assertion[:id]} with flavor #{bake_params[:flavor] || 'default'}")

    bakery = Bakery.new(
      config: bakery_config[:signing],
      assertion: assertion,
      badge_template: badge_template_blob
    )

    send_data(bakery.bake, type: 'image/png', dispositon: 'inline')
  end

  private

  def bake_params
    params.permit(:imagePath, :imageURL, :flavor).to_h
  end

  def assertion
    params[:assertion].to_unsafe_h
  end

  # rubocop:disable Metrics/AbcSize
  def check_params
    errors = []
    errors << 'assertion required' unless params[:assertion]
    errors << 'imagePath or imageURL required' unless params[:imagePath] || params[:imageURL]
    errors << "unknown flavor: #{params[:flavor]}" if params[:flavor] && !flavors.include?(params[:flavor])
    render status: 422, json: { errors: errors } if errors.any?
  end
  # rubocop:enable Metrics/AbcSize

  def bakery_config
    @bakery_config ||= Rails.configuration.bakery[bake_params[:flavor]] \
                   || Rails.configuration.bakery[:default]
  end

  def flavors
    Rails.configuration.bakery.keys
  end

  # rubocop:disable Metrics/AbcSize
  def badge_template_blob
    if bake_params[:imageURL]
      return Rails.cache.fetch(bake_params[:imageURL], expires_in: 1.hour) do
        Rails.logger.info "Loading template from #{bake_params[:imageURL]}"
        Typhoeus.get(bake_params[:imageURL]).body
      end
    end

    template_path = File.join(bakery_config[:images][:base_path], bake_params[:imagePath])
    File.read(template_path)
  end
  # rubocop:enable Metrics/AbcSize
end
