require 'test/unit'
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test_help'
require 'pp'

module ActionController
	class TestRequest
		alias_method :params, :parameters unless respond_to? :params
	end
end

class SlowController < ActionController::Base
	def profile_me
		sleep 1
		render :text => "slow action"
	end
end

class BrowserProfilerTest <  Test::Unit::TestCase
	def setup
		@controller = SlowController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_no_impact_without_request_param
		get :profile_me, :params => {}
		assert_response :success
		assert_equal "slow action", @response.body
	end

	def no_test_profile_param_adds_profile

		get :profile_me, :params => {"browser_profile!" => ""}
		assert_response :success

		assert profiled?(@response.body)

	end

	def no_test_profile_output_to_file

		clean_outfile

		get :profile_me, :params => {"file_profile!" => ""}
		assert_response :success

		assert ! profiled?(@response.body)
		assert File.exists?(profile_out_file)
		assert profiled?(File.read(profile_out_file))

		clean_outfile

	end


	private 

	def clean_outfile
		FileUtils.rm_rf(profile_out_file)
	end

	def profiled?(body)
		pp body
		(body =~ /browser_profile/) && (body =~ /Profile Report/)
	end

	def profile_out_file
		"#{RAILS_ROOT}/log/profile_out.html"
	end

end
