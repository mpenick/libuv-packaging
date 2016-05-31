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
url="http://dist.libuv.org/v$version/$archive"

if [[ -d build ]]; then
  read -p "Build directory exists, remove? [y|n] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf build
  fi
fi
mkdir -p build/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

echo "Downloading $archive"
cp libuv.pc.in build/SOURCES
if [[ ! -f "$archive" ]]; then
  curl -L --url "$url" --output "build/SOURCES/$archive"
fi

echo "Building package:"
rpmbuild --target $arch --define "_topdir ${PWD}/build" --define "libuv_version $version" -ba libuv.spec

exit 0
