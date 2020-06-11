#!/bin/bash
echo ADA_TARGET=gnat_2019 >> /etc/portage/make.conf
echo FEATURES=buildpkg >> /etc/portage/make.conf
sed -i -e '/PKGDIR=/s@=.*@="/github/home/binpkgs"@' /etc/portage/make.conf
mkdir -p /github/home/binpkgs
emerge --usepkg dev-ada/gprbuild
eselect gcc set x86_64-pc-linux-gnu-8.3.1
. /etc/profile

mkdir -p /etc/portage/repos.conf
cat << EOF > /etc/portage/repos.conf/ada-overlay.conf
[ada-overlay]
location = /github/workspace
EOF

cat << EOF >/etc/portage/package.accept_keywords 
=dev-ada/matreshka-20.1 ~amd64
EOF

emerge $*