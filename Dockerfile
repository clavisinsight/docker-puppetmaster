FROM ubuntu:12.04
# FORKED FROM Arcus "http://arcus.io"
MAINTAINER "Artur Martins <artur.martins@clavisinsight.com>"
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe multiverse" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y wget apt-utils aptitude dialog ruby rubygems 
RUN wget -q http://apt.puppetlabs.com/puppetlabs-release-precise.deb -O /tmp/puppetlabs.deb
RUN dpkg -i /tmp/puppetlabs.deb
RUN aptitude update
RUN aptitude -y install puppetmaster-passenger puppet-dashboard puppetdb puppetdb-terminus redis-server supervisor openssh-server net-tools mysql-server
RUN gem install --no-ri --no-rdoc hiera hiera-puppet redis hiera-redis hiera-redis-backend
RUN apt-get install python-dev python python-pip git uwsgi -y
RUN git clone https://github.com/nedap/puppetboard \
 && cd /puppetboard \
 && pip install -r requirements.txt

RUN mkdir /var/run/sshd
ADD puppetmaster.apache_conf /etc/apache2/sites-available/puppetmaster
ADD supervisor.conf /opt/supervisor.conf
ADD auth.conf /etc/puppet/auth.conf
ADD puppet.conf /etc/puppet/puppet.conf
ADD puppetdb.conf /etc/puppet/puppetdb.conf
ADD jetty.ini /etc/puppetdb/conf.d/jetty.ini
ADD routes.yaml /etc/puppet/routes.yaml
ADD hiera.yaml /etc/hiera.yaml
ADD hiera.yaml /etc/puppet/hiera.yaml
ADD hiera-common.yaml /etc/puppet/hiera/common.yaml
ADD autosign.conf /etc/puppet/autosign.conf
ADD puppetboard-default_settings.py /puppetboard/puppetboard/default_settings.py

RUN (start-stop-daemon --start -b --exec /usr/sbin/mysqld && sleep 5 ; echo "create database dashboard character set utf8;" | mysql -u root)
RUN (start-stop-daemon --start -b --exec /usr/sbin/mysqld && sleep 5 ; echo "create user dashboard@'localhost' identified by '1q2w3e4r5t';" | mysql -u root)
RUN (start-stop-daemon --start -b --exec /usr/sbin/mysqld && sleep 5 ; echo "grant all on dashboard.* to dashboard@'%';" | mysql -u root)
ADD database.yml /usr/share/puppet-dashboard/config/database.yml
RUN (start-stop-daemon --start -b --exec /usr/sbin/mysqld && cd /usr/share/puppet-dashboard && RAILS_ENV=production rake db:migrate)
RUN (sed -i 's/.*START.*/START=yes/g' /etc/default/puppet-dashboard)
RUN (sed -i 's/.*START.*/START=yes/g' /etc/default/puppet-dashboard-workers)

RUN mkdir -p /etc/puppet/environments/default
RUN mkdir -p /var/puppet.git
RUN cd /var/puppet.git && git --bare init
ADD post-receive /var/puppet.git/hooks/post-receive
RUN chmod a+x /var/puppet.git/hooks/post-receive

RUN mkdir /root/.ssh
# NOTE: change this key to your own
ADD sshkey.pub /root/.ssh/authorized_keys
RUN chown root:root /root/.ssh/authorized_keys
ADD run.sh /usr/local/bin/run

EXPOSE 22 3000 8080 8081 8140 9090
CMD ["/usr/local/bin/run"]
