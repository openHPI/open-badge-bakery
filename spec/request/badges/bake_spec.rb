# frozen_string_literal: true

require 'rails_helper'
require 'chunky_png'

RSpec.describe 'bake', type: :request do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:payload) { {} }

  subject { post '/bake', params: payload, headers: headers, as: :json }
  let(:json) { JSON.parse(subject.body) }

  before do
    Rails.configuration.bakery[:default][:images][:base_path] = Rails.root.join('spec/files')
  end

  shared_examples 'properly baked badge' do |flavor|
    it 'responds with png image' do
      expect(subject).to be_successful
      expect(subject.headers['Content-Type']).to eq 'image/png'
    end

    it 'bakes the assertion into the png' do
      badge = subject.body
      config = Rails.configuration.bakery[flavor][:signing]

      # extract and verify signed assertion
      ds = ChunkyPNG::Datastream.from_blob(badge)
      signed_assertion = ds.other_chunks.select { |c| c.type == 'iTXt' }.first.text

      verify_params = {
        signed_assertion: signed_assertion,
        algorithm: config[:algorithm],
        public_key: config[:public_key]
      }

      expect(verify_assertion(**verify_params)).to be_truthy
    end
  end

  describe 'response' do
    subject { super(); response }

    context 'with insufficient parameters' do
      it 'responds with error message' do
        expect(subject.status).to eq 422
        expect(json['errors']).to include('assertion required')
        expect(json['errors']).to include('imagePath or imageURL required')
      end
    end

    context 'with invalid flavor' do
      let(:payload) { super().merge(flavor: 'udacity') }

      it 'responds with error message' do
        expect(subject.status).to eq 422
        expect(json['errors']).to include('unknown flavor: udacity')
      end
    end

    context 'with valid parameters' do
      let(:assertion) do
        {
          id: 'abcdefghijklm1234567898765',
          recipient: {
            identity: 'sha256$a1b2c3d4e5f6g7h8i9a1b2c3d4e5f6g7h8i9a1b2c3d4e5f6g7h8i9',
            type: 'email',
            hashed: true
          },
          badge: 'http://issuersite.org/badge-class.json',
          verify: {
            url: 'http://issuersite.org/public-key.pem',
            type: 'signed'
          },
          issuedOn: 1_403_120_715
        }
      end
      let(:image_path) { 'sample_badge_template.png' }

      let(:payload) { super().merge(assertion: assertion, imagePath: image_path) }

      it_behaves_like 'properly baked badge', :default

      context 'with flavor' do
        before do
          rsa_key = OpenSSL::PKey::RSA.new(2048)

          Rails.configuration.bakery[:openhpi] = {
            signing: {
              algorithm: 'RS256',
              private_key: rsa_key.to_pem,
              public_key: rsa_key.public_key.to_pem
            },
            images: {
              base_path: Rails.root.join('spec/files')
            }
          }
        end

        let(:payload) { super().merge(flavor: 'openhpi') }

        it_behaves_like 'properly baked badge', :openhpi
      end

      context 'with imageURL' do
        let(:image_url) { 'http://test.host/badge_template.png' }
        let(:payload) { super().merge(assertion: assertion, imageURL: image_url).except(:image_path) }

        before do
          stub_request(:get, image_url)
            .to_return(
              body: File.open(Rails.root.join('spec/files/sample_badge_template.png')),
              status: 200,
              headers: { 'Content-Type' => 'image/png' }
            )
        end

        it_behaves_like 'properly baked badge', :default
      end
    end
  end
end
