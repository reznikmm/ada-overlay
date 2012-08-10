# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ada/qtada/qtada-1.0.4.ebuild,v 1.2 2008/10/23 14:17:58 george Exp $

# We only need gnat.eclass for a few vars and helper functions.
# We will not use src_* functions though.
EAPI="2"

inherit eutils multilib gnat

IUSE=""

DESCRIPTION="Ada bindings for Qt library"
HOMEPAGE="http://www.qtada.com/"

QTADA_RELEASE="20120708-3871"

SRC_URI="http://download.qtada.com/${PN}-gpl-${PV}-${QTADA_RELEASE}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

# qtada is quite picky atm. For example this version will only compile with
# the specified gnat, not even gnat-gcc-4.3.0 for example.
RDEPEND=">=dev-lang/gnat-gpl-4.3.6.2010
	dev-ada/gprbuild
	dev-ada/asis-gpl
	>=x11-libs/qt-core-4.6.0
	>=x11-libs/qt-sql-4.6.0
	>=x11-libs/qt-gui-4.6.0[accessibility]
	>=x11-libs/qt-opengl-4.6.0
	>=x11-libs/qt-webkit-4.6.0"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}-gpl-${PV}-${QTADA_RELEASE}"

#LIBDIR=/usr/lib/ada/i686-pc-linux-gnu-gnat-gpl-4.3/qtada

pkg_setup() {
	local ActiveGnat=$(get_active_profile)
	case "${ActiveGnat}" in
	 "*gnat-gpl*")
		;;
	 "*")
		ewarn "This version of qtada can only be compiled with gnat-gpl"
		die   "Please switch to  gnat-gpl and try again"
		;;
	esac
}

# As this version of qtada only compiles with gnat-gpl-4.3 and we already
# verified that it is active, we do not switch profiles or do any majic here.
# We simplt run build once, just need to set some path appropriately.
src_compile() {
	econf --datadir=${AdalibDataDir}/${PF} \
		--includedir=${AdalibSpecsDir}/${PN} \
		--libdir=${AdalibLibTop}/$(get_active_profile)/${PN} || die "econf failed"
	emake || die "make failed"
}

src_install() {
	# set common part of the path
	local InstTop=${AdalibLibTop}/$(get_active_profile)

	# run upstream setup
	einstall \
		libdir=${D}/${InstTop}/${PN} \
		bindir=${D}/${InstTop}/bin \
		docdir=${D}/${PREFIX}/share/doc/${PF} \
		includedir=${D}/${AdalibSpecsDir} || die "install failed"

	if has_version ">=dev-ada/gprbuild-2011"; then
		einfo "Fix amoc.xml"
		sed -i -e "s/{PATH}/{PATH(Amoc)}/" \
		    "${D}"/${PREFIX}/share/gprconfig/amoc.xml
	fi

	# move .ali file together with .so's
	mv "${D}"/${InstTop}/${PN}/${PN}/*.ali "${D}"/${InstTop}/${PN}/
	rmdir "${D}"/${InstTop}/${PN}/${PN}/

	# arrange and fix gpr files
	mv "${D}"/${InstTop}/${PN}/gnat "${D}"/${InstTop}/gpr
	sed -i -e "s:../../include:${AdalibSpecsDir}:" \
		-e "s:../../lib:${InstTop}/${PN}:" \
		-e "s:${PN}/${PN}:${PN}:" "${D}"/${InstTop}/gpr/*.gpr

	# Create an environment file
	local SpecFile="${D}/usr/share/gnat/eselect/${PN}/$(get_active_profile)"
	dodir /usr/share/gnat/eselect/${PN}/
	echo "PATH=${InstTop}/bin" > "${SpecFile}"
	echo "ADA_INCLUDE_PATH=${AdalibSpecsDir}/${PN}/core" >> "${SpecFile}"
	echo "ADA_OBJECTS_PATH=${InstTop}/${PN}" >> "${SpecFile}"
	echo "ADA_PROJECT_PATH=${InstTop}/gpr" >> "${SpecFile}"

	# install docs
	dodoc NEWS README
	find "${D}/usr/examples/${PN}" -name main -delete
	mv "${D}"/usr/examples/${PN} "${D}"/usr/share/doc/${PF}/examples
	rmdir "${D}"/usr/examples/
}
