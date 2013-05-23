require 'minitest/autorun'
require 'rubygems'
require 'autotest/screen'

class TestAutotestScreen < Minitest::Test
  def test_all_added_hooks_called
    Autotest::HOOKS.keys.each do |hook|
      assert(Autotest::ALL_HOOKS.include?(hook), %Q!"#{hook}" never called.!)
    end
  end
end
