class puppetlabs::mon0 {
	include puppetlabs::lan

	include ganglia::server

  apache::vhost {'mon0.puppetlabs.lan':
    port => 80,
    docroot => '/var/www',
    ssl => false,
    priority => 10,
    template => 'ganglia/apache.conf.erb',
  }

	file {
		"/usr/local/bin/redmine_gmetric.pl":
			source => "puppet:///modules/puppetlabs/redmine_gmetric.pl",
			owner => root,
			group => root,
			mode => 755;
	}

  cron { # need to source some files here and run under not zach user
    "redmine_gmetrics.pl": 
			command => "/usr/local/bin/redmine_gmetric.pl",
      user => zach,
      minute => "*/5";
    "start_ii.sh":
			command => "~/bin/start_ii.sh",
      user => zach,
      minute => "*/3";
    "ircusers_graph":
			command => '/usr/bin/gmetric -c /etc/ganglia/gmond.conf --name="ircusers" --value=`~/bin/get_irc_users.sh` --type=int16',
      user => zach,
      minute => "*/5";
    "puppet-users-count":
			command => '/usr/bin/gmetric -c /etc/ganglia/gmond.conf --name="puppet-users_count" --value=`wget -q -O - http://groups.google.com/group/puppet-users | grep Members | awk \'{ print $NF }\'` --type=int16',
      user => zach,
      minute => "*/10";
    "puppet-dev-count":
			command => '/usr/bin/gmetric -c /etc/ganglia/gmond.conf --name="puppet-dev-count" --value=`wget -q -O - http://groups.google.com/group/puppet-dev | grep Members | awk \'{ print $NF }\'` --type=int16',
      user => zach,
      minute => "*/10";
    "gd_irc.sh":
			command => '~/bin/gd_irc_csv.sh >> ~/projects/irc/irc_users.csv',
      user => zach,
      minute => "*/10";

  }

}