$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')

use Rack::ShowExceptions

require 'lib/git_http'

config = {
  :project_root          => "/home/www/repositories/git",
  :git_path              => '/usr/bin/git',
  :upload_pack           => true,
  :receive_pack          => true,

  :use_redmine_auth      => true,
  :redmine               => 'https://posativ.org/redmine',
  :grack_suburi          => '/git/'
}


$grackConfig = config
if defined?(config[:use_redmine_auth])
	if(config[:use_redmine_auth])
		require 'lib/redmine_grack_auth'
		use RedmineGrackAuth do |user,pass|
			false #dummy code, validation is done in module
		end
	end
end


run GitHttp::App.new(config)
