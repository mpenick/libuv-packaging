#!/bin/bash

function check_command {
  command=$1
  package=$2
  if ! type "$command" > /dev/null 2>&1; then
    echo "Missing command '$command', run: yum install $package"
    exit 1
  fi
}

check_command "curl" "curl"
# 'redhat-rpm-config' needs to be installed for the 'debuginfo' package
check_command "rpmbuild" "rpm-build"

if [[ -z $1 ]]; then
  echo "Usage: $0 <version> [<arch>]"
  exit 1
fi
version=$1

arch="x86_64"
if [[ ! -z $2 ]]; then
  arch=$2
fi

release="1"
archive="libuv-v$version.tar.gz"
url="https://github.com/libuv/libuv/archive/v$version.tar.gz"

if [[ -d build ]]; then
  read -p "Build directory exists, remove? [y|n] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf build
  fi
fi
mkdir -p build/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

echo "Downloading $archive"
if [[ ! -f "$archive" ]]; then
  curl -Lf --url "$url" --output "build/SOURCES/$archive"
  if [ $? -ne 0 ]; then
    echo "Unable to download archive from $url"
    exit $?
  fi
fi

echo "Building package:"
cp libuv.pc.in build/SOURCES
echo "* $(date +"%a %b %d %Y") Michael Penick <michael.penick@datastax.com> - $version-1" >> libuv.spec
echo "- release" >> libuv.spec
rpmbuild --target $arch --define "_topdir ${PWD}/build" --define "libuv_version $version" -ba libuv.spec

exit 0
