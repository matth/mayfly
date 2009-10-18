module Mayfly
  module Utils

    require 'rubygems'
    gem 'growl', '=1.0.3'
    require 'growl'
    include Growl
    
    require 'socket'
    
    def growl(msg)
      if Growl.installed?
        notify_info(msg, {:title => 'mayfly'}) 
      end
    end

    # http://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
    def local_ip
          
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
      
    ensure
      Socket.do_not_reverse_lookup = orig
    end
    module_function :local_ip
    
    # Some helpers for the cli  
    class Cli
      
      gem 'highline', '=1.5.1'
      require 'highline/import'
            
      def self.get_passwd  
        passwd = ask('Password, leave blank for none: ') {|q| q.echo = false}
        return nil if passwd == ''
        if (passwd != ask('Confirm password: ') {|q| q.echo = false})
          puts 'Passwords do not match, exiting'
          exit 1
        end
        passwd
      end          
             
    end
    
  end
end