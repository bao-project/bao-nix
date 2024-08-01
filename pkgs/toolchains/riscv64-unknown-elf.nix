# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ lib
, stdenv
, fetchurl
, ncurses5
, python38
, libmpc
, rsync
, mpfr
, gmp
, zlib
, zstd
}:

stdenv.mkDerivation rec {
  pname = "riscv64-unknown-elf";
  version = "1.0.0";
  arch = "x86_64";

  src = fetchurl {
    url = "https://github.com/bao-project/bao-riscv-toolchain/releases/download/gc891d8dc23e/riscv-unknown-elf-13.2.0-ubuntu-22.04.tar.gz";
    sha256 = "sha256-MMKEFVwIl3wGwSZDHmvpVzEWsgpc6ePaX5kTrzyVfL0=";
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
      patchelf --set-rpath ${lib.makeLibraryPath [ "$out" stdenv.cc.cc ncurses5 python38 zlib libmpc mpfr gmp zstd]} "$f" || true
    done
  '';

}


