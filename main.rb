# frozen-string-literal: true

require 'discordrb'
require_relative 'game.rb'

config = File.foreach('config.txt').map { |line| line.split(' ').join(' ') }
TOKEN = config[0].to_s
CLIENT_ID = config[1].to_s
PREFIX = %w[!c4 !connect4].freeze

bot = Discordrb::Commands::CommandBot.new token: TOKEN, client_id: CLIENT_ID, prefix: PREFIX, max_args: 2

bot.command(:test) do |msg|
  msg.respond('sup')
end
