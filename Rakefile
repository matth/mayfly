task :generate_site do
  
  require 'rubygems'
  require 'rdoc/markup/to_html'
 
  def get_file_as_string(filename)
    data = ''
    f = File.open(File.expand_path(filename), "r") 
    f.each_line do |line|
      data += line
    end
    return data
  end
 
  def string_replace(search, replace, filename)
    file = File.open(File.expand_path(filename), "r")
    aString = file.read
    file.close
    aString.gsub!(search, replace)
    File.open(filename, "w") {|file| file << aString}
  end
  
  h = RDoc::Markup::ToHtml.new
  html_str = h.convert(get_file_as_string('README.rdoc'))
  
  string_replace('GENERATED_CONTENT', html_str, 'index.html')
    
end