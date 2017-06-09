#!/bin/bash
##############################################################################
# Copyright (c) 2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

export ADD_PKG="tcpdump"

export ADD_SPE_PKG=""

for i in $ADD_PKG; do
    apt-get install -y $i -d
done

for j in $ADD_SPE_PKG; do
    name=`basename $j`
    wget -O /var/cache/apt/$name $j
done