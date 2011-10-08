require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'
require 'rack/auth/basic'
require 'open-uri'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class RedmineGrackAuth < Rack::Auth::Basic

  def valid?(auth)
    url = $grackConfig[:redmine]
    return false if !url

    creds = *auth.credentials
    user, pass = creds[0, 2]

    identifier = get_project()
    return false if !identifier
    permission = (@req.request_method == "POST" && Regexp.new("(.*?)/git-receive-pack$").match(@req.path_info) ? 'rw' : 'r')

    user = auth.username
    password = auth.credentials[1]
    begin
      open("#{url}/projects/#{identifier}.xml",
           :http_basic_authentication => [user, password]) {}
    rescue OpenURI::HTTPError
      return false
    end

    return true
  end

  def call(env)
    @env = env  
    @req = Rack::Request.new(env)


    return unauthorized if(not defined?($grackConfig))

    auth = Rack::Auth::Basic::Request.new(env)
    return unauthorized unless auth.provided?
    return bad_request unless auth.basic?
    return unauthorized unless valid?(auth)

    env['REMOTE_USER'] = auth.username
    return @app.call(env)
  end

  def get_project
    paths = ["(.*?)/git-upload-pack$", "(.*?)/git-receive-pack$", "(.*?)/info/refs$", "(.*?)/HEAD$", "(.*?)/objects" ]

    suburi = $grackConfig[:grack_suburi] || ''
    paths.each {|re|
      if m = Regexp.new(File.join('/', suburi, re)).match(@req.path)
        identifier = m[1][/([^\/]+)\.git/, 1]
        return (identifier == '' ? nil : identifier)
      end
    }

    return nil
  end

end
