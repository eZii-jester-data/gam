require 'zircon'
require 'colorize'
require 'byebug'
require 'net/http'
require 'cgi'
LOG_FILE = File.open('chat.txt', 'w')


def start
  client = Zircon.new(
    server: 'irc.twitch.tv',
    port: '6667',
    channel: '#dowright',
    username: 'ezii_tm_registerred',
    password: ENV["EZE_TWITCH_TOKEN_CHAT"]
  )

  removed_colors = [:black, :white, :light_black, :light_white]
  colors = String.colors - removed_colors

  client.on_message do |message|
    puts ">>> #{message.from}: #{message.body}".colorize(colors.sample)
    LOG_FILE.write(message.body.to_s + "\n")

    if message.body
      url = URI.parse('https://eezee-9.herokuapp.com' + '?message=' + CGI.escape(message.body))
      response = Net::HTTP.get(url)
      puts response
      client.privmsg("#dowright", response) if !response.empty?
    end
  end

  client.run!
end

start()

