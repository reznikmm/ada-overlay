# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit versionator

IUSE=""

DESCRIPTION="GPRbuild Tool To Speed Multi-Language Development"
HOMEPAGE="http://www.adacore.com/home/products/gnatpro/toolsuite/gprbuild/"
SRC_URI="http://www.ada-ru.org/files/gentoo/${PN}-gpl-${PV}-src.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"

DEPEND="|| ( >=dev-lang/gnat-gcc-4.5.0 >=dev-lang/gnat-gpl-2010 )
        dev-ada/xmlada"

RDEPEND=""

S="${WORKDIR}/${P}-src"

src_prepare ()
{
    epatch "${FILESDIR}"/${PN}-gentoo-gnatgcc.patch
}

src_configure ()
{
    econf '--datadir=${prefix}/share' '--libdir=${prefix}'/$(get_libdir)
}

src_compile ()
{
#    emake LIBRARY_TYPE=relocatable all
    emake all || die "Make files"
}

src_install ()
{
    emake prefix="${D}/usr" install
    rm -rf ${D}/usr/share/{doc,examples,gpr,info}

    insinto /usr/share/gprconfig
    doins ${FILESDIR}/gentoo-gnat.xml

    dodoc README features*
    dohtml doc/html/*
    doinfo doc/info/${PN}_ug.info

    insinto /usr/share/doc/${PF}
    doins -r doc/pdf doc/txt examples
}
