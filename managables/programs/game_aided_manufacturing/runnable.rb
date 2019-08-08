require_relative 'gam'
require_relative 'lib/drb_server.rb'


gam = Gam.new


WIT = Wit.new(access_token: ENV['WIT_AI_TOKEN_SERVER'])


Thread.new do
    if WIT.get_entity('intent').grep(/.*move.*cube.*/)
        gam.move_cube(:any, [rand(), rand(), rand()])
    end
end


DrbServer.new(gam).start

gam.start