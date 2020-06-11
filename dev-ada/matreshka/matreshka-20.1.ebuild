# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

ADA_COMPAT=( gnat_201{6,7,8,9} )
inherit ada multiprocessing
MYP=${PN}-${PV}

IUSE="oracle postgresql sqlite mysql aws a2js uml"

DESCRIPTION="Set of Ada libraries to help to develop information systems"
HOMEPAGE="http://forge.ada-ru.org/matreshka"

SRC_URI="http://forge.ada-ru.org/${PN}/downloads/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"

RDEPEND="${ADA_DEPS}
	oracle? ( dev-db/oracle-instantclient-basic )
	postgresql? ( dev-db/postgresql )
	sqlite? ( dev-db/sqlite )
	mysql? ( virtual/mysql )
	aws? ( dev-ada/aws )
	a2js? ( dev-ada/asis )"
DEPEND="${RDEPEND}
	dev-ada/gprbuild[${ADA_USEDEP}]"

REQUIRED_USE="${ADA_REQUIRED_USE}"

S="${WORKDIR}"/${MYP}

PATCHES=( "${S}"/packages/Fedora/files/matreshka-gprinstall.patch )

src_configure() {
    for J in `dirname $(which gnatmake)`/* ; do
        if file `which $J` |grep -q "shell script" ; then
            # Ebuild uses a shell script that looks like
            # exec "/usr/bin/gnatmake-8.3.1" "${@}"
            # gnatmake-8.3.1 doesn't work at all, so replace it by a link
            LINK=`grep ^exec $J|cut -d\  -f2| tr -d \"`
            FILE=`readlink -f $LINK`
            rm $J
            ln -v -s $FILE $J
        fi
    done
    emake config
    econf $(use_enable oracle ) \
      $(use_enable postgresql ) \
      $(use_enable sqlite sqlite3 ) \
      $(use_enable mysql mysql ) \
      $(use_enable uml amf )
}

src_compile()
{
    emake PROCESSORS=$(makeopts_jobs) GPRBUILD_FLAGS="-j0 -p -R"
}

src_test() {
    emake PROCESSORS=$(makeopts_jobs) check
}

src_install()
{
    einfo emake PROCESSORS=$(makeopts_jobs) DESTDIR="${D}" GPRDIR=/usr/share/gpr install
    emake PROCESSORS=$(makeopts_jobs) DESTDIR="${D}" GPRDIR=/usr/share/gpr install
    einstalldocs
}
