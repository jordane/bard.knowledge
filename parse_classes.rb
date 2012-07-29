#!/usr/bin/env ruby

require 'nokogiri'
require 'json'
#require 'sinatra'
#require '/var/lib/gems/1.8/gems/sinatra-cross_origin-0.2.0/lib/sinatra/cross_origin'

TEN_LEVEL_SPELLS=['cleric', 'druid', 'wizard', 'oracle', 'witch']
SEVEN_LEVEL_SPELLS=[ 'magus']
SIX_LEVEL_SPELLS=['alchemist', 'summoner', 'inquisitor', 'bard']
FOUR_LEVEL_SPELLS=['antipaladin', 'paladin', 'ranger']
NINE_LEVEL_SPELLS=['oracle', 'sorcerer']
SPELL_CASTERS= TEN_LEVEL_SPELLS + SEVEN_LEVEL_SPELLS + SIX_LEVEL_SPELLS + NINE_LEVEL_SPELLS + FOUR_LEVEL_SPELLS
STATS=['Wis', 'Dex', 'Str', 'Con', 'Cha', 'Int']
BAB = 1
FORT = 2
REF = 3
WILL = 4
SPECIAL = 5
SPELLS_0 = 6
SPELLS_1 = 7
SPELLS_2 = 8
SPELLS_3 = 9
SPELLS_4 = 10
SPELLS_5 = 11
SPELLS_6 = 12
SPELLS_7 = 13
SPELLS_8 = 14
SPELLS_9 = 15
SPELLS = [SPELLS_0, SPELLS_1, SPELLS_2, SPELLS_3, SPELLS_4, SPELLS_5, SPELLS_6, SPELLS_7, SPELLS_8, SPELLS_9]
def slugify (name) 
name.downcase!
name.delete!('(')
name.delete!(')')
name.gsub(' ', '-')
end

def parse_skills(pf_class)
  class_number = 0
  class_skills = []
  html = Nokogiri::HTML(File.open('skills'))
  tables = html.css('table')
  skills_table = tables[3]
  rows = skills_table.css('tbody tr')
  1.step(rows[0].css('td').length).to_a.each do |number|
    if defined?(rows[0].css('td')[number].get_attribute('title').downcase)
      if rows[0].css('td')[number].get_attribute('title').downcase == pf_class
        class_number = number
        break
      end
    end
  end
  rows[1..rows.css('td').length].each do |row|
    if defined?(row.css('td')[class_number].text)
      if row.css('td')[class_number].text == 'C'
        class_skills.push(slugify(row.css('td')[0].text.downcase))
      end
    end
  end
  return class_skills
end

def parse_stats (stat,file)
  bab = []
  html = Nokogiri::HTML(File.open(file))
  rows = html.css('table')
  rows = rows[2].css('tbody tr')
  if defined?(rows[0].css('th')[0].text)
    if rows[0].css('th')[0].text() == "Level"
      if SPELL_CASTERS.include?(file.split('/')[-1])
        rows[2..rows.length].each do |row|
          values = row.css('td')
          if not stat == SPECIAL
            bab.push(values[stat].text().scan(/\d+/)[0] ? values[stat].text().scan(/\d+/)[0] : '0')
          else
            if values[stat].text().strip == "\303\202\302\240"
              bab.push([""])
            else
              bab.push(values[stat].text().strip.split(', ') ? values[stat].text().split(', ') : '')
            end
          end
        end
      else
        rows[1..rows.length].each do |row|
          values = row.css('td')
          if not stat == SPECIAL
            bab.push(values[stat].text().scan(/\d+/)[0] ? values[stat].text().scan(/\d+/)[0] : '0')
          else
            if values[stat].text().strip == "\303\202\302\240"
              bab.push([""])
            else
              bab.push(values[stat].text().strip.split(', ') ? values[stat].text().split(', ') : '')
            end
          end
        end
      end
    end
  else
    if SPELL_CASTERS.include?(file.split('/')[-1])
      if rows[0].css('td')[0].text() == "Level"
        rows[2..rows.length].each do |row|
          values = row.css('td')
          if not stat == SPECIAL
            bab.push(values[stat].text().scan(/\d+/)[0] ? values[stat].text().scan(/\d+/)[0] : '0')
          else
            if values[stat].text().strip == "\303\202\302\240"
              bab.push([""])
            else
              bab.push(values[stat].text().strip.split(', ') ? values[stat].text().split(', ') : '')
            end
          end
        end
      end
    else
      if rows[0].css('td')[0].text() == "Level"
        rows[1..rows.length].each do |row|
          values = row.css('td')
          if not stat == SPECIAL
            bab.push(values[stat].text().scan(/\d+/)[0] ? values[stat].text().scan(/\d+/)[0] : '0')
          else
            if values[stat].text().strip == "\303\202\302\240"
              bab.push([""])
            else
              bab.push(values[stat].text().strip.split(', ') ? values[stat].text().split(', ') : '')
            end
          end
        end
      end
    end
  end
  return bab
end

def parse_class (pf_class)
  if CORE_CLASSES.include?(pf_class)
    dir = '/home/jordane/git/bard.knowledge/classes/www.d20pfsrd.com/classes/core-classes/'
  elsif BASE_CLASSES.include?(pf_class)
    dir = '/home/jordane/git/bard.knowledge/classes/www.d20pfsrd.com/classes/base-classes/'
  elsif ALT_CLASSES.include?(pf_class)
    dir = '/home/jordane/git/bard.knowledge/classes/www.d20pfsrd.com/classes/alternate-classes/'
  end
  file = dir + pf_class
  stats = {}
  spells = {}
  special = {}
  if SIX_LEVEL_SPELLS.include?(pf_class)
    SPELLS[1..5].each do |spell|
      spells[(spell - 6).to_s] = parse_stats(spell - 1, file)
  end
  elsif NINE_LEVEL_SPELLS.include?(pf_class)
    SPELLS[1..9].each do |spell|
      spells[(spell - 6).to_s] = parse_stats(spell - 1, file)
  end
  elsif FOUR_LEVEL_SPELLS.include?(pf_class)
    SPELLS[1..4].each do |spell|
      spells[(spell -6).to_s] = parse_stats(spell-1, file)
  end
  elsif SPELL_CASTERS.include?(pf_class)
    if TEN_LEVEL_SPELLS.include?(pf_class)
      SPELLS.each do |spell|
        spells[(spell - 6).to_s] = parse_stats(spell, file)
      end
    elsif SEVEN_LEVEL_SPELLS.include?(pf_class)
      SPELLS[0..6].each do |spell|
        spells[(spell - 6).to_s] = parse_stats(spell, file)
      end
    end  
  end
  %w{BAB FORT REF WILL}.each do |stat|
    stats[stat.downcase] = parse_stats(eval(stat), file)
  end
  special = parse_stats(SPECIAL, file)
  stats[:spells] = spells
  stats[:skills] = parse_skills(pf_class)
  stats[:special] = special
  pf_class_stats = { :stats => stats, :name => pf_class, :display_name => pf_class.capitalize}
  return pf_class_stats
end

