#!/usr/bin/env ruby

require 'nokogiri'
require 'json'
#require 'sinatra'
#require '/var/lib/gems/1.8/gems/sinatra-cross_origin-0.2.0/lib/sinatra/cross_origin'

SPELL_CASTERS=['bard', 'cleric', 'druid', 'sorcerer', 'wizard', 'ranger', 'paladin']
TEN_LEVEL_SPELLS=['cleric', 'druid', 'wizard', 'sorcerer']
SEVEN_LEVEL_SPELLS=['bard', 'ranger', 'paladin']
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
            bab.push(values[stat].text().split(', '))
          end
        end
      else
        rows[1..rows.length].each do |row|
          values = row.css('td')
          if not stat == SPECIAL
            bab.push(values[stat].text().scan(/\d+/)[0] ? values[stat].text().scan(/\d+/)[0] : '0')
          else
            bab.push(values[stat].text().split(', '))
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
            bab.push(values[stat].text().split(', '))
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
            bab.push(values[stat].text().split(', '))
          end
        end
      end
    end
  end
  return bab
end

def parse_class (pf_class)
  file = '/home/jordane/git/bard.knowledge/classes/www.d20pfsrd.com/classes/core-classes/' + pf_class
  stats = {}
  spells = {}
  special = {}
  if SPELL_CASTERS.include?(pf_class)
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
  stats[:special] = special
  pf_class_stats = { :stats => stats, :name => pf_class,}
  return pf_class_stats
end

