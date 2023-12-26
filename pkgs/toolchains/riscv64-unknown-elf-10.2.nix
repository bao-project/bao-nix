# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ lib
, stdenv
, fetchurl
, ncurses5
, python38
, zlib
}:

stdenv.mkDerivation rec {
  pname = "riscv64-unknown-elf";
  version = "1.0.0";
  arch = "x86_64";

  src = fetchurl {
    url = "https://static.dev.sifive.com/dev-tools/freedom-tools/v2020.12/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-${arch}-linux-ubuntu14.tar.gz";
    sha256 = "sha256-vYVyQrfGSxqYxWs1vIAYZKxCBdA/ODxwEKkMXQu5VJo=";
  };

  nativeBuildInputs = [ zlib ]; #build time dependencies


  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';

  # Package -> put the binaries with nix store paths
  preFixup = ''
    find $out -type f | while read f; do
      patchelf "$f" > /dev/null 2>&1 || continue
      patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) "$f" || true
      patchelf --set-rpath ${lib.makeLibraryPath [ "$out" stdenv.cc.cc ncurses5 python38 zlib]} "$f" || true
    done
  '';

}


