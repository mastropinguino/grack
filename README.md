Grack - Ruby/Rack Git Smart-HTTP Server Handler
===============================================

[See original Grack README.md](https://github.com/maxlapshin/grack/blob/master/README.md).

This is a fork to use a really working (yes, really!1) redmine <-> git auth. It
does **not** depend on a redmine counterpart plugin. You need a redmine installation
version 1.1 or higher and need to enable the REST API under *administration* ->
*configuration* -> *authentication* -> *enable REST interface*.

This is my working `config.ru` used at *https://posativ.org/redmine* to get
a url scheme like *https://domain.tld/git/myproject.git*:

    config = {
      :project_root          => "/home/www/repositories/git",
      :git_path              => '/usr/bin/git',
      :upload_pack           => true,
      :receive_pack          => true,

      :use_redmine_auth      => true,
      :redmine               => 'https://posativ.org/redmine',
      :grack_suburi          => '/git/'
    }