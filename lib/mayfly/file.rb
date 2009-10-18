module Mayfly
  
  class File < File

    @close_callback
    
    def initialize(file, close_callback = nil)
      super file
      @close_callback = close_callback      
    end
    
    def close
      super
      @close_callback.call if @close_callback != nil
    end
    
  end
  
end