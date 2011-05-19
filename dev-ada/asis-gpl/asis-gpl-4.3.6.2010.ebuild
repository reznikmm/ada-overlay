# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ada/asis-gpl/asis-gpl-4.1.3.2008.ebuild,v 1.2 2008/08/23 20:15:54 george Exp $

inherit eutils flag-o-matic gnatbuild

ACT_Ver=$(get_version_component_range 4)
Gnat_Name="gnat-gpl"

DESCRIPTION="The Ada Semantic Interface Specification (semantic analysis and tools tied to compiler)"
SRC_URI="http://www.ada-ru.org/files/gentoo/${PN}-${ACT_Ver}-src.tgz"
HOMEPAGE="http://www.adacore.com/home/products/gnatpro/add-on_technologies/asis/"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~x86 ~ppc"

RDEPEND="=dev-lang/gnat-gpl-${PV}*"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}-${ACT_Ver}-src"

# it may be even better to force plain -O2 -pipe -ftracer here
replace-flags -O3 -O2

# we need to adjust some vars defined in gnatbuild.eclass so that they use
# gnat-gpl instead of asis
LIBPATH=${LIBPATH/${PN}/${Gnat_Name}}
BINPATH=${BINPATH/${PN}/${Gnat_Name}}
DATAPATH=${DATAPATH/${PN}/${Gnat_Name}}

QA_EXECSTACK="${BINPATH:1}/*
	${LIBPATH:1}/adalib/libasis-${ACT_Ver}.so"

pkg_setup() {
	currGnat=$(eselect --no-color gnat show | grep "gnat-" | awk '{ print $1 }')
	if [[ "${currGnat}" != "${CTARGET}-${Gnat_Name}-${SLOT}" ]]; then
		echo
		eerror "The active gnat profile does not correspond to the selected"
		eerror "version of asis!  Please install the appropriate gnat (if you"
		eerror "did not so yet) and run:"
		eerror "eselect gnat set ${CTARGET}-${Gnat_Name}-${SLOT}"
		eerror "env-update && source /etc/profile"
		eerror "and then emerge =dev-ada/${P} again.."
		echo
		die
	fi
}

# we need to override the eclass defined src_unpack
# and change gcc to gnatgcc where appropriate
src_unpack() {
	unpack ${A}
	cd "${S}"
	for fn in asis/a4g-gnat_int.adb \
		tools/tool_utils/asis_ul-common.adb ; do
		sed -i -e "s:\"gcc:\"gnatgcc:" ${fn}
	done
}

src_compile() {
    emake all tools || die "make failed"
}

src_install () {
    local GPRPATH=/usr/$(get_libdir)/ada/${CTARGET}-${Gnat_Name}-${SLOT}/gpr

    emake install install-asistant install-tools install-gnatcheck-doc\
	prefix="${D}"\
	I_BIN="${D}${BINPATH}" \
	I_INC="${D}${LIBPATH}"/adainclude/asis \
	I_LIB="${D}${LIBPATH}"/adalib/asis \
	I_GPR="${D}${GPRPATH}" \
	I_DOC="${D}"/usr/share/doc/${PF} \
	G_DOC="${D}"/usr/share/doc/${PF} \
	I_GPS="${D}"/usr/share/doc/${PF} \
	|| die "make install failed"

    sed -i -e "/Source_Dirs/s#\".*\"#\"${LIBPATH}/adainclude/asis\"#" \
	-e "/Library_Dir/s#\".*\"#\"${LIBPATH}/adalib/asis\"#" \
	"${D}${GPRPATH}"/asis.gpr

    rm -rf "${D}"/usr/share/doc/${PF}/{info,txt}
    doinfo documentation/*.info
    dodoc README features* *.txt documentation/*.txt

    insinto /usr/share/doc/${PF}
    doins -r tutorial/ templates/
}

pkg_postinst() {
	echo
	elog "The ASIS is installed for the active gnat compiler at gnat's	location."
	elog "No further configuration is necessary. Enjoy."
	echo
}
