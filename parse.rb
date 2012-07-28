#!/usr/bin/env ruby

require 'nokogiri'
require 'json'
require 'sinatra'
require '/var/lib/gems/1.8/gems/sinatra-cross_origin-0.2.0/lib/sinatra/cross_origin'
require '/home/jordane/git/bard.knowledge/parse_classes.rb'

STATS=['Wis', 'Dex', 'Str', 'Con', 'Cha', 'Int']
CLASSES=['barbarian', 'bard', 'cleric', 'druid', 'fighter', 'monk', 'paladin', 'ranger', 'rogue', 'sorcerer', 'wizard']

def slugify (name) 
name.downcase!
name.delete!('(')
name.delete!(')')
name.gsub(' ', '-')
end

get '/classes/:name' do

output = ""
enable :cross_origin
  names = params[:name].split(' ')
  if names.length == 1 and names[0] == "all"
    files = []
    Dir.foreach('/home/jordane/git/bard.knowledge/classes/www.d20pfsrd.com/classes/core-classes') do |file|
      if not file == "." and not file == ".."
        files.push(file)
      end
    end
    output << files.to_json
  else 
    classes = []
    names.each do |name|
      if CLASSES.include?(name)
        classes.push(parse_class(name))
      end
    end
    if classes.length == 1
      output << classes[0].to_json
    elsif classes.length > 1
      output << classes.to_json
    return output
    end
  end
end 

get '/skills/:name' do

enable :cross_origin
skills = []

response['Access-Control'] ="allow <*>, secure=false"
html = Nokogiri::HTML(File.open("skills"))


html.css('tr').each do |line|
  name = ""
  stat = ""
  check_penalty = false
  trained = false
  td = line.css('td')
  if STATS.include?(td[-1].text)
    name = td[0].css('a').text
    stat = td[-1].text
    trained = td[-3].text == "Yes" ? true : false
    check_penalty = td[-2].text == "Yes" ? true : false
    skills.push({ :display_name => name, :name => slugify(name.clone), :stat => slugify(stat), :trained => trained, :check_penalty => check_penalty })
  end
end
  names = params[:name].split(' ')
  if names.length == 1 and names[0] == "all"
    return skills.to_json
  else
    return_skills = []
    skills.each do |skill|
      if names.include?(skill[:name])
        return_skills.push(skill)
      else
        next
      end
    end
  end
  return return_skills.to_json
end
