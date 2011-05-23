# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit gnat versionator

IUSE="soap wsdl ssl ldap ipv6"

DESCRIPTION="Ada Web Server - powerful HTTP component to embed in applications"
HOMEPAGE="http://libre.adacore.com/aws/"
SRC_URI="http://www.ada-ru.org/files/gentoo/${PN}-gpl-${PV}-src.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"

RDEPEND="sys-libs/zlib
	soap? ( dev-ada/xmlada )
	wsdl? ( dev-ada/asis-gpl )
	ssl? ( dev-libs/openssl )
	ldap? ( net-nds/openldap )"

DEPEND=">=virtual/ada-2005
	dev-ada/gprbuild
	${RDEPEND}"

S="${WORKDIR}/${PN}-gpl-${PV}-src"

# a location to temporarily keep common stuff installed by make install
CommonInst="${WORKDIR}/common-install"

src_configure() {
	# overide some settings in makefile.conf

	if use wsdl; then
		echo "ASIS = true" >> makefile.conf
	else
		echo "ASIS = false" >> makefile.conf
	fi

	if use soap; then
		echo "XMLADA = true" >> makefile.conf
	else
		echo "XMLADA = false" >> makefile.conf
	fi

	if use ipv6; then
		echo "IPv6 = true" >> makefile.conf
	else
		echo "IPv6 = false" >> makefile.conf
	fi

	if use ssl; then
		echo "SOCKET = openssl" >> makefile.conf
	fi

	if use ldap; then
		echo "LDAP = true" >> makefile.conf
	fi

	echo "DEFAULT_LIBRARY_TYPE = relocatable" >> makefile.conf
	echo "ZLIB = true" >> makefile.conf

	# gnat-gcc-4.4 doesn't understant -gnatyB option, drop it
	sed -i -e "/-gnaty/s/B//" shared.gpr
}

lib_compile()
{
        emake -j1 setup build || die "make setup build failed"
}

lib_install()
{
        emake -j1 install prefix="${D}/usr" \
	    I_BIN="${CommonInst}/bin" \
	    I_INC="${CommonInst}/aws/" \
	    TI_INC="${CommonInst}/aws/native" \
	    I_CPN="${CommonInst}/aws/components" \
	    I_LIB="${DL}/native" \
	    I_GPR="${DLgpr}" \
	    I_AGP="${DLgpr}/aws" \
	    I_TPL="${CommonInst}/examples/templates" \
	    I_IMG="${CommonInst}/examples/images" \
	    I_SBN="${CommonInst}/examples/bin" \
	    I_WEL="${CommonInst}/examples/web_elements" \
	    I_DOC="${CommonInst}/docs" \
	    I_PLG="${CommonInst}/gps" \
         || die "make install failed"

	sed -i -e "/Source_Dirs/,+1c   for Source_Dirs use (\"${AdalibSpecsDir}/${PN}\");" \
	    -e "/Library_Dir/c   for Library_Dir use AWS_Shared'Library_Dir;" \
		"${DLgpr}/aws.gpr"

	sed -i -e "s#../../../include#${AdalibSpecsDir}#" \
		"${DLgpr}/aws/aws_components.gpr"

	sed -i -e "s#../..#${AdalibLibTop}/$1#" "${DLgpr}/aws/aws_shared.gpr"
}

src_install ()
{
        cd "${S}"
        dodir ${AdalibSpecsDir}
        insinto ${AdalibSpecsDir}
	doins -r "${CommonInst}"/aws

	dobin "${CommonInst}"/bin/*

        #set up environment
        #echo "PATH=%DLbin%" > ${LibEnv}
        echo "LDPATH=%DL%/native/relocatable" >> ${LibEnv}
        echo "ADA_OBJECTS_PATH=%DL%/native/relocatable" >> ${LibEnv}
        echo "ADA_INCLUDE_PATH=\
${AdalibSpecsDir}/${PN}:\
${AdalibSpecsDir}/${PN}/components:\
${AdalibSpecsDir}/${PN}/native" >> ${LibEnv}

        #echo "ADA_PROJECT_PATH=%DLgpr%" >> ${LibEnv}

	gnat_src_install

	dodoc  AUTHORS readme.txt "${CommonInst}"/docs/*.txt
	dohtml "${CommonInst}"/docs/*.html
	doinfo "${CommonInst}"/docs/*.info

        dodir /usr/share/doc/${PF}/pdf
	insinto /usr/share/doc/${PF}/pdf
	doins "${CommonInst}"/docs/*.pdf

	insinto /usr/share/doc/${PF}
	doins -r "${CommonInst}"/{examples,gps}
}
