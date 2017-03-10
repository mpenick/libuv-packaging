Name:    libuv
Epoch:   1
Version: %{libuv_version}
Release: 1%{?dist}
Summary: Cross-platform asychronous I/O 

Group: Development/Tools
License: MIT, BSD and ISC
URL: http://http://libuv.org/
Source0: %{name}-v%{version}.tar.gz
Source1: libuv.pc.in

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: autoconf >= 2.59
BuildRequires: automake >= 1.9.6
BuildRequires: libtool >= 1.5.22
Requires(post): /sbin/ldconfig
Requires(postun): /sbin/ldconfig

%description
A multi-platform support library with a focus on asynchronous I/O. It was primarily developed for use by Node.js, but it’s also used by Luvit, Julia, pyuv, and others.

%package devel
Summary: Development libraries for libuv
Group: Development/Tools
Requires: %{name} = %{epoch}:%{version}-%{release}
Requires: pkgconfig
Requires(post): /sbin/ldconfig
Requires(postun): /sbin/ldconfig

%description devel
Development libraries for libuv

%prep
%setup -qn %{name}-%{version}

%build
export CFLAGS='%{optflags}'
export CXXFLAGS='%{optflags}'
sh autogen.sh
%configure
make %{?_smp_mflags}

%install
rm -rf %{buildroot}
make DESTDIR=%{buildroot} install

mkdir -p %{buildroot}/%{_libdir}/pkgconfig
sed -e "s#@prefix@#%{_prefix}#g" \
    -e "s#@exec_prefix@#%{_exec_prefix}#g" \
    -e "s#@libdir@#%{_libdir}#g" \
    -e "s#@includedir@#%{_includedir}#g" \
    -e "s#@version@#%{version}#g" \
    %SOURCE1 > %{buildroot}/%{_libdir}/pkgconfig/libuv.pc

%clean
rm -rf %{buildroot}

%check
# make check

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files
%defattr(-,root,root)
%doc README.md AUTHORS LICENSE
%{_libdir}/*.so
%{_libdir}/*.so.*

%files devel
%defattr(-,root,root)
%doc README.md AUTHORS LICENSE
%{_includedir}/*.h
%{_libdir}/*.a
%{_libdir}/*.la
%{_libdir}/pkgconfig/*.pc

%changelog
