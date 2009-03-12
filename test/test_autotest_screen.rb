require 'test/unit'
require 'rubygems'
require 'autotest/screen'

class TestAutotestScreen < Test::Unit::TestCase
  def test_all_added_hooks_called
    Autotest::HOOKS.keys.each do |hook|
      assert(Autotest::ALL_HOOKS.include?(hook), %Q!"#{hook}" never called.!)
    end
  end
end
