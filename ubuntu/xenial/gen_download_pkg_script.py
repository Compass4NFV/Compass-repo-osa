##############################################################################
# Copyright (c) 2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import yaml
import os
import sys
from Cheetah.Template import Template

def get_packages_name_list(root, arch, yml_name):
    pkg_names = []

    datas = yaml.load(open(yml_name))

    for key_role, value in datas.items():
        var_dir = ""
        if key_role in ['ceph.ceph-common']: # hard code, to be corrected
            var_dir = os.path.join(root, key_role, 'defaults')
        else:
            var_dir = os.path.join(root, key_role, 'vars')

        pkg_vars = []

        for i in value:
            for key_arch, _value in i.items():
                if key_arch == arch:
                    if _value.get('packages'):
                        for j in _value.get('packages'):
                            pkg_vars.append(j)

                    if _value.get('name'):
                        var_path = os.path.join(var_dir, _value.get('name'))
                        for j in _get_packages_name_list(var_path, pkg_vars):
                            if j not in pkg_names:
                                pkg_names.append(j)

    return pkg_names

def _get_packages_name_list(path, var):
    datas = yaml.load(open(path))
    packages = []
    for i in var:
        pkgs = datas.get(i)
        if not isinstance(pkgs, list):
            pkgs = [pkgs]
        for j in pkgs:
            if isinstance(j, dict):
                for key, value in j.items():
                    if value == "absent":
                        break
                    if key.endswith("packages"):
                        for k in value:
                            if k.endswith("}"):
                                continue
                            if k not in packages:
                               packages.append(k)

            else:
                if j.endswith("}"):
                    continue
                if j not in packages:
                    packages.append(j)
    return packages

def generate_download_script(ansible_root="", arch="", yml_path="", tmpl=""): # Shall add special packages handling?
    packages_name = get_packages_name_list(ansible_root, arch, yml_path)
    tmpl = Template(
        file=tmpl,
        searchList={
            'packages': packages_name})
    with open('/opt/download_packages.sh', 'w') as f:
        f.write(tmpl.respond())


if __name__ == '__main__':
        generate_download_script(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])