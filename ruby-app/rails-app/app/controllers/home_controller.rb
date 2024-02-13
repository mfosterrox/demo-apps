require 'net/http'
require 'uri'
require 'json'

class HomeController < ApplicationController
  def index
    @image_url = get_content
    @dummy = Dummy.first || Dummy.create(message: 'Initial message')
  end

  private

  def get_content
    uri = URI.parse(ENV.fetch('CONTENT_API_URL'))
    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)
    data.fetch('url')
  end
end
