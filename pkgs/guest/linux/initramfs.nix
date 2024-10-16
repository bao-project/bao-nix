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
        path = /home/mafs/bao-demos/images/output/pack.tar.gz;
    };

    buildInputs = [ cpio fakeroot ];

    unpackPhase = ''
        tar -xvf $linux_image
    '';

    buildPhase = ''
        mkdir -p initramfs
        cd initramfs 
        cpio -idm  < ../rootfs.cpio || true
        chmod +x init bin/busybox sbin/init bin/sh
        cp ${linuxApp}/bin/program.out home/testf/testf-app.out
        find . | cpio -o -H newc --owner root:root > ../new.cpio
        cd ..
    '';

    installPhase = ''
        mkdir -p $out/cpio
        cp new.cpio $out/cpio/rootfs.cpio     
    '';

}
