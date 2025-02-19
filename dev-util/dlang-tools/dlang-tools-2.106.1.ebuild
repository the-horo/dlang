# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Ancilliary tools for the D programming language compiler"
HOMEPAGE="http://dlang.org/"
LICENSE="Boost-1.0"

SLOT="0"
KEYWORDS="~amd64 ~x86"
TOOLS="ddemangle detab dustmite rdmd"
IUSE="+ddemangle detab dustmite +rdmd"
REQUIRED_USE="|| ( ${TOOLS} )"

DLANG_SLOT="$(ver_cut 1-2)"
RESTRICT="mirror"

BETA="$(ver_cut 4)"
VERSION="$(ver_cut 1-3)"

if [[ -n "${BETA}" ]]; then
	# We want to convert a Gentoo version string into an upstream one: 2.097.0_rc1 -> 2.097.0-rc.1
	VERSION="$(ver_rs 3 "-" 4 ".")"
fi
SRC_URI="https://codeload.github.com/dlang/tools/tar.gz/v${VERSION} -> dlang-tools-${VERSION}.tar.gz"

DLANG_VERSION_RANGE="2.075-"
DLANG_PACKAGE_TYPE="single"

inherit desktop dlang xdg-utils

S="${WORKDIR}/tools-${VERSION}"

d_src_compile() {
	use ddemangle && dlang_compile_bin ddemangle ddemangle.d
	use detab     && dlang_compile_bin detab     detab.d
	use dustmite  && dlang_compile_bin dustmite  DustMite/dustmite.d DustMite/splitter.d DustMite/polyhash.d
	use rdmd      && dlang_compile_bin rdmd      rdmd.d
}

d_src_install() {
	for tool in ${TOOLS}; do
		if use "${tool}"; then
			dobin "${tool}"
		fi
	done

	# file icons
	for size in 16 22 24 32 48 256; do
		newicon --size "${size}" --context mimetypes "${FILESDIR}/icons/${size}/dmd-source.png" text-x-dsrc.png
	done
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
