# Puppetmaster

Creates a Puppet Master running with Apache/Passenger, PuppetDB, Dashboard, and Redis (for Hiera).

What is this ?
--------------

This is a self-contained puppetmaster used for testing and education.

Whats inside ?
--------------

Everything is kept up-to-date during a build.
The last time i refreshed mine, I got the following versions...

* ubuntu 12.04 LTS
* facter 1.7.4
* hiera 1.3.1
* puppet 3.4.2
* puppetdb 1.6.2
* puppet-dashboard 1.2.23
* mysql-server 5.5.22


How do i play use it ?
----------------------

Build

```
docker build -t puppetmaster .
```

Example run:

```
CONTAINER_ID=$(docker run -h puppet -P -d puppetmaster)
chmod 0600 sshkey
PUPPET_SSHPORT=$(docker port $CONTAINER_ID 22 | cut -d: -f2)
ssh -i sshkey -p $PUPPET_SSHPORT root@localhost
```

Note: 
 The `sshkey` and `sshkey.pub` are just for example. 
 Replace with your own before using. 
 These are used to access the SSH daemon on the container.

 Once you generate new ssh keys, then you need to rebuild the container.

```
ssh-keygen -f sshkey
```

Note: you can trigger the puppetmaster to run the puppet agent is...

```
puppet agent -t`
```

Ports:
------

* 22 (ssh)
* 8140 (puppet - SSL)
* 8080 (puppetdb - HTTP)
* 8081 (puppetdb - HTTPS)
* 3000 (dashboard - HTTP)
