# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PingController do
  describe 'index' do
    it 'should return the wanted page and answer with HTTP Status 200' do
      get :index
      assert_response :success
    end
  end
end
