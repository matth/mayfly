module Mayfly 
  
  require 'rubygems'
  require 'thread'
  require 'webrick/httputils'
  require 'mayfly/utils'    
  include Mayfly::Utils
  
  class Servlet < WEBrick::HTTPServlet::AbstractServlet
  
    @@instance = nil
    @@instance_creation_mutex = Mutex.new
    
    def self.get_instance(config, *options)
      @@instance_creation_mutex.synchronize {
        @@instance = @@instance || self.new(config, *options)
      }
    end

    def initialize(config, file, max, passwd = nil)
      super
      @file = file
      @max = max
      @count = 1
      @count_mutex = Mutex.new
      @passwd = passwd
    end
  
    def do_GET(req, resp)

      if (@count > @max)
        resp.status = 401
      end
      
      if (@passwd)
        WEBrick::HTTPAuth.basic_auth(req, resp, 'mayfly') do |user, pass|
            user == 'mayfly' && pass == @passwd
        end
      end
            
      st = File::stat(@file)
      resp['content-type'] = WEBrick::HTTPUtils::mime_type(@file, WEBrick::HTTPUtils::DefaultMimeTypes) 
      resp['content-length'] = st.size
      resp['content-disposition'] = "attachment; filename=\"#{File.basename(@file)}\""
      resp['last-modified'] = st.mtime.httpdate
      resp['Cache-Control'] = 'no-cache, must-revalidate'
      
      close_callback = nil 
      
      @count_mutex.synchronize {
        @count += 1
        close_callback = Proc.new do
          growl("mayfly served #{@file} to #{req.peeraddr[2]}")            
          if (@count > @max)
            @server.shutdown if (@count >= @max) 
            growl("mayfly has died, it served #{@file} #{@max} times")            
          end
        end
      }
      
      if (@count <= @max + 1)
        resp.body = File.new(@file, close_callback)
      end
      
    end
    
  end

end