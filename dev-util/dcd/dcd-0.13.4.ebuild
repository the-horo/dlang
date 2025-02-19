# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Auto-complete program for the D programming language"
HOMEPAGE="https://github.com/dlang-community/DCD"
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="amd64 x86"
IUSE="systemd"

CONTAINERS="fc1625a5a0c253272b80addfb4107928495fd647"
DSYMBOL="f9a3d302527a9e50140991562648a147b6f5a78e"
LIBDPARSE="1393ee4d0c8e50011e641e06d64c429841fb3c2b"
MSGPACK="480f3bf9ee80ccf6695ed900cfcc1850ba8da991"
ALLOCATOR="d6e6ce4a838e0dad43ef13f050f96627339cdccd"
SRC_URI="
	https://github.com/dlang-community/DCD/archive/v${PV}.tar.gz -> DCD-${PV}.tar.gz
	https://github.com/economicmodeling/containers/archive/${CONTAINERS}.tar.gz -> containers-${CONTAINERS}.tar.gz
	https://github.com/dlang-community/dsymbol/archive/${DSYMBOL}.tar.gz -> dsymbol-${DSYMBOL}.tar.gz
	https://github.com/dlang-community/libdparse/archive/${LIBDPARSE}.tar.gz -> libdparse-${LIBDPARSE}.tar.gz
	https://github.com/dlang-community/stdx-allocator/archive/${ALLOCATOR}.tar.gz -> stdx-allocator-${ALLOCATOR}.tar.gz
	https://github.com/msgpack/msgpack-d/archive/${MSGPACK}.tar.gz -> msgpack-d-${MSGPACK}.tar.gz
	"
S="${WORKDIR}/DCD-${PV}"

DLANG_VERSION_RANGE="2.082-2.100"
DLANG_PACKAGE_TYPE="single"

inherit dlang systemd bash-completion-r1

src_prepare() {
	# Default ebuild unpack function places archives side-by-side ...
	mv -T ../stdx-allocator-${ALLOCATOR} stdx-allocator/source || die
	mv -T ../containers-${CONTAINERS}    containers            || die
	mv -T ../dsymbol-${DSYMBOL}          dsymbol               || die
	mv -T ../libdparse-${LIBDPARSE}      libdparse             || die
	mv -T ../msgpack-d-${MSGPACK}        msgpack-d             || die
	# Stop makefile from executing git to write an unused githash.txt
	echo "v${PV}" > githash.txt || die "Could not generate githash"
	touch githash || die "Could not generate githash"
	# Apply patches
	dlang_src_prepare
}

d_src_compile() {
	# Build client & server with the requested Dlang compiler
	local flags="$DCFLAGS $LDFLAGS -Icontainers/src -Idsymbol/src -Ilibdparse/src -Imsgpack-d/src -Isrc -J."
	case "$DLANG_VENDOR" in
	DigitalMars)
		emake \
			DMD="$DC" \
			DMD_CLIENT_FLAGS="$flags -ofbin/dcd-client" \
			DMD_SERVER_FLAGS="$flags -ofbin/dcd-server" \
			dmd
		;;
	GNU)
		emake \
			GDC="$DC" \
			GDC_CLIENT_FLAGS="$flags -obin/dcd-client" \
			GDC_SERVER_FLAGS="$flags -obin/dcd-server" \
			gdc
		;;
	LDC)
		mkdir -p bin || die "Could not create 'bin' output directory."
		emake \
			LDC="$DC" \
			LDC_CLIENT_FLAGS="$flags -g -of=bin/dcd-client" \
			LDC_SERVER_FLAGS="$flags" \
			ldc
		;;
	*)
		die "Unsupported compiler vendor: $DLANG_VENDOR"
		;;
	esac
	# Write system include paths of host compiler into dcd.conf
	dlang_system_imports > dcd.conf
}

d_src_test() {
	# The tests don't work too well in a sandbox, e.g. multiple permission denied errors.
	cd tests
	#./run_tests.sh || die "Tests failed"
}

d_src_install() {
	dobin bin/dcd-server
	dobin bin/dcd-client
	use systemd && systemd_douserunit "${FILESDIR}"/dcd-server.service
	dobashcomp bash-completion/completions/dcd-server
	dobashcomp bash-completion/completions/dcd-client
	insinto /etc
	doins dcd.conf
	dodoc README.md
	doman man1/dcd-client.1 man1/dcd-server.1
}

pkg_postinst() {
	use systemd && elog "A systemd user service for 'dcd-server' has been installed."
}
