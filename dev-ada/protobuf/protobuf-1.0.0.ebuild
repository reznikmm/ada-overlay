# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

ADA_COMPAT=( gnat_201{6,7,8,9} )

inherit ada multiprocessing

DESCRIPTION="The Google Protocol Buffers implementation in Ada"
HOMEPAGE="https://github.com/reznikmm/protobuf"
SRC_URI="https://github.com/reznikmm/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/protobuf
		dev-ada/matreshka
		dev-ada/ada-pretty
"

RDEPEND="${DEPEND}"
BDEPEND="${DEPEND}"

src_compile()
{
	emake PROCESSORS=$(makeopts_jobs) GPRBUILD_FLAGS="-j0 -p -R"
}

src_install()
{
	emake PROCESSORS=$(makeopts_jobs) DESTDIR="${D}" PREFIX="${EPREFIX}/usr" LIBDIR="${EPREFIX}/usr/$(get_libdir)" BINDIR="${EPREIFX}/usr/bin" GPRDIR="${EPREFIX}/usr/share/gpr" install

}

