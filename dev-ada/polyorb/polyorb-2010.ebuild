# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ada/polyorb/polyorb-2.1.0.ebuild,v 1.6 2008/01/27 00:15:45 george Exp $

EAPI="1"

inherit gnat

IUSE="+doc +corba +giop ssl soap dsa moma event ir naming notification time"

DESCRIPTION="A CORBA implementation for Ada"
HOMEPAGE="http://libre.adacore.com/libre/tools/polyorb"
SRC_URI="http://www.ada-ru.org/files/gentoo/${PN}-gpl-${PV}-src.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"

RDEPEND="ssl? ( dev-libs/openssl )
	soap? ( dev-ada/xmlada )"

# PCS version of compiler and polyorb should match to use DSA.
# See PCS_Version in polyorb's s-parint.ads and in compiler's exp_dist.ads

DEPEND="${RDEPEND}
	virtual/ada
	dsa? ( || ( =dev-lang/gnat-gcc-4.5* =dev-lang/gnat-gpl-4.3.6.2010* ) )"

S="${WORKDIR}/${PN}-gpl-${PV}-src"

CommonInst="${WORKDIR}/common-install"

src_unpack () {
	unpack ${A}
	cd "${S}"
	sed -i -e 's/\${prefix}/${DESTDIR}\0/' Makefile.in || die "sed failed"
}

lib_compile()
{
	APPLI="$(usev corba) $(usev dsa) $(usev moma)"
	PROTO="$(usev giop) $(usev soap)"
	CORBA_SERVICES="$(usev event) $(usev ir) $(usev naming)\
		 $(usev notification) $(usev time)"

	# set Ada compiler name
	export ADA=$ADAC

	econf --with-appli-perso="$APPLI" \
		--with-proto-perso="$PROTO" \
		--with-corba-services="$CORBA_SERVICES" \
		--datadir='${prefix}/share' \
		--libdir=/usr/lib \
		$(use_with ssl openssl) || die "econf failed"
		#--enable-shared \
		# NOTE: --libdir is passed here to simplify logic - all the proper files
		# are anyway moved to the final destination by the eclass
	emake -j1 || die "make failed"
}

# NOTE: we are using $1 - the passed gnat profile name
lib_install()
{
	make DESTDIR=${DL} install || die "install failed"

	[ -d "${CommonInst}" ] || mkdir "${CommonInst}"

	mv "${DL}/usr/bin/${PN}-config" "${DLbin}"
	cp -Rf "${DL}/usr/bin" "${CommonInst}"
	cp -Rf "${DL}/usr/include" "${CommonInst}"
	mv "${DL}/usr/lib/gnat"/* "${DLgpr}"
	mv "${DL}/usr/lib/polyorb/static"/* "${DL}"
	mv "${DL}/usr/lib/polyorb"/*.ali "${DL}"
	cp -Rf "${DL}/usr/share" "${CommonInst}"
	rm -rf "${DL}"/usr

	# fix paths in polyorb-config
	sed -i -e "s:includedir=\"\${prefix}/include\":includedir=/usr/include/ada:" \
		-e "s:libdir=\"/usr/lib\":libdir=${AdalibLibTop}/$1/${PN}:" \
		"${DLbin}/${PN}-config"
	sed -i -e "/Source_Dirs/s#../../include#/usr/include/ada#" \
		-e "/Object_Dir/s#../../lib#${AdalibLibTop}/$1#" \
		"${DLgpr}"/polyorb.gpr
	sed -i -e "/Library_Dir/s#../../polyorb/static#${AdalibLibTop}/$1/${PN}#" \
		"${DLgpr}"/polyorb/*.gpr
}

src_install ()
{
	cd "${S}"
	# install sources
	dodir ${AdalibSpecsDir}
	insinto ${AdalibSpecsDir}
	doins -r "${CommonInst}/include/${PN}"
	rm -f "${CommonInst}/bin/idlac"
	ls "${CommonInst}/bin"/*
	dobin "${CommonInst}/bin"/*
	dosym /usr/bin/iac /usr/bin/idlac

        dodir /usr/share/doc/${PF}
        insinto /usr/share/doc/${PF}
        doins -r "${CommonInst}/share/gps/plug-ins"

	#set up environment
	#echo "PATH=%DL%/bin" > ${LibEnv}
	#echo "LDPATH=%DL%" >> ${LibEnv}
	echo "ADA_OBJECTS_PATH=%DL%" >> ${LibEnv}
	echo "ADA_INCLUDE_PATH=/usr/include/ada/${PN}" >> ${LibEnv}

	gnat_src_install

	dodoc CHANGE_* FEATURES INSTALL MANIFEST NEWS README* VERSION

	doinfo "${CommonInst}/share/doc/${PN}/info"/*.info

	if use doc; then
		dohtml "${CommonInst}/share/doc/${PN}/html/polyorb_ug"/*.html
    		insinto /usr/share/doc/${PF}
    		doins -r "${CommonInst}/share/doc/${PN}/pdf"
    		doins -r "${CommonInst}/share/doc/${PN}/ps"
    		dodoc "${CommonInst}/share/doc/${PN}/txt"/*.txt

		dodir /usr/share/doc/${PF}/examples
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
