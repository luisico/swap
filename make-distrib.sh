#!/bin/sh

version=$1
echo "Packing version ${version:?}"

plugin=swap
dir=$plugin
tar=$plugin-v$version.tgz

cd ../

tar zcvf $tar $dir/pkgIndex.tcl $dir/swap.tcl $dir/index.html $dir/swapbyres.tcl

mv $tar $dir/versions
chmod go+rX $dir/version/$tar
cd $dir

