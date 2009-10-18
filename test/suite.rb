$:.push(File.dirname(__FILE__) + "/../lib", File.dirname(__FILE__))
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'
require 'tc_cli_test'
require 'tc_mayfly_test'
require 'mayfly'

class TS_MyTests
 def self.suite
   suite = Test::Unit::TestSuite.new 'Mayfly tests'
   suite << TC_CliTest.suite
   suite << TC_MayflyTest.suite   
   return suite
 end
end
Test::Unit::UI::Console::TestRunner.run(TS_MyTests)