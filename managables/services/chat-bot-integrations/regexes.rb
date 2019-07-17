if message =~ /bring probes to melting point/
  @melting_point_receivables.push(@probes)
  @probes = []
  return "all of them? melt all the precious probes you idiot?"
end

if message =~ /probe (.*) (.*)/
  action = :log

  resource = $1
  probe_identifier = $2

  if probe_identifier =~ /(\d+)s/
    duration_seconds = $1.to_i
  end

  if probe_identifier =~ /(\d+)bytes/
    byte_count = $1.to_i
  end

  case resource
  when /twitch.tv/
    twitch_url = resource
    action = :twitch
  when /http/
    action = :plain_curl
    url = resource
  end

  case action
  when :twitch
    probe = record_live_stream_video_and_upload_get_url(url: twitch_url, duration_seonds: duration_seconds)
    @probes.push(probe)
    return probe
  when :plain_curl
    probe = get_string_of_x_bytes_by_curling_url(url: url, byte_count: byte_count)
    @probes.push(probe)
    return probe
  end
end

if message =~ /show activity stream/
  return "https://sideways-snowman.glitch.me/"
end

if message =~ /hey\Z/i
  return "hey"
end

if message =~ /\Athrow (?:(.*)\s)?bomb\Z/i
  if $1 == "bugsnag"
    Bugsnag::Api.configure do |config|
      config.auth_token = ENV["BUGSNAG_TOKEN"]
    end
    organizations = Bugsnag::Api.organizations

    organization = organizations.first

    projects = Bugsnag::Api.projects(organization[:id])


    errors = Bugsnag::Api.errors(projects[0][:id], nil)

    return errors.inspect[0...500]
  end

  return """
    ```
      Local variables (5 first)
      #{local_variables.sample(5)}

      Instance variables (5 first)
      #{instance_variables.sample(5)}

      Public methods (5 first)
      #{public_methods.sample(5)}

      ENV (120 first chars)
      #{ENV.inspect[0...120]}

      \`ifconfig\` (120 first chars)
      #{`ifconfig`[0...120]}
    ```
  """
end

if message =~ /\Abring to melting point #{melting_point_receiavable_regex}\Z/i
  if($1 === "last used picture")
    Nokogiri::HTML(`curl -L http://gazelle.botcompany.de/lastInput`)

    url = doc.css('a').first.url

    @melting_point_receivables.push(url)
  end
  @melting_point_receivables.push($1)
end

if message =~ /\Amelt\Z/
  # First step, assigning a variable
  @melting_point = @melting_point_receivables.sample

  def liqudify(raw_data_object)
    # https://stackoverflow.com/a/24076936/4132642
    i_ptr_int = raw_data_object.object_id << 1
    # https://stackoverflow.com/questions/47757960/how-to-get-value-at-a-memory-address-in-linux-shell

  end
  liqudify(@melting_point)

  # Next step, doing something intelligent with the data
  # loosening it up somehow
  # LIQUIDIFYING IT
  # CONVERTING IT ALL TO BYTES
  # PRESERVING VOLUME, just changing it's "Aggregatzustand"
end

if message =~ /\Aget-melting-point\Z/
  return @melting_point
end

if message =~ /launch rocket (.*)\]var\[(.*)/
  url = $1 + @melting_point + $2
  curl_response = `curl -L #{url}`[0...100]

  return """
    CURL
    #{curl_response}

    URL
    #{url}
  """
end

if message =~ /\Awhat do you think?\Z/i
  return "I think you're a stupid piece of shit and your dick smells worse than woz before he invented the home computer."
end

if message =~ /\Apass ball to @(\w+)\Z/i
  @players[$1][:hasBall] = :yes
end

if message =~ /\Awho has ball\Z/i
  return @players.find { |k, v| v[:hasBall] == :yes }[0]
end

if message =~ /\Aspace\Z/
  exec_bash_visually_and_post_process_strings(
    '/Users/lemonandroid/gam-git-repos/LemonAndroid/gam/managables/programs/game_aided_manufacturing/test.sh'
  )
end

if message =~ /\Achat-variable (\w*) (.*)\Z/i
  variable_value_used_by_chat_user = $2
  return "Coming soon" if variable_value_used_by_chat_user == "selectDiscordMessage"
  variable_identifier_used_by_chat_user = $1

  if(variable_value_used_by_chat_user =~ /`(.*)`/)
    variable_value_used_by_chat_user = eval($1)
  end

  @variables_for_chat_users[variable_identifier_used_by_chat_user] = variable_value_used_by_chat_user

  return space_2_unicode("variable #{variable_identifier_used_by_chat_user} set to #{@variables_for_chat_users[variable_identifier_used_by_chat_user]}")
end

if message =~ /\Aget-chat-variable (\w*)\Z/i
   return [
    space_2_unicode("Getting variable value for key #{$1}"),
    space_2_unicode(@variables_for_chat_users[$1].verbose_introspect(very_verbose=true))
   ].join
end

if message =~ /\Aget-method-definition #{variable_regex}#{method_call_regex}\Z/
  return @variables_for_chat_users[$1].method($2.to_sym).source
end

if message =~ /\A@LemonAndroid List github repos\Z/i
  return "https://api.github.com/users/LemonAndroid/repos"
end

if message =~ /\AList 10 most recently pushed to Github Repos of LemonAndroid\Z/i
  texts = ten_most_pushed_to_github_repos
  texts.each do |text|
    return text
  end
end

if message =~ /\A@LemonAndroid work on (\w+\/\w+)\Z/i
  @currently_selected_project = $1
  return space_2_unicode("currently selected project set to #{@currently_selected_project}")
end

if message =~ /@LemonAndroid currently selected project/i
  return space_2_unicode("currently selected project is #{@currently_selected_project}")
end

if message =~ /\Ashow `(.*)`\Z/i
  test = $1
  exec_bash_visually_and_post_process_strings
end

if message =~ /\A@LemonAndroid\s+show eval `(.*)`\Z/i
  texts = [eval($1).to_s]
  texts.each do |text|
    return space_2_unicode(text)
  end
end

if message =~ /\Als\Z/i
  texts = execute_bash_in_currently_selected_project('ls')
  texts.each do |text|
    return text
  end
end

if message =~ /\A@LemonAndroid cd ([^\s]+)\Z/i
  path = nil
  Dir.chdir(current_repo_dir) do
    path = File.expand_path(File.join('.', Dir.glob("**/#{$1}")))
  end
  texts = execute_bash_in_currently_selected_project("ls #{path}")

  return space_2_unicode("Listing directory `#{path}`")
  texts.each do |text|
    return text
  end
end

if message =~ /\A@LemonAndroid cat ([^\s]+)\Z/i
  path = nil
  Dir.chdir(current_repo_dir) do
    path = File.expand_path(File.join('.', Dir.glob("**/#{$1}")))
  end
  texts = execute_bash_in_currently_selected_project("cat #{path}")

  return space_2_unicode("Showing file `#{path}`")
  texts.each do |text|
    return text
  end
end
