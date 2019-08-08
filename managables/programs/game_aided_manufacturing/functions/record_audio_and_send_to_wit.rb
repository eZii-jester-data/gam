

require_relative './base_command.rb'

class RecordAudioAndSendToWitAi < BaseCommand
    def run
        `sox -d --norm -t .wav - silence -l 1 0 1% 1 6.0 1% rate 16k >  #{(t = Tempfile.new).path}`

        `curl -XPOST 'https://api.wit.ai/speech?v=20170307' \
        -i -L \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: audio/wav" \
        --data-binary "@#{t.path}"`

        self.finish
    end
end

