module ActionController
  class Base
    def process_with_browser_profiling(request, response, method = :perform_action, *arguments)
      browser_output = request.parameters.key?('browser_profile!') || ENV["BROWSER_PROFILE"]
      file_output = request.parameters.key?('file_profile!') || ENV["FILE_PROFILE"]
      if (browser_output or file_output)
        #Only require these files in needed
        require 'ruby-prof'
        require 'ruby-prof/graph_html_printer_enhanced'

        #run the process through a profile block
        profile_results = RubyProf.profile { 
          response = process_without_browser_profiling(request,response, method, *arguments); 
        }

        #Use the enhanced html printer to get better results
        printer = RubyProf::GraphHtmlPrinterEnhanced.new(profile_results)

        #determine output location
        if file_output
          printer.print(File.new("#{RAILS_ROOT}/log/profile_out.html","w"))
        else
          response.body << printer.print("",0)
        end 
        
        #reset the content length so the profiling data is included in the response
        response.send("set_content_length!")
        
        
        response 
      else
        process_without_browser_profiling(request, response, method, *arguments)   
      end
    end
    alias_method_chain :process, :browser_profiling
  end
end
