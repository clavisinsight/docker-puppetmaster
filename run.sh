#!/bin/sh

# Turn off ipv6
echo '1' > /proc/sys/net/ipv6/conf/lo/disable_ipv6  
echo '1' > /proc/sys/net/ipv6/conf/lo/disable_ipv6  
echo '1' > /proc/sys/net/ipv6/conf/all/disable_ipv6  
echo '1' > /proc/sys/net/ipv6/conf/default/disable_ipv6

# Force the hostname to be puppet
hostname puppet

# delete all the certs generated during the build.
rm -rf /var/lib/puppet/ssl

# Force the puppetmaster to generate some new certs
puppet master --no-daemonize --verbose &
sleep 5
pkill puppet

# Enable SSL for puppetdb
puppetdb-ssl-setup
supervisorctl restart puppetdb

# Start all the services
supervisord -c /opt/supervisor.conf -n

# run puppet agent once on the container
puppet agent -t
