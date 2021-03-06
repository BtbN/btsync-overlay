# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit pax-utils eutils systemd user

DESCRIPTION="Sync stuff via BitTorrent"
HOMEPAGE="https://www.getsync.com/"
SRC_URI="amd64? ( https://download-cdn.getsync.com/${PV}/linux-x64/resilio-sync_x64.tar.gz -> ${P}_amd64.tar.gz )
	x86? ( https://download-cdn.getsync.com/${PV}/linux-i386/resilio-sync_i386.tar.gz -> ${P}_x86.tar.gz )
	arm? ( https://download-cdn.getsync.com/${PV}/linux-armhf/resilio-sync_armhf.tar.gz -> ${P}_arm.tar.gz )"

RESTRICT="mirror"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86 ~arm ~ppc"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"

QA_PREBUILT="usr/bin/rslsync"

pkg_setup() {
	enewuser btsync -1 -1 /var/lib/btsync
}

src_install() {
	dodoc LICENSE.TXT

	newinitd "${FILESDIR}/btsync_initd" btsync
	newconfd "${FILESDIR}/btsync_confd" btsync

	systemd_newunit "${FILESDIR}/btsync.system_service" "btsync@.service"
	systemd_newuserunit "${FILESDIR}/btsync.user_service" "btsync.service"

	insinto /etc
	doins "${FILESDIR}/btsync.conf"

	mkdir -p "${ED}/usr/bin"
	cp rslsync "${ED}/usr/bin/rslsync"
	pax-mark m "${ED}/usr/bin/rslsync"
	dosym rslsync /usr/bin/btsync

	keepdir /var/lib/btsync
	fperms 0700 /var/lib/btsync
	fowners btsync:btsync /var/lib/btsync
}
