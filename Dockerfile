##############################################################################
# Copyright (c) 2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

FROM ubuntu:16.04
MAINTAINER Yifei Xue <xueyifei@huawei.com>

RUN apt-get update

# add additional packages
ADD ./download_add_pkg.sh /opt/download_add_pkg.sh
RUN chmod +x /opt/download_add_pkg.sh
RUN /opt/download_add_pkg.sh

# pre-cache
RUN apt-get -y install git python-apt python-all python-dev curl python2.7-dev build-essential libssl-dev \
libffi-dev netcat python-requests python-openssl python-pyasn1 python-netaddr python-prettytable \
python-crypto python-yaml python-virtualenv python-ndg-httpsclient software-properties-common \
wget python-cheetah nginx -d
RUN mkdir -p /opt/deb
RUN find /var/cache/apt/ -name '*.deb' | xargs -i cp {} /opt/deb/

RUN apt-get install -y git wget nginx python-cheetah python-yaml

# add special distro packages
RUN wget -O /opt/deb/gcc-5-base_5.4.0-6ubuntu1~16.04.4_amd64.deb http://launchpadlibrarian.net/291946892/gcc-5-base_5.4.0-6ubuntu1~16.04.4_amd64.deb
RUN wget -O /opt/deb/libstdc++6_5.4.0-6ubuntu1~16.04.4_amd64.deb http://launchpadlibrarian.net/291947015/libstdc++6_5.4.0-6ubuntu1~16.04.4_amd64.deb
RUN wget -O /opt/deb/libarchive13_3.1.2-11ubuntu0.16.04.3_amd64.deb http://launchpadlibrarian.net/310274057/libarchive13_3.1.2-11ubuntu0.16.04.3_amd64.deb

# add roles
RUN wget -O /opt/roles.tar.gz http://artifacts.opnfv.org/compass4nfv/package/master/roles.tar.gz
RUN mkdir -p /etc/ansible
RUN tar -zxf /opt/roles.tar.gz -C /etc/ansible/

# ADD files
ADD ./gen_download_pkg_script.py /opt/gen_download_pkg_script.py
ADD ./package_name.yml /opt/package_name.yml
ADD ./download_packages.tmpl /opt/download_packages.tmpl

# generate the script for downloading packages
RUN python /opt/gen_download_pkg_script.py "/etc/ansible/roles" "ubuntu" "/opt/package_name.yml" \
"/opt/download_packages.tmpl"

RUN chmod +x /opt/download_packages.sh

# download packages
RUN /opt/download_packages.sh

# get lxc image
RUN wget -O /var/www/html/download.tar.gz http://artifacts.opnfv.org/compass4nfv/package/master/download.tar.gz 

# add pip cache of OSA
RUN wget -O /var/www/html/pip_pkg.tar.gz http://artifacts.opnfv.org/compass4nfv/package/master/pip_pkg.tar.gz
RUN tar -zxf /var/www/html/pip_pkg.tar.gz -C /var/www/html/

# add some special package
RUN wget -O /var/www/html/rabbitmq-server_3.6.9-1_all.deb http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.9/rabbitmq-server_3.6.9-1_all.deb
RUN wget -O /var/www/html/percona-xtrabackup-24_2.4.5-1.xenial_amd64.deb https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.5/binary/debian/xenial/x86_64/percona-xtrabackup-24_2.4.5-1.xenial_amd64.deb
RUN wget -O /var/www/html/qpress_11-1.xenial_amd64.deb https://repo.percona.com/apt/pool/main/q/qpress/qpress_11-1.xenial_amd64.deb
RUN wget -O /var/www/html/hatop-0.7.7.tar.gz https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/hatop/hatop-0.7.7.tar.gz
RUN wget -O /var/www/html/get-pip.py https://bootstrap.pypa.io/get-pip.py
RUN wget -O /var/www/html/upper-constraints.txt https://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt?id=90094c5d578ecfc4ab1e9f38a86bca5b615a3527

# generate simple
RUN apt install -y python-pip
RUN pip install pip2pi
RUN dir2pi /var/www/html/pip_pkg

# clear the cache
RUN apt-get clean
RUN rm -rf /opt/roles.tar.gz
RUN rm -rf /etc/ansible/roles
RUN rm -rf /opt/deb
RUN rm -rf /opt/osa
RUN rm -rf /var/www/html/pip_pkg.tar.gz

# Expose ports.
EXPOSE 80
EXPOSE 443

# Define default command.
CMD ["nginx", "-g", "daemon off;"]
