class TC_CliTest < Test::Unit::TestCase

  @@mayfly_bin = File.dirname(__FILE__) + '/../bin/mayfly'
  @@options = {
    :version => '--version',
    :version_lots => '-l 12 -p 1234 file --version',
    :help_l => '-h',
    :help_s => '--help',
    :help_lots => '-l 12 -p 1234 file --help',
    :lives_bad => '-l FOO',
    :lives_good => '-l 10 filename',    
    :port_bad => '-p FOO',
    :port_good => '--port 1234 filename',
    :pass_bad => '--pass',
    :pass_good => '--pass password --auth filename',    
    :pass_good_no_auth => '--pass password filename',        
    :bad_opt_s => '-x',
    :bad_opt_l => '--xtra',    
    :just_file => 'filename',
    :no_file => '',
    :auth => '--auth --pass password filename',
    :no_auth => '--no-auth filename',    
    :secure => '--secure filename',
    :no_secure => '--no-secure filename',    
    :verbose => 'filename -v',
  }

  def setup
    ENV['MAYFLY_TESTING'] = 'YES'
  end
  
  def teardown
    ENV['MAYFLY_TESTING'] = nil
  end

  def test_version
    [@@options[:version], @@options[:version_lots]].each do |c|
      cmd = `#{@@mayfly_bin} #{c}`
      assert_equal("Mayfly #{Mayfly::VERSION.join('.')}\n", cmd, "Version function not working as expected")
    end
  end
  
  def test_help
    [@@options[:help_l], @@options[:help_s], @@options[:help_lots]].each do |c|
      cmd = `#{@@mayfly_bin} #{c}`
      assert(cmd.include?('Usage'), "Help function not working as expected")
    end    
  end
  
  def test_missing_args
    [@@options[:pass_bad]].each do |c|
      cmd = `#{@@mayfly_bin} #{c}`
      assert(cmd.include?('missing argument'), "Missing args validation function not working as expected")      
    end
  end
  
  def test_invalid_args
    [@@options[:lives_bad], @@options[:port_bad]].each do |c|
      cmd = `#{@@mayfly_bin} #{c}`
      assert(cmd.include?('invalid argument'), "Args validation function not working as expected")
    end
  end
  
  def test_invalid_option
    [@@options[:bad_opt_s], @@options[:bad_opt_l]].each do |c|
      cmd = `#{@@mayfly_bin} #{c}`
      assert(cmd.include?('invalid option'), "Options validation function not working as expected")
    end
  end  
  
  def test_pass
    cmd =`#{@@mayfly_bin} #{@@options[:pass_good]}`
    assert_equal("filename,7887,1,,password,false\n", cmd)
  end
  
  def test_pass_good_no_auth
    cmd =`#{@@mayfly_bin} #{@@options[:pass_good_no_auth]}`
    assert_equal("filename,7887,1,,,false\n", cmd)
  end  
  
  def test_file
    cmd =`#{@@mayfly_bin} #{@@options[:just_file]}`
    assert_equal("filename,7887,1,,,false\n", cmd) 
  end
  
  def test_lives
    cmd =`#{@@mayfly_bin} #{@@options[:lives_good]}`
    assert_equal("filename,7887,10,,,false\n", cmd) 
  end  
  
  def test_port
    cmd =`#{@@mayfly_bin} #{@@options[:port_good]}`
    assert_equal("filename,1234,1,,,false\n", cmd)
  end
  
  def test_no_file
    cmd =`#{@@mayfly_bin} #{@@options[:no_file]}`
    assert(cmd.include?('File argument not specified'))
  end  
  
  def test_secure
    cmd =`#{@@mayfly_bin} #{@@options[:secure]}`
    assert_equal("filename,7887,1,true,,false\n", cmd) 
  end
  
  def test_no_secure
    cmd =`#{@@mayfly_bin} #{@@options[:no_secure]}`
    assert_equal("filename,7887,1,false,,false\n", cmd) 
  end  
  
  def test_auth
    cmd =`#{@@mayfly_bin} #{@@options[:auth]}`
    assert_equal("filename,7887,1,,password,false\n", cmd) 
  end
  
  def test_no_auth
    cmd =`#{@@mayfly_bin} #{@@options[:no_auth]}`
    assert_equal("filename,7887,1,,,false\n", cmd) 
  end  
  
  def test_verbose
    cmd =`#{@@mayfly_bin} #{@@options[:verbose]}`
    assert_equal("filename,7887,1,,,true\n", cmd)
  end
  
end