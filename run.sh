#!/bin/bash -x

# Turn off ipv6
echo '1' > /proc/sys/net/ipv6/conf/lo/disable_ipv6
echo '1' > /proc/sys/net/ipv6/conf/lo/disable_ipv6
echo '1' > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo '1' > /proc/sys/net/ipv6/conf/default/disable_ipv6

# Check the hostname, it must be puppet for this to work
if [ $(hostname) != "puppet" ];then
  echo
  echo
  echo
  echo "-----------------------------------------"
  echo " YOU MUST SET THE HOSTNAME TO BE 'puppet'"
  echo " docker run -h puppet -t puppetmaster    "
  echo "-----------------------------------------"
  echo
  echo
  echo
  echo
  exit 1
fi

IP_ADDRESS=$(facter ipaddress)
FQDN=$(facter fqdn)

if [[ "${IP_ADDRESS}" ]];then
    IP_ADDRESS=", ${IP_ADDRESS}"
fi


if [[ "${FQDN}" ]];then
    FQDN=", ${FQDN}"
fi

# Slam the IP as a valid CERT name
sed -i "s/dns_alt_names = puppet, localhost/& ${IP_ADDRESS} ${FQDN}/" /etc/puppet/puppet.conf

# delete all the certs generated during the build.
rm -rf /var/lib/puppet/ssl

# Force the puppetmaster to generate some new certs
puppet master --no-daemonize --verbose &
sleep 5
pkill puppet

# Move the certs around -- this was breaking with custom domains from DHCP servers
cp /var/lib/puppet/ssl/certs/puppet*.pem /var/lib/puppet/ssl/certs/puppet.pem
cp /var/lib/puppet/ssl/private_keys/puppet*.pem /var/lib/puppet/ssl/private_keys/puppet.pem

# Enable SSL for puppetdb
puppetdb-ssl-setup
supervisorctl restart puppetdb

# Start all the services
supervisord -c /opt/supervisor.conf -n

# run puppet agent once on the container
puppet agent -t
