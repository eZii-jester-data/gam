require 'io/console'

def at(x, y, str)
  print "\033[#{y};#{x}H#{str}"
end




#
# INIT
#
# terminal configuration 
Kernel.system "tput civis; stty -icanon -echo; resize -s 30 120; clear"
height, width = $stdout.winsize
# Ship initial position, speed and fired missiles
lvl     = 0
y_pos   = 10
y_incr  = 1
hull    = 20
shield  = 20
zion    = 40
weapon  = ['~', '=>', '░▒▓█', 'Φ']
wpn_i   = 1
fire    = [] # [x_pos, y_pos]
enemies = [] # [x_pos, y_pos]
kills   = 0

while true
  #
  # WINDOW
  #  
  # top left
  at(1, 1, "Level:   #{lvl.to_s}")
  at(1, 2, "Kills:   #{kills.to_s}")
  at(1, 5, "Enemies: #{enemies.size.to_s}")
  # top center
  at(58, 1, "ZION")
  at(40, 2, "#{('|' * zion).ljust(40, ' ')}")
  # top right
  at(width - 28, 1, 'Nebuchadnezzar')
  at(width - 28, 2, "Hull:   #{('|' *  hull).ljust(20, ' ')}")
  at(width - 28, 3, "Shield: #{('|' * shield).ljust(20, ' ')}")
  # bottom left
  at(1, height, '\'q\' to quit')
  




  #
  # USER INPUT
  #
  # STDIN input refresh screen, or 0.005 scd. Might melts some CPU ?
  refresh = Kernel.select([$stdin], nil, nil, 0.005)
  if refresh then
    case $stdin.getc
    when 'q' then system('clear') && break
    when ' ' then
      wpn_i += 1
      # unlock new weapons
      fire << [34, y_pos + 7, weapon[0]]
      fire << [34, y_pos + 6, weapon[0]] if kills >= 10
      fire << [28, y_pos + 4, weapon[1]] if kills >= 50
      fire << [22, y_pos + 5, weapon[1]] if kills >= 100
      fire << [17, y_pos + 3, weapon[2]] if kills >= 200 && wpn_i % 5 == 0
    # ANSI escape sequence
    when "\033"
      # Arrow up
      when 'A' then y_pos -= 1
      # Arrow down
      when 'B' then y_pos += 1
    end
  end






  #
  # SHIP
  #
  # clear trailing lines
  at(24, y_pos, "#{' ' * 5}")
  at(29, y_pos + 1, "#{' ' * 10}")
  at(39, y_pos + 2, "#{' ' * 3}")
  at(42, y_pos + 3, ' ')
  at(42, y_pos + 7, ' ')
  at(33, y_pos + 8, "#{' ' * 9}")
  at(28, y_pos + 9, "#{' ' * 5}")

  # make sure ship stay on the screen
  y_pos = y_pos + 1 if y_pos <= 0
  y_pos = y_pos - 1 if y_pos >= height - 8
  
  # display ship. Instanciate new File object every 0.01 scd ?  ¯\_(ツ)_/¯
  at(nil, y_pos, File.read('ascii_nebuchadnezzar'))



  #
  # FIRE
  #
  if fire.any? 
    fire.each_with_index do |f, i|
      # shots move forward without leaving a character behind them
      at(f[0], f[1], ' ')
      f[0] += 1

      (f[0] + f[2].size) < width ? at(f[0], f[1], f[2]) : at(f[0], f[1], "#{' ' * f[2].size}")
      fire.delete_at(i) if f[0] > width
    end
  end




  #
  # ENEMIES
  #
  # e = [x_position, y_position, x_pos as float, speed]
  
  # more and more enemies spawn
  if lvl < 1000
    enemies << [width, rand(9..27), width, rand(0.008..0.09)] if lvl % 360 == 0
  elsif lvl <= 2500
    enemies << [width, rand(9..27), width, rand(0.008..0.09)] if lvl % 140 == 0
  elsif lvl <= 5000
    enemies << [width, rand(9..27), width, rand(0.008..0.09)] if lvl % 51 == 0
  elsif lvl <= 10_000
    enemies << [width, rand(9..27), width, rand(0.008..0.09)] if lvl % 20 == 0
  elsif lvl <= 11_000
    enemies << [width, rand(9..27), width, rand(0.008..0.09)] if lvl % 15 == 0
  elsif lvl <= 12_000
    enemies << [width, rand(9..27), width, rand(0.008..0.09)] if lvl % 10 == 0
  elsif lvl <= 13_000
    enemies << [width, rand(9..27), width, rand(0.008..0.09)] if lvl % 5 == 0
  elsif lvl > 13_000
    enemies << [width, rand(9..27), width, rand(0.008..0.09)] if lvl % 2 == 0
  end

  enemies.each_with_index do |e, i|
    # each enemy has his own speed
    e[2] -= e[3]
    # enemies speed increases with time
    case lvl
      when 1..2000    then nil 
      when 2001..5000 then e[2] -= 0.02
      when 5001..7500 then e[2] -= 0.04
      else                 e[2] -= 0.07
    end
    e[0] = e[2].to_i

    # display enemies
    at(e[0],     e[1], '*')
    at(e[0] + 1, e[1], ' ')
    
    # kill an enemy if he gets shot
    fire.each_with_index do |f, j|
      if e[0] == f[0] && e[1] == f[1]
        enemies.delete_at(i)
        at(f[0] - 1, f[1], '     ')
        # weapon[2] (= laser) go through enemies
        fire.delete_at(j) if f[2] != weapon[2]
        kills += 1
      end
    end

    # an enemy damages the ship shield/hull if they're on the same cell
    if e[0] < 42
      if (e[0].between?(24, 28) && e[1] == y_pos + 1) ||
         (e[0].between?(23, 38) && e[1] == y_pos + 2) ||
         (e[0].between?(23, 41) && e[1] == y_pos + 3) ||
         (e[0] <= 42 && e[1] == y_pos + 4) ||
         (e[0] <= 42 && e[1] == y_pos + 5) ||
         (e[0] <= 42 && e[1] == y_pos + 6) ||
         (e[0].between?(27, 41) && e[1] == y_pos + 7) ||
         (e[0].between?(28, 32) && e[1] == y_pos + 8)
      then
        shield < 1 ? hull -= 0.2 : shield -= 1
        enemies.delete_at(i)
      end
    end

    # hide enemies if they cross the window and damage zion
    if e[0] == 0
      enemies.delete_at(i) && zion -= 1
    end
  end
  # loose victory
  break if hull < 0.2 || zion < 1

  lvl += 1
end

Kernel.system "clear; tput cnorm; stty icanon echo"

