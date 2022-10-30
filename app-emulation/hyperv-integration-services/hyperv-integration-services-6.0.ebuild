# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="Hyper-V Integration Services"
HOMEPAGE="http://www.kernel.org"

SRC_URI="http://www.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/linux-${PV}.tar.xz"
KEYWORDS="amd64"

LICENSE="GPL-2.0"
SLOT="0"

IUSE=""

RDEPEND="dev-lang/python"
DEPEND=""

S="${WORKDIR}/linux-${PV}/tools/hv/"

src_install() {
	emake DESTDIR="${D}" install
	keepdir /var/lib/hyperv

	exeinto /usr/libexec/hypervkvpd/
	doexe "${FILESDIR}/hv_get_dhcp_info" "${FILESDIR}/hv_get_dns_info" "${FILESDIR}/hv_set_ifconfig"

	for daemon in kvp vss fcopy; do
		sed -e "s:@daemon@:${daemon}:g" "${FILESDIR}/${PN}.init.in" >"hv_${daemon}_daemon" || die
		doinitd "hv_${daemon}_daemon"
		systemd_newunit "${FILESDIR}"/"hv-${daemon}-daemon".service "hv-${daemon}-daemon".service
	done

}
