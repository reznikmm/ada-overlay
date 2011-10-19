# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit gnat

IUSE=""

DESCRIPTION="set of Ada libraries to help to develop information systems"
HOMEPAGE="http://adaforge.qtada.com/matreshka"

SRC_URI="http://adaforge.qtada.com/${PN}/downloader/download/file/13/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"

RDEPEND=">=dev-lang/gnat-gpl-4.3.6.2010
	dev-ada/gprbuild"

DEPEND="${RDEPEND}"

RDEPEND=""

DEPEND=">=virtual/ada-2005
	dev-ada/gprbuild
	${RDEPEND}"

# a location to temporarily keep common stuff installed by make install
CommonInst="${WORKDIR}/common-install"

lib_compile()
{
        emake config
        econf  
        emake
}

lib_install()
{
        einfo emake install \
          INSTALL_PROJECT_DIR="${DLgpr}" \
          INSTALL_INCLUDE_DIR="${DL}/include/${PN}" \
          INSTALL_LIBRARY_DIR="${DL}"
        emake install \
          INSTALL_PROJECT_DIR="${DLgpr}" \
          INSTALL_INCLUDE_DIR="${DL}/usr/include/${PN}" \
          INSTALL_LIBRARY_DIR="${DL}"

	[ -d "${CommonInst}" ] || mkdir "${CommonInst}"

	cp -Rf "${DL}/usr/include" "${CommonInst}"
	rm -rf "${DL}"/usr

	sed -i -e "/Source_Dirs/s#../../include#/usr/include/ada#" \
		"${DLgpr}"/*.gpr
	sed -i -e "/Library_.*Dir/s#/usr/lib[0-9]*#${AdalibLibTop}/$1/${PN}#" \
		"${DLgpr}"/${PN}/config.gpr
}

src_install ()
{
        cd "${S}"
        dodir ${AdalibSpecsDir}
        insinto ${AdalibSpecsDir}
	doins -r "${CommonInst}/include/${PN}"

        #set up environment
        #echo "PATH=%DLbin%" > ${LibEnv}
        echo "LDPATH=%DL%" >> ${LibEnv}
        #echo "ADA_OBJECTS_PATH=%DL%/${PN}" >> ${LibEnv}
        #echo "ADA_INCLUDE_PATH=${AdalibSpecsDir}/${PN}" >> ${LibEnv}

        #echo "ADA_PROJECT_PATH=%DLgpr%" >> ${LibEnv}

	gnat_src_install

	dodoc AUTHORS README

	insinto /usr/share/doc/${PF}
	doins -r examples
}
