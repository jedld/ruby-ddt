#This file was automatically generated by the pretentious gem
require 'minitest_helper'
require "minitest/autorun"

class TestTestClass2 < Minitest::Test
end

class Scenario1 < TestTestClass2
  def setup
    @fixture = TestClass2.new("This is message 2")
  end

  def test_current_expectation

    #TestClass2#print_message  should return 
    assert_nil @fixture.print_message

    #TestClass2#print_message  should return 
    assert_nil @fixture.print_message


  end
end

