FROM debian:jessie

RUN apt-get update

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

ENV MYSQL_ROOT_PASSWORD password

#RUN bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"'
#RUN bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"'

RUN apt-get install mysql-server mysql-client -y

RUN apt-get install pwgen unzip rsyslog openjdk-7-jdk  git less supervisor -y

ENV PLAY_VERSION 2.2.6
ENV PATH $PATH:/opt/play-$PLAY_VERSION

ADD http://downloads.typesafe.com/play/$PLAY_VERSION/play-$PLAY_VERSION.zip /tmp/play-$PLAY_VERSION.zip
RUN (cd /opt && unzip /tmp/play-$PLAY_VERSION.zip && rm -f /tmp/play-$PLAY_VERSION.zip)

RUN (cd /opt && git clone https://github.com/IT2901PhysicalActivity/Sintef-PushMe.git)

RUN (cd /opt/Sintef-PushMe/PushMe  && play clean stage)


RUN mkdir -p /var/log/supervisor

# Add image configuration and scripts
ADD start-mysqld.sh /start-mysqld.sh
ADD start-play.sh /start-play.sh
ADD run.sh /run.sh
ADD supervisord-play.conf /etc/supervisor/conf.d/supervisord-play.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

ADD config_mysql.sh /config_mysql.sh

RUN chmod 755 /*.sh

RUN apt-get install vim -y
# you should map the volume yourself VOLUME  ["/home/thomasv/apps/pushme/mysql", "/var/lib/mysql" ]


CMD /run.sh 
 
