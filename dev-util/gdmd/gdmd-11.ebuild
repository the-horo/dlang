# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Wrapper script for gdc that emulates the dmd command"
HOMEPAGE="https://www.gdcproject.org/"
LICENSE="GPL-3+"

SLOT="${PV}"
KEYWORDS="~alpha amd64 arm arm64 ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 x86"
RDEPEND="sys-devel/gcc:${PV}[d]"
IDEPEND="sys-devel/gcc-config"
RELEASE="0.1.0"
SRC_URI="https://codeload.github.com/D-Programming-GDC/gdmd/tar.gz/script-${RELEASE} -> gdmd-${RELEASE}.tar.gz"
PATCHES="${FILESDIR}/${PN}-no-dmd-conf.patch"
S="${WORKDIR}/gdmd-script-${RELEASE}"

src_compile() {
	:
}

src_install() {
	local binPath="usr/${CHOST}/gcc-bin/${PV}"
	exeinto "${binPath}"
	newexe dmd-script "${CHOST}-gdmd"
	ln -f "${D}/${binPath}/${CHOST}-gdmd" "${D}/${binPath}/gdmd" || die "Could not create 'gdmd' hardlink"
}

pkg_postinst() {
	maybe_update_gcc_config
}

pkg_postrm() {
	maybe_update_gcc_config
}

maybe_update_gcc_config() {
	# Call gcc-config if the current configuration if for the same slot
	# we are installing to. This is needed to make gdmd available in
	# $PATH.

	local CTARGET=${CTARGET:-${CHOST}}

	# Logic taken from toolchain.eclass and simplified a little
	local curr_config
	curr_config=$(gcc-config -c ${CTARGET} 2>&1) || return 0

	local curr_config_ver=$(gcc-config -S ${curr_config} | awk '{print $2}')

	if [[ ${curr_config_ver} == ${SLOT} ]]; then
		# We should call gcc-config to make sure the addition/removal
		# of gdmd is propagated in $PATH
		local current_specs use_specs
		current_specs=$(gcc-config -S ${curr_config} | awk '{print $3}')
		[[ -n ${current_specs} ]] && use_specs=${current_specs}

		if [[ -n ${use_specs} ]] && \
		   [[ ! -e ${EROOT}/etc/env.d/gcc/${CTARGET}-${SLOT}${use_specs} ]]
		then
			# It's out of the scope of this package to treat such
			# cases. The user will probably be warned by another package
			# that something is off.
			return
		fi

		local target="${CTARGET}-${SLOT}${use_specs}"

		gcc-config "${target}"
	fi
}
