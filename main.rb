# frozen-string-literal: true

#
# TODO:
# reaction stuff
# display who has which color

require 'discordrb'
require_relative 'game.rb'
require_relative 'player.rb'

config = File.foreach('config.txt').map { |line| line.split(' ').join(' ') }
TOKEN = config[0].to_s
CLIENT_ID = config[1].to_s
PREFIX = %w[!c4 !connect4].freeze

bot = Discordrb::Commands::CommandBot.new token: TOKEN, client_id: CLIENT_ID, prefix: PREFIX, max_args: 1

# !c4play <target>, start a game against another member
bot.command :play, description: 'Start a game against someone', min_args: 1 do |msg|
  break unless msg.server

  target_name = msg.content[(msg.content.index(' ') + 1)..-1]
  target = msg.server.members.select { |member| member.display_name.downcase == target_name.downcase }[0]

  if target
    if Game.locate_player(msg.author)
      msg.respond("You're already in a game")
    elsif Game.locate_player(target)
      msg.respond("They're already in a game")
    # elsif target.current_bot?
    #   msg.respond("You can't play against a bot")
    else
      game = Game.new(msg.author, target)
      msg.respond("#{msg.author.mention}'s turn:\n\n#{game.stringify_board}")
    end
  else
    msg.respond("Couldn't find that person")
  end
end

# !c4move <column>, make a move during a game in a certain column
bot.command :move, description: 'Make a move during a game', max_args: 1, min_args: 1 do |msg|
  break unless msg.server

  col = msg.content.split[1].to_i - 1
  # get the Player object for the author so we can figure out which game it is
  author = Game.locate_player(msg.author)
  if !author
    msg.respond("You're not in a game")
  elsif col.negative? || col.digits.count > 1 || col > 6
    msg.respond('Invalid input')
  else
    game = author.game
    if game.whose_turn == author
      if game.check_col_full?(col)
        msg.respond('Illegal move')
      else
        author.make_move(col)
        if game.check_win?
          game.end_game
          msg.respond("#{author.name} wins!\n\n#{game.stringify_board}")
        elsif game.check_board_full?
          game.end_game
          msg.respond("Tie!\n\n#{game.stringify_board}")
        else
          msg.respond("#{game.whose_turn.user.mention}'s turn:\n\n#{game.stringify_board}")
        end
      end
    else
      msg.respond('Not your turn')
    end
  end
end

# !c4end, end game prematurely
bot.command :end, description: 'End the game', max_args: 0 do |msg|
  break unless msg.server

  author = Game.locate_player(msg.author)
  if !author
    msg.respond("You're not in a game")
  else
    game = author.game
    game.end_game
    msg.respond("#{author.name} has ended the game between #{game.p1.name} and #{game.p2.name}.")
  end
end

bot.command :test do |msg|
  msg.respond(msg.content.split[1..-1].join)
end

at_exit { bot.stop }
bot.run
