require 'mayfly'

class MockServer < Mayfly::Server
  def logger
    @logger ||= Mayfly::Log.new('/dev/null', WEBrick::Log::INFO)
  end
  def get_cert
    return 'foo', 'bar'
  end
end

class TC_MayflyTest < Test::Unit::TestCase
  
  def test_file_not_found
    assert_raise(Mayfly::FileNotFoundException) do 
      Mayfly::Server.new('i-should-not-exist.jpeg', 1, 1, false, false, false)        
    end
  end
  
  def test_file_close_callback
    some_var = true
    callback = Proc.new {some_var = false}
    file = Mayfly::File.new('/dev/null', callback)
    assert(some_var)
    file.close
    assert(!some_var)
  end
  
  def test_server_initialize_secure
    
    server = MockServer.new('/dev/null', 1234, 10, true)
    expected_config = {
      :SSLCertificate => "foo",
      :SSLEnable => true,
      :SSLPrivateKey => "bar",
      :SSLVerifyClient => 0,
      :Logger=> server.config[:Logger],
      :AccessLog => server.config[:AccessLog],
      :Port => 1234   
    }
    assert_equal(expected_config, server.config)
          
  end
  
  def test_server_initialize_no_secure
    server = MockServer.new('/dev/null', 4567, 33, false)
    expected_config = {
      :Logger=> server.config[:Logger],
      :AccessLog => server.config[:AccessLog],
      :Port => 4567   
    }
    assert_equal(expected_config, server.config)
  end
  
end