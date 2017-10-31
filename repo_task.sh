#!/bin/bash

##############################################################################
# Copyright (c) 2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

source /opt/feature_package.conf

mkdir -p /opt/deb
apt-get update

# download EX_DISTRO_PKG of feature
for i in $EX_DISTRO_PKG; do
    apt-get install -y $i -d
done

chmod +x /opt/download_add_pkg.sh
./opt/download_add_pkg.sh

# pre-cache
apt-get -y install git python-apt python-all python-dev curl python2.7-dev build-essential libssl-dev \
libffi-dev netcat python-requests python-openssl python-pyasn1 python-netaddr python-prettytable \
python-crypto python-yaml python-virtualenv python-ndg-httpsclient software-properties-common \
wget python-cheetah nginx -d
find /var/cache/apt/ -name '*.deb' | xargs -i cp {} /opt/deb/

apt-get install -y git wget nginx python-cheetah python-yaml

# add special distro packages
wget -O /opt/deb/gcc-5-base_5.4.0-6ubuntu1~16.04.5_amd64.deb http://launchpadlibrarian.net/336920226/gcc-5-base_5.4.0-6ubuntu1~16.04.5_amd64.deb
wget -O /opt/deb/libstdc++6_5.4.0-6ubuntu1~16.04.5_amd64.deb http://launchpadlibrarian.net/336920453/libstdc++6_5.4.0-6ubuntu1~16.04.5_amd64.deb
wget -O /opt/deb/libarchive13_3.1.2-11ubuntu0.16.04.3_amd64.deb http://launchpadlibrarian.net/310274057/libarchive13_3.1.2-11ubuntu0.16.04.3_amd64.deb
wget -O /opt/deb/libc6_2.23-0ubuntu9_amd64.deb http://launchpadlibrarian.net/324305509/libc6_2.23-0ubuntu9_amd64.deb
wget -O /opt/deb/libkmod2_22-1ubuntu5_amd64.deb http://launchpadlibrarian.net/330554478/libkmod2_22-1ubuntu5_amd64.deb


# add roles
wget -O /opt/roles.tar.gz http://artifacts.opnfv.org/compass4nfv/package/master/roles.tar.gz
mkdir -p /etc/ansible
tar -zxf /opt/roles.tar.gz -C /etc/ansible/

# generate the script for downloading packages
python /opt/gen_download_pkg_script.py "/etc/ansible/roles" "ubuntu" "/opt/package_name.yml" \
"/opt/download_packages.tmpl"

chmod +x /opt/download_packages.sh

# download packages
./opt/download_packages.sh

# get lxc image
wget -O /var/www/html/download.tar.gz http://artifacts.opnfv.org/compass4nfv/package/master/download.tar.gz

# add pip cache of OSA
wget -O /var/www/html/pip_pkg.tar.gz http://artifacts.opnfv.org/compass4nfv/package/master/pip_pkg.tar.gz
tar -zxf /var/www/html/pip_pkg.tar.gz -C /var/www/html/

# download EXT_DISTRO_URL of feature
for i in $EXT_DISTRO_URL; do
    if [[ -n $i ]]; then
        name=`basename $i`
        wget -O /var/www/html/$name $i
    fi
done

# download EXT_PIP_PKG
for i in $EXT_PIP_PKG; do
    if [[ -n $i ]]; then
        pip install $i -d /var/www/html/pip_pkg/
    fi
done

# download EXT_PIP_URL
for i in $EXT_PIP_URL; do
    if [[ -n $i ]]; then
        name=`basename $i`
        wget -O /var/www/html/pip_pkg/$name $i
    fi
done

# add some special package
wget -O /var/www/html/rabbitmq-server_3.6.9-1_all.deb http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.9/rabbitmq-server_3.6.9-1_all.deb
wget -O /var/www/html/percona-xtrabackup-24_2.4.5-1.xenial_amd64.deb https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.5/binary/debian/xenial/x86_64/percona-xtrabackup-24_2.4.5-1.xenial_amd64.deb
wget -O /var/www/html/qpress_11-1.xenial_amd64.deb https://repo.percona.com/apt/pool/main/q/qpress/qpress_11-1.xenial_amd64.deb
wget -O /var/www/html/hatop-0.7.7.tar.gz https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/hatop/hatop-0.7.7.tar.gz
wget -O /var/www/html/get-pip.py https://bootstrap.pypa.io/get-pip.py
wget -O /var/www/html/upper-constraints.txt https://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt?id=90094c5d578ecfc4ab1e9f38a86bca5b615a3527

# generate simple
apt install -y python-pip
pip install pip2pi
dir2pi /var/www/html/pip_pkg

# clear the cache
apt-get clean
rm -rf /opt/roles.tar.gz
rm -rf /etc/ansible/roles
rm -rf /opt/deb
rm -rf /opt/osa
rm -rf /opt/feature
rm -rf /var/www/html/pip_pkg.tar.gz
