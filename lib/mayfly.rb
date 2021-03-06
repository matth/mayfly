require 'webrick'
require 'webrick/https'
require 'logger'
require 'mayfly/file'
require 'mayfly/servlet'
require 'mayfly/utils'
include Mayfly::Utils

module Mayfly
  
  VERSION = [0,0,1]
  
  class FileNotFoundException < RuntimeError; end
  
  class Log < Logger
    def mayfly_log(msg)
      (@logdev.nil?) ? puts(msg) : info(msg)
    end
  end
  
  class Server 
      
    attr_accessor :config
    
    def initialize(file, port, lives, secure = nil, passwd = nil, verbose = false)
      
      local_variables.each {|v| eval("@#{v}=eval(v)")}
      
      if (!File.exists?(@file)) 
        raise FileNotFoundException, "#{@file} does not exist"
      end
      
      logger.mayfly_log("#{file} will be served #{lives} times from: " +
                        "http#{(secure) ? 's' : ''}://#{local_ip}:#{port}/mayfly/")
    
      logger.mayfly_log("Using HTTP Authentication with the username 'mayfly'" +
                        " and the password you specified") if @passwd

      
      logger.info("Starting mayfly with the following settings: ")
      logger.info("file=#{file}")      
      logger.info("port=#{port}")            
      logger.info("lives=#{lives}")                  
      logger.info("secure=#{secure}")                        
      logger.info("passwd=#{passwd}")
      
       @config = {
          :Port => port,
          :Logger => logger,
          :AccessLog => [[$stdout, "%t Request from %h, response code = %s"]],
        }

        if (secure)

          cert, key = get_cert

          @config.merge!({
            :SSLEnable => true,
            :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
            :SSLCertificate => cert,
            :SSLPrivateKey => key
          })

        end
      
    end
    
    def start
      
      server = WEBrick::HTTPServer.new(@config)
      server.mount('/mayfly', Mayfly::Servlet, @file, @lives, @passwd)

      ['INT', 'TERM'].each { |signal|
         trap(signal){server.shutdown} 
      }

      server.start
      
    end

    # Generate SSL Cert, and hack stderr to not output some ugly crap from webrick
    def get_cert
      old_stderr = $stderr
      $stderr = StringIO.new
      cert, key = WEBrick::Utils.create_self_signed_cert(1024, [["C","GB"], ["O","#{local_ip}"], ["CN", "Mayfly"]], "Generated by Ruby/OpenSSL")
      $stderr = old_stderr
      return cert, key      
    end
    
    def logger
      @logger ||= Log.new((@verbose) ? $stdout : nil, WEBrick::Log::INFO)
    end
    
  end
  
end