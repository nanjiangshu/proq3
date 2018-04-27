#!/bin/bash
# Install Rosetta package for ProQ3
# Author: Nanjiang Shu (nanjiang.shu@scilifelab.se)

set -e

usage="
USAGE: $0 INSTALL_PATH PASSWORD
"

if [ $# -lt 2 ];then
    echo "$usage"
    exit 1
fi

INSTALL_PATH=$1
PASSWORD=$2

INSTALL_PATH=`readlink -f $INSTALL_PATH`

if [ "$PASSWORD" == "" ];then
    echo "You need to obtain a valid password for downloading the Rosetta package"
    echo "through https://www.rosettacommons.org/software/license-and-download"
fi

if [ ! -d "$INSTALL_PATH" ];then
    mkdir -p $INSTALL_PATH
fi


echo "The Rosetta package will be installed at $INSTALL_PATH ..."

pushd "$INSTALL_PATH"

url=https://www.rosettacommons.org/downloads/academic/2016/wk15/rosetta_bin_linux_2016.15.58628_bundle.tgz

filename=$(basename $url)

wget --user Academic_User --password $PASSWORD  $url -O $filename

tar -xzf $filename

foldername=$(basename $filename .tgz)

pushd $foldername/main/source/; ./scons.py bin mode=release ; popd

rm -f  $filename

echo "Installation completed!"

popd
