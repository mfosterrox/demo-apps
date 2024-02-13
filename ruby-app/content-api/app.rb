#!/usr/bin/env ruby

require 'bundler/setup'
require 'sinatra'
require 'net/http'
require 'uri'
require 'json'

set :bind, '0.0.0.0'

def get_random_cat_image_url
  uri = URI.parse('https://api.thecatapi.com/v1/images/search')
  response = Net::HTTP.get_response(uri)
  data = JSON.parse(response.body)
  data[0].fetch('url')
end

get '/image_url.json' do
  { url: get_random_cat_image_url }.to_json
end
