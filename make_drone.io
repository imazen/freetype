#!/bin/bash
# set $1 to 1 to force an x86 build

_build()
{
  echo "*building* (x86=${1-0})"
  
  pack="*.a *.so*"
  cmargs="-DCMAKE_C_FLAGS=-fPIC"
  [ ${1-0} -gt 0 ] && cmargs="$cmargs -DCMAKE_C_FLAGS=-m32"
  
  cmake -G "Unix Makefiles" $cmargs
  make
  ctest .
  objdump -f *.so | grep ^architecture
  ldd *.so
  find . -maxdepth 1 -type l -exec rm -f {} \;
  tar -zcf binaries.tar.gz $pack
}


_clean()
{
  echo "*cleaning*"
  git clean -ffde /out > /dev/null
  git reset --hard > /dev/null
}

mkdir out

_build
mv binaries.tar.gz out/libfreetype-x64.tar.gz
_clean

sudo apt-get -y update > /dev/null
sudo apt-get -y install gcc-multilib > /dev/null

_build 1
mv binaries.tar.gz out/libfreetype-x86.tar.gz
_clean
