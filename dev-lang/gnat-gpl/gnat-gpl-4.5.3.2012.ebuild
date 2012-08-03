# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/gnat-gpl/gnat-gpl-4.1.3.2008.ebuild,v 1.2 2010/01/21 11:20:13 george Exp $

inherit gnatbuild2

DESCRIPTION="GNAT Ada Compiler - AdaCore GPL version"
HOMEPAGE="https://libre.adacore.com/"
LICENSE="GPL-2"

#GNATREV="172703"
BOOT_SLOT="4.3"

SRC_URI="http://www.ada-ru.org/files/gentoo/gcc-${GNATMAJOR}.${GNATMINOR}-gpl-${ACT_Ver}-src.tgz
        http://www.ada-ru.org/files/gentoo/${PN}-${ACT_Ver}-src.tgz
	http://www.adaic.org/standards/05rm/RM-05-Html.zip
	x86?   ( http://www.ada-ru.org/files/gentoo/gnatboot-${BOOT_SLOT}-i386.tar.bz2 )
	ppc?   ( http://www.ada-ru.org/files/gentoo/gnatboot-${BOOT_SLOT}-ppc.tar.bz2 )
	amd64? ( http://www.ada-ru.org/files/gentoo/gnatboot-${BOOT_SLOT}-amd64.tar.bz2 )
	arm? ( http://www.ada-ru.org/files/gentoo/gnatboot-4.5-armv6j.tar.bz2 )"
# ${BOOT_SLOT} and ${GCCVER} are defined in gnatbuild.eclass and depend
# only on $PV, so should be safe to use in DEPEND/SRC_URI
#	mirror://gentoo/${PN}-gcc-3.4.6.1.diff.bz2

KEYWORDS="~amd64 ~ppc ~x86 ~arm"
DEPEND="app-arch/unzip
sys-devel/flex
>=dev-libs/gmp-4.2
>=dev-libs/mpfr-2.3.1
>=dev-libs/mpc-0.8.0"

RDEPEND=""

IUSE=""

QA_EXECSTACK="${BINPATH:1}/gnatls ${BINPATH:1}/gnatbind
	${BINPATH:1}/gnatmake ${LIBEXECPATH:1}/gnat1"

S="${WORKDIR}/gcc-${GNATMAJOR}.${GNATMINOR}-${ACT_Ver}-src"
GNATSOURCE="${WORKDIR}/${PN}-${ACT_Ver}-src"

src_unpack() {
	gnatbuild2_src_unpack base_unpack common_prep

	# one of the converted gcc->gnatgcc in common_prep needs to stay gcc in
	# fact in this version
	# sed -i -e 's:(Last3 = "gnatgcc"):(Last3 = "gcc"):' "${S}"/gcc/ada/makegpr.adb
	# reverting similar conversion in comment - line too long
	sed -i -e 's:"gnatgcc":"gcc":' "${S}"/gcc/ada/osint.ads "${S}"/gcc/ada/switch.ads

	# it seems some assertion isn't precise enought and breaks
	# compilation of qtada-3.1.1. Remove it:
	# epatch "${FILESDIR}/drop_assert.patch"
}

src_install() {
	gnatbuild2_src_install

	# No idea how make compiler to find .h includes. So just make symlink
	dodir "${LIBPATH}/gcc/${CTARGET}"
	dosym "../.." "${LIBPATH}/gcc/${CTARGET}/${GCCRELEASE}"
	# docs have to be fetched from 3rd place, quite messy package
	dodir /usr/share/doc/${PF}/html
	dohtml "${WORKDIR}"/*.html

	# misc notes and examples
	cd ${GNATSOURCE}
	dodoc features*
	cp -pPR examples/ Contributors.html "${D}/usr/share/doc/${PF}/"

	# this version of gnat does not provide info files yet
	rm -rf "${D}${DATAPATH}/info/"
}

pkg_postinst() {
	gnatbuild2_pkg_postinst

	ewarn "Please note!!!"
	ewarn "gnat-gpl is distributed under the GPL-2 license, without the GMGPL provision!!"
	ewarn "For the GMGPL version you may look at the gnat-gcc compiler."
	ewarn
}
