#!/bin/sh

SRCDIR="/vagrant/puppet/environments"
DSTDIR="/etc/puppet/environments"
ENV="production"

rm -rf $DSTDIR/$ENV/hieradata
rm -rf $DSTDIR/$ENV/manifests
rm -rf $DSTDIR/$ENV/modules

if [ ! -d $DSTDIR ]; then
  mkdir $DSTDIR
fi

cp -rp $SRCDIR/$ENV $DSTDIR/

chown -R puppet:puppet $DSTDIR/$ENV/hieradata
chown -R puppet:puppet $DSTDIR/$ENV/manifests
chown -R puppet:puppet $DSTDIR/$ENV/modules
