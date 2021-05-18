require "test_helper"

class SmartWatchTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SmartWatch.version
  end

  # def test_docker_install
  # 	assert_equal "Hello World",
  # 		SmartWatch::Docker.new.install
  # end
end
