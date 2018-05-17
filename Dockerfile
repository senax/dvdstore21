#
# vim: bg=dark
# http://en.community.dell.com/techcenter/extras/w/wiki/dvd-store
#
# docker run --rm --name mysql -e MYSQL_ROOT_PASSWORD=root  -e MYSQL_ROOT_HOST='%' -e MYSQL_USER=web -e MYSQL_PASSWORD=web -p 3306:3306 mysql/mysql-server:5.7

# docker run --rm -ti --network=host --name dvdstore dvdstore21:latest bash
# docker run --rm -ti --network=host --name dvdstore dvdstore21:latest setup
# docker run --rm -ti --network=host --name dvdstore dvdstore21:latest bench
# docker run --rm -ti --network=host -e THREADS=1 --name dvdstore dvdstore21:latest


FROM centos:centos7

MAINTAINER frank@crystalconsulting.eu

RUN yum -y install epel-release; yum -y install git mariadb wget unzip

RUN cd /root; git clone https://github.com/senax/ds21.git

RUN rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" ; \
curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo ; \
yum -y install mono-core
#yum -y install mono-devel

RUN cd /root/ds21/ds2 && \
wget https://dev.mysql.com/get/Downloads/Connector-Net/mysql-connector-net-6.9.12-noinstall.zip && \
unzip -x mysql-connector-net-6.9.12-noinstall.zip && \
rm -f mysql-connector-net-6.9.12-noinstall.zip && \
gacutil /i v4.5/MySql.Data.dll && \
mcs -out:drivers/my_ds2xdriver.exe drivers/ds2xdriver.cs mysqlds2/ds2mysqlfns.cs -r:/usr/lib/mono/4.5/System.Data.dll,v4.5/MySql.Data.dll

ADD scripts/setup /usr/local/bin/setup
ADD scripts/bench /usr/local/bin/bench

RUN chmod +x /usr/local/bin/setup /usr/local/bin/bench

RUN yum -y remove git wget unzip && yum clean all && rm -rf /var/cache/yum

ENV STAGE=bench
ENV SIZE=1
ENV SIZE_UNIT=GB
ENV THREADS=2
ENV THINK=0
ENV MYSQL_HOST=127.0.0.1

# CMD ["/usr/local/bin/setup"]
CMD ["/usr/local/bin/bench"]
