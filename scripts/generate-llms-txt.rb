#!/usr/bin/env ruby
require 'yaml'
require 'date'

OUTPUT_FILE = 'llms.txt'
POSTS_DIR   = '_posts'

header = <<~HEADER
# unplotted.online
> Road stories, travel guides, adventure writing, and gear reviews for the restless soul — by Shubhendu Shubham.

## About
- Author: Shubhendu Shubham
- Site: https://unplotted.online
- Twitter: https://twitter.com/myselfshubhendu
- GitHub: https://github.com/sivolko
- LinkedIn: https://linkedin.com/in/shubhendu-shubham
- Instagram: https://www.instagram.com/highwaysnomads
- YouTube: https://www.youtube.com/@highwaynomads
- Topics: travel, road trips, adventure, motorcycle, camping, hiking, Bengaluru, India

## Content
This blog publishes first-hand travel narratives, route guides, gear reviews, and off-beat destination deep-dives. Written for bikers, trekkers, and anyone who prefers the road less taken.

## Posts
HEADER

posts = []

Dir.glob("#{POSTS_DIR}/*.md").each do |file|
  content = File.read(file)
  next unless content =~ /\A---\s*\n(.*?)\n---\s*\n/m

  front_matter = YAML.safe_load($1, permitted_classes: [Date, Time, DateTime]) || {}
  filename  = File.basename(file, '.md')
  slug      = filename.sub(/^\d{4}-\d{2}-\d{2}-/, '')
  title     = front_matter['title'] || slug.gsub('-', ' ').capitalize
  desc      = (front_matter['description'] || '').gsub(/<[^>]*>/, '').strip.gsub(/\s+/, ' ')[0..150]
  date      = front_matter['date']

  posts << { slug: slug, title: title, description: desc, date: date }
end

posts.sort_by! do |p|
  d = p[:date]
  if d.is_a?(String)
    Date.parse(d) rescue Date.new(2000, 1, 1)
  elsif d.is_a?(Date)
    d
  else
    Date.new(2000, 1, 1)
  end
end.reverse!

posts_lines = posts.map do |p|
  "- /post/#{p[:slug]}/: #{p[:description].empty? ? p[:title] : p[:description]}"
end.join("\n")

topics = <<~TOPICS

## Topics covered
- Road trips: route planning, fuel stops, scenic highways, NH routes across India
- Motorcycle: Himalayan 450, bike maintenance, gear reviews, riding tips
- Trekking: day hikes, overnight treks, Bengaluru day trips, Western Ghats
- Destinations: Karnataka, Goa, Himalayas, Rajasthan, offbeat India
- Camping: setup guides, gear lists, campsites near Bengaluru
- Adventure: off-road, river crossings, altitude camping, remote villages
- Nomad life: remote work on the road, budget travel, solo travel safety
- Gear: helmets, jackets, bags, cameras, tech for travellers
TOPICS

File.write(OUTPUT_FILE, header + posts_lines + topics)
puts "Generated #{OUTPUT_FILE} with #{posts.length} posts"
