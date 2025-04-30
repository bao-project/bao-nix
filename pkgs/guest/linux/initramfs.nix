# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchurl
, fetchgit
, rsync
, cpio
, setup-cfg
, fakeroot
, linuxApp
}:

stdenv.mkDerivation rec {

    pname = "initramfs";
    version = "1.0.0";

    linux_image = fetchurl {
        url = "https://github.com/bao-project/bao-linux-test/releases/download/v1.0.0-${setup-cfg.platform_name}/initramfs_${setup-cfg.platform_name}.tar.gz";
        sha256 = "sha256-Rpe9phmrBJpmi/7sB3uPwxNRME+ZUtrGcMq/OvaULRc=";
    };

    buildInputs = [ cpio fakeroot ];

    unpackPhase = ''
        tar -xvf $linux_image
    '';

    buildPhase = ''
        mkdir -p initramfs
        cd initramfs 
        cpio -idm < ../wrkdir/rootfs_${setup-cfg.platform_name}.cpio || true
        chmod +x init bin/busybox sbin/init bin/sh
        mkdir -p home/testf
        cp ${linuxApp}/bin/program.out home/testf/testf-app.out
        cp ${linuxApp}/bin/program.out etc/init.d/S99testf-app
        chmod +x etc/init.d/S99testf-app
        find . | fakeroot cpio -o -H newc --owner root:root > ../new.cpio
        cd ..
    '';

    installPhase = ''
        mkdir -p $out/cpio
        cp new.cpio $out/cpio/rootfs.cpio     
    '';

}
