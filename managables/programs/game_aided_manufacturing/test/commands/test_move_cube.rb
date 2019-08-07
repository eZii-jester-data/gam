require_relative '../test_helper.rb'
require 'byebug'

module SystemTests
  class TestSelectionCube < AbstractSystemTest
    def test_move_any_cube_somehow
        open_gam_window do |console_stdin, console_stdout|
            cubes_before = drb_interface.cubes

            assert_equal cubes_after, cubes_before
            drb_interface.move_cube(:any, *[rand(), rand(), rand()])
            cubes_after = drb_interface.cubes

            refute_equal cubes_after, cubes_before
        end
    end
  end
end
