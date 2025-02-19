# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_VER="$(ver_rs 3 - 4 .)" # 0.8.0_beta15 -> 0.8.0-beta.15

DESCRIPTION="Microsoft language server protocol implementation for D"
HOMEPAGE="https://github.com/Pure-D/serve-d"
SRC_URI="https://code.dlang.org/packages/serve-d/${MY_VER}.zip -> ${PF}.zip

https://code.dlang.org/packages/automem/0.6.9.zip -> automem-0.6.9.zip
https://code.dlang.org/packages/botan/1.12.19.zip -> botan-1.12.19.zip
https://code.dlang.org/packages/botan-math/1.0.3.zip -> botan-math-1.0.3.zip
https://code.dlang.org/packages/cachetools/0.4.1.zip -> cachetools-0.4.1.zip
https://code.dlang.org/packages/dcd/0.16.0-beta.2.zip -> dcd-0.16.0-beta.2.zip
https://code.dlang.org/packages/dfmt/0.15.0.zip -> dfmt-0.15.0.zip
https://code.dlang.org/packages/diet-complete/0.0.3.zip -> diet-complete-0.0.3.zip
https://code.dlang.org/packages/diet-ng/1.8.1.zip -> diet-ng-1.8.1.zip
https://code.dlang.org/packages/dscanner/0.16.0-beta.2.zip -> dscanner-0.16.0-beta.2.zip
https://code.dlang.org/packages/dub/1.33.1.zip -> dub-1.33.1.zip
https://code.dlang.org/packages/emsi_containers/0.9.0.zip -> emsi_containers-0.9.0.zip
https://code.dlang.org/packages/eventcore/0.9.25.zip -> eventcore-0.9.25.zip
https://code.dlang.org/packages/fuzzymatch/1.0.0.zip -> fuzzymatch-1.0.0.zip
https://code.dlang.org/packages/inifiled/1.3.3.zip -> inifiled-1.3.3.zip
https://code.dlang.org/packages/isfreedesktop/0.1.1.zip -> isfreedesktop-0.1.1.zip
https://code.dlang.org/packages/libasync/0.8.6.zip -> libasync-0.8.6.zip
https://code.dlang.org/packages/libddoc/0.8.0.zip -> libddoc-0.8.0.zip
https://code.dlang.org/packages/libdparse/0.23.2.zip -> libdparse-0.23.2.zip
https://code.dlang.org/packages/memutils/1.0.9.zip -> memutils-1.0.9.zip
https://code.dlang.org/packages/mir-algorithm/3.20.4.zip -> mir-algorithm-3.20.4.zip
https://code.dlang.org/packages/mir-core/1.5.5.zip -> mir-core-1.5.5.zip
https://code.dlang.org/packages/mir-cpuid/1.2.10.zip -> mir-cpuid-1.2.10.zip
https://code.dlang.org/packages/mir-ion/2.1.8.zip -> mir-ion-2.1.8.zip
https://code.dlang.org/packages/mir-linux-kernel/1.0.1.zip -> mir-linux-kernel-1.0.1.zip
https://code.dlang.org/packages/msgpack-d/1.0.4.zip -> msgpack-d-1.0.4.zip
https://code.dlang.org/packages/openssl/3.3.0.zip -> openssl-3.3.0.zip
https://code.dlang.org/packages/openssl-static/1.0.2+3.0.8.zip -> openssl-static-1.0.2+3.0.8.zip
https://code.dlang.org/packages/requests/2.1.1.zip -> requests-2.1.1.zip
https://code.dlang.org/packages/rm-rf/0.1.0.zip -> rm-rf-0.1.0.zip
https://code.dlang.org/packages/sdlfmt/0.1.1.zip -> sdlfmt-0.1.1.zip
https://code.dlang.org/packages/sdlite/1.1.2.zip -> sdlite-1.1.2.zip
https://code.dlang.org/packages/silly/1.1.1.zip -> silly-1.1.1.zip
https://code.dlang.org/packages/standardpaths/0.8.2.zip -> standardpaths-0.8.2.zip
https://code.dlang.org/packages/stdx-allocator/2.77.5.zip -> stdx-allocator-2.77.5.zip
https://code.dlang.org/packages/taggedalgebraic/0.11.22.zip -> taggedalgebraic-0.11.22.zip
https://code.dlang.org/packages/test_allocator/0.3.4.zip -> test_allocator-0.3.4.zip
https://code.dlang.org/packages/unit-threaded/0.10.8.zip -> unit-threaded-0.10.8.zip
https://code.dlang.org/packages/vibe-core/2.2.0.zip -> vibe-core-2.2.0.zip
https://code.dlang.org/packages/vibe-d/0.9.6.zip -> vibe-d-0.9.6.zip
https://code.dlang.org/packages/xdgpaths/0.2.5.zip -> xdgpaths-0.2.5.zip
"

LICENSE="MIT"
LICENSE+=" Apache-2.0 BSD-2 BSD Boost-1.0 GPL-3 ISC LGPL-3 MIT public-domain Unlicense || ( openssl SSLeay )"
S="${WORKDIR}/${PN}-${MY_VER}"
SLOT="0"
KEYWORDS="~amd64"

DLANG_VERSION_RANGE="2.100-2.106"
DLANG_PACKAGE_TYPE="single"
# gdc currently fails due to a bug in mir-cpuid, see: https://github.com/libmir/mir-cpuid/pull/46
DLANG_COMPILER_DISABLED_BACKENDS=(gdc)

CHECKREQS_MEMORY="10G" # mir is a chonker

inherit check-reqs dlang multiprocessing

# Lower versions of dcd won't immediately fail but they won't work as intended (no autocompletion for example)
RDEPEND=">=dev-util/dcd-0.15.2"
DEPEND=""
BDEPEND="dev-util/dub app-arch/unzip"

src_unpack() {
	unpack "${PF}.zip"
	pushd "${S}" || die

	local dep name ver dub_args
	dub_args=(
		# Don't look up dependencies online or in the system path
		--skip-registry=all
		# Only look for them in the ${T} directory
		--registry=file://"${T}"
		# Prefer verbose operation
		--verbose
		# Unpack dependencies for the local project (put them in ${S}/.dub)
		--cache=local
	)
	for dep in ${A}; do
		if [[ ${dep} != ${PF}.zip ]]; then
			# Due to a bug in dub, we can't have similar looking
			# archives in the same directory. Simply put, if we had:
			# foo-1.zip and foo-bar-2.zip when trying to fetch foo dub
			# will fail because it thinks that foo-bar-2.zip is foo's
			# archive. See: https://github.com/dlang/dub/pull/2727
			cp "${DISTDIR}/${dep}" "${T}" || die "Could not copy dependency to temporary directory"

			# This calculation is faulty, dub allows digits in package names, it will
			# probably be needed to save dependencies in a similar to $CRATES variable.
			name="${dep%%-[0-9]*}"
			version="${dep%.zip}"
			version="${version#${name}-}"

			/usr/bin/dub "${dub_args[@]}" fetch "${name}@${version}" \
				|| die "Could not extract dub dependencies"

			rm "${T}/${dep}" || die "Could not remove depedency from temporary directory"
		fi
	done
	popd > /dev/null || die
}

d_src_compile() {
	local dub_args=(
		# It wouldn't be good if the build became interactive
		--non-interactive
		# Let user provided $DCFLAGS dictate the build
		#--build=realease
		# It is good practice to be verbose
		--verbose
		# Don't touch anything outside the ${S} directory
		--skip-registry=all
	)

	DFLAGS="${DCFLAGS}" DUB_HOME="${S}" /usr/bin/dub build "${dub_args[@]}" || die
}

d_src_test() {
	local dub_args=(
		# It is good practice to be verbose
		--verbose
		# Don't touch anything outside the ${S} directory
		--skip-registry=all

		# ${PV} uses silly for testing so it supports jobs
		--
		--threads="$(makeopts_jobs)"
	)

	# Tests all submodules in dub.json. :dcd currently fails tests due to a missing dependency and import.
	# It's 1 little test though so no biggie.
	# See: https://github.com/Pure-D/serve-d/pull/350
	local subpkg
	# We also have another issue that testing $PV gives linking errors
	# when the --build configuration is specified (or if $DFLAGS are specified).
	# We can work around it by forcing --build=unittest.
	# See: https://github.com/Pure-D/serve-d/issues/351
	for subpkg in ":http" ":protocol" ":lsp" ":serverbase" ":workspace-d" ""; do
		# Let $subpkg be shell expanded since it can be empty
		DUB_HOME="${S}" DFLAGS="${DCFLAGS}" /usr/bin/dub test ${subpkg} --build=unittest "${dub_args[@]}" \
			|| die "Tests failed"
	done
}

d_src_install() {
	dobin "${S}/serve-d"
}
