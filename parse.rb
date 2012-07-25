#!/usr/bin/env ruby

require 'nokogiri'
require 'json'
require 'sinatra'

STATS=['Wis', 'Dex', 'Str', 'Con', 'Cha', 'Int']

def slugify (name) 
name.downcase!
name.delete!('(')
name.delete!(')')
name.gsub(' ', '-')
end
get '/skills/:name' do
skills = []

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
