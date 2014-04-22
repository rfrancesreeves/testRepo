#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'machinist'
require 'faker'
require 'jbuilder'

no_teams = ARGV[0].to_i || 24
no_players_per_team = ARGV[1].to_i || 20

if ARGV.count < 2
  puts "json <team> <players per team>"
  exit()

end

class Team
  extend Machinist::Machinable
  attr_accessor :id, :players, :name
end

class Player
  extend Machinist::Machinable
  attr_accessor :id, :first_name, :last_name, :player_number, :goals, :shots,:team
end
I18n.enforce_available_locales = false

Team.blueprint do
  id { sn }
  name { Faker::Team.name.titleize }
  players { Array.new(no_players_per_team) { Player.make  } }
end

Player.blueprint do
  id { sn }
  last_name { Faker::Name.last_name }
  first_name { Faker::Name.first_name }
  shots { Faker::Number.number(3) }
  goals { Faker::Number.number(2) }
  player_number { Faker::Number.number(2) }
end

def caviar_key(obj)
  "#{obj.class.name.downcase}_#{obj.id}"
end

def caviar_url(obj)
  "caviar://" + caviar_key(obj)
end

teams = Array.new(no_teams) { Team.make }
json_builder = Jbuilder.encode do |json|
  teams.each do |team|
   json.set! caviar_key team  do
     json.(team,:id,:name)
     json.players team.players.map {|p| caviar_url p }
   end
  end
  teams.each do |team|
    team.players.each do |player|
      json.set! caviar_key player do
        json.(player,:id,:first_name,:last_name,:shots,:goals,:player_number)
        json.team caviar_url team
      end
    end
  end
end


json_obj = JSON.parse(json_builder)
puts       JSON.pretty_generate(json_obj)
