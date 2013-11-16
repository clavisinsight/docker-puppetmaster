# Puppetmaster

Creates a Puppet Master running with Apache/Passenger, PuppetDB, Dashboard, and Redis (for Hiera).

Build

```
docker build -t puppetmaster .
```

Example run:

```
CONTAINER_ID=$(docker run -h puppet -d puppetmaster)
chmod 0600 sshkey
PUPPET_SSHPORT=$(docker port $CONTAINER_ID 22)
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