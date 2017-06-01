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
RUN apt-get -y install git python-all python-dev curl python2.7-dev build-essential libssl-dev \
libffi-dev netcat python-requests python-openssl python-pyasn1 python-netaddr python-prettytable \
python-crypto python-yaml python-virtualenv python-ndg-httpsclient software-properties-common \
wget python-cheetah nginx -d
RUN mkdir -p /opt/deb
RUN find /var/cache/apt/ -name '*.deb' | xargs -i cp {} /opt/deb/

RUN apt-get install -y git wget nginx python-cheetah

# get download scripts
RUN git clone https://github.com/Justin-chi/compass-tasks-osa.git /opt/compass-tasks-osa
RUN mkdir -p /opt/git
RUN cp /opt/compass-tasks-osa/* /opt/git/
RUN /opt/git/run.sh

# copy openstack git to nginx directory
RUN tar -zcf openstack_git.tar.gz -C /opt/git/ openstack
RUN mv openstack_git.tar.gz /var/www/html/

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

# clear the cache
RUN apt-get clean
RUN rm -rf /etc/ansible/roles
RUN rm -rf /opt/git
RUN rm -rf /opt/deb

# Expose ports.
EXPOSE 80
EXPOSE 443

# Define default command.
CMD ["nginx", "-g", "daemon off;"]