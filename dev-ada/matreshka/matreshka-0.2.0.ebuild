# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit gnat

IUSE="oracle postgresql sqlite"

DESCRIPTION="set of Ada libraries to help to develop information systems"
HOMEPAGE="http://forge.ada-ru.org/matreshka"

SRC_URI="http://forge.ada-ru.org/${PN}/downloads/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"

RDEPEND=">=dev-lang/gnat-gpl-4.5.3.2011
	dev-ada/gprbuild
	oracle? ( dev-db/oracle-instantclient-basic )
	postgresql? ( dev-db/postgresql-base )
	sqlite? ( dev-db/sqlite )"

DEPEND=">=virtual/ada-2005
 ${RDEPEND}"

# a location to temporarily keep common stuff installed by make install
CommonInst="${WORKDIR}/common-install"

lib_compile()
{
        emake config
        econf $(use_enable oracle ) \
          $(use_enable postgresql ) \
          $(use_enable sqlite sqlite3 )
        emake -j1
}

lib_install()
{
        einfo emake install \
          DESTDIR="${DL}" \
          INSTALL_PROJECT_DIR="${DLgpr}" \
          INSTALL_LIBRARY_DIR="${DL}"
        emake -j1 install \
          DESTDIR="${DL}" \
          INSTALL_PROJECT_DIR="${DLgpr}" \
          INSTALL_LIBRARY_DIR="${DL}"

	[ -d "${CommonInst}" ] || mkdir "${CommonInst}"

	cp -Rf "${DL}/usr/include" "${CommonInst}"
	cp -Rf "${DL}/usr/share"   "${CommonInst}"
	rm -rf "${DL}"/usr

	sed -i -e "/Source_Dirs/s#../../include#/usr/include/ada#" \
		"${DLgpr}"/*.gpr
	sed -i -e "/Library_.*Dir/s#/usr/lib[0-9]*#${AdalibLibTop}/$1/${PN}#" \
		"${DLgpr}"/${PN}/${PN}_config.gpr
}

src_install ()
{
        cd "${S}"
        dodir ${AdalibSpecsDir}
        insinto ${AdalibSpecsDir}
	doins -r "${CommonInst}/include/${PN}"

        dodir /usr/share
        insinto /usr/share
	doins -r "${CommonInst}/share/${PN}"

        #set up environment
        #echo "PATH=%DLbin%" > ${LibEnv}
        echo "LDPATH=%DL%" >> ${LibEnv}
        #echo "ADA_OBJECTS_PATH=%DL%/${PN}" >> ${LibEnv}
        #echo "ADA_INCLUDE_PATH=${AdalibSpecsDir}/${PN}" >> ${LibEnv}

        #echo "ADA_PROJECT_PATH=%DLgpr%" >> ${LibEnv}

	gnat_src_install

	dodoc CONTRIBUTORS README

	insinto /usr/share/doc/${PF}
	doins -r examples
}
