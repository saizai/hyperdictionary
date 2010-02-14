# This is a modified version from the rubyprof project rubyprof.rubyforge.org
require 'ruby-prof/abstract_printer'
require "erb"

module RubyProf
  # Generates graph[link:files/examples/graph_html.html] profile reports as html. 
  # To use the grap html printer:
  #
	# 	result = RubyProf.profile do
  #			[code to profile]
  #		end
  #
  # 	printer = RubyProf::GraphHtmlPrinter.new(result, 5)
  # 	printer.print(STDOUT, 0)
  #
  # The constructor takes two arguments.  The first is
  # a RubyProf::Result object generated from a profiling
  # run.  The second is the minimum %total (the methods 
  # total time divided by the overall total time) that
  # a method must take for it to be printed out in 
  # the report.  Use this parameter to eliminate methods
  # that are not important to the overall profiling results.
	#  
	#  This is mostly from ruby_forge, with some optimization changes.
  
  class GraphHtmlPrinterEnhanced < AbstractPrinter
  include ERB::Util
    
    MIN_TIME = 0.01
    MIN_THREAD_TIME = 0.0
    PERCENTAGE_WIDTH = 8
    TIME_WIDTH = 10
    CALL_WIDTH = 20
  
    # Create a GraphPrinter.  Result is a RubyProf::Result  
    # object generated from a profiling run.
    def initialize(result)
      super(result)
      @thread_times = Hash.new
      calculate_thread_times
    end

    # Print a graph html report to the provided output.
    # 
    # output - Any IO oject, including STDOUT or a file. 
    # The default value is STDOUT.
    # 
    # options - Hash of print options.  See #setup_options 
    #           for more information.
    #
    def print(output = STDOUT, options = {})
      @output = output
      setup_options(options)
      
      _erbout = @output
      erb = ERB.new(template, nil, nil)
      @output << erb.result(binding)
    end

    # These methods should be private but then ERB doesn't
    # work.  Turn off RDOC though 
    #--
    def calculate_thread_times
      # Cache thread times since this is an expensive
      # operation with the required sorting      
      @result.threads.each do |thread_id, methods|
        top = methods.sort.last
        
        thread_time = 0.01
        thread_time = top.total_time if top.total_time > 0

        @thread_times[thread_id] = thread_time 
      end
    end
    
    def thread_time(thread_id)
      @thread_times[thread_id]
    end

    def select_methods(methods)
      return [] unless methods
      methods.select {|method| method.total_time >= MIN_TIME }
    end

    def select_threads(threads)
      threads.select {|thread_id, methods| thread_time(thread_id) >= MIN_THREAD_TIME }
    end
   
    def total_percent(thread_id, method)
      overall_time = self.thread_time(thread_id)
      (method.total_time/overall_time) * 100
    end
    
    def self_percent(method)
      overall_time = self.thread_time(method.thread_id)
      (method.self_time/overall_time) * 100
    end

    # Creates a link to a method.  Note that we do not create
    # links to methods which are under the min_perecent 
    # specified by the user, since they will not be
    # printed out.
    def create_link(thread_id, method)
      if self.total_percent(thread_id, method) < min_percent
        # Just return name
        h method.full_name
      else
        href = '#' + method_href(thread_id, method)
        "<a href=\"#{href}\">#{h method.full_name}</a>" 
      end
    end
    
    def method_href(thread_id, method)
      h(method.full_name.gsub(/[><#\.\?=:]/,"_") + "_" + thread_id.to_s)
    end
    
    def template
      return IO.read(File.dirname(__FILE__) + "/template.rhtml")
    end
 
  end
end	

