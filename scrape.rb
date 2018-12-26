require 'faraday'
require 'faraday_middleware'
require_relative 'html_generation'

print 'enter imgur album ids (separated by space): '
imgur_album_ids = gets.strip.split(/\s+/).uniq

agent = Faraday.new(:url => 'https://api.imgur.com') do |f|
  f.request :json
  f.response :json, content_type: /\bjson$/
  f.adapter  Faraday.default_adapter
  f.headers['Authorization'] = "Client-ID #{File.read("#{__dir__}/imgur_client_id.example").strip}"
end

save_dir = "#{__dir__}/dl"

imgur_album_ids.each do |album_id|
  response = agent.get "/3/album/#{album_id}"

  `mkdir -p #{save_dir}`

  response.body['data']['images'].each do |image|
    `wget -P #{save_dir} -q --show-progress --no-clobber #{image['link']}`
  end
end

generate_slideshow interval: 3000
generate_new_tab