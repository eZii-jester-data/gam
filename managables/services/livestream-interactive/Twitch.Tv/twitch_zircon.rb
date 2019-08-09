require 'zircon'
require 'colorize'
require 'net/http'
require 'cgi'
LOG_FILE = File.open('chat.txt', 'w')

SCREEN = []

TWITCH_CHANNEL = '#' + ENV["TWITCH_CHANNEL"]

def start
  client = Zircon.new(
    server: 'irc.twitch.tv',
    port: '6667',
    channel: TWITCH_CHANNEL,
    username: 'ezii_tm_registerred',
    password: ENV["EZE_TWITCH_TOKEN_CHAT"]
  )

  removed_colors = [:black, :white, :light_black, :light_white]
  colors = String.colors - removed_colors
  client.on_message do |message|
    puts ">>> #{message.from}: #{message.body}".colorize(colors.sample)
    LOG_FILE.write(message.body.to_s + "\n")
    if message.body == "Nebuchadnezzar"
      Thread.new do
        i = 0
        puts `ls`
        Dir.chdir("managables/services/livestream-interactive/Twitch.Tv/") do
          open("|ruby zion_fleet.rb") do |∫|
            while response = ∫.gets
              i += 1
              next if i < 20
              SCREEN.push(response)
              # if rand < 0.00001
              #   byebug
              # end
  
              url = URI.parse('https://eezee-9.herokuapp.com' + '?message=' + CGI.escape(response))
              response = Net::HTTP.get(url)
              puts response
              client.privmsg(TWITCH_CHANNEL, response.gsub(/\s/, '.')) if !response.empty?
            end
          end 
        end
      end
    end

    if message.body
      url = URI.parse('https://eezee-9.herokuapp.com' + '?message=' + CGI.escape(message.body))
      response = Net::HTTP.get(url)
      puts response
      client.privmsg(TWITCH_CHANNEL, response) if !response.empty?
    end
  end

  client.run!
end

start()

