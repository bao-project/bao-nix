# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
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

    linux_image = builtins.path {
        #TODO: change cpio source url
        path = /media/diogo/linux_rootfs_2/bao_dev/bao-linux-test/wrkdir/pack.tar.gz;
    };

    buildInputs = [ cpio fakeroot ];

    unpackPhase = ''
        tar -xvf $linux_image
    '';

    buildPhase = ''
        mkdir -p initramfs
        cd initramfs 
        cpio -idm < ../rootfs.cpio || true
        chmod +x init bin/busybox sbin/init bin/sh
        mkdir -p home/testf
        cp ${linuxApp}/bin/program.out home/testf/testf-app.out
        find . | fakeroot cpio -o -H newc --owner root:root > ../new.cpio
        cd ..
    '';

    installPhase = ''
        mkdir -p $out/cpio
        cp new.cpio $out/cpio/rootfs.cpio     
    '';

}
