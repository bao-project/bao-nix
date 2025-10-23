{ stdenv
, fetchFromGitHub
, toolchain
, u-boot
, openssl
, dtc
, platform
, arch ? "aarch64"
, setup-cfg
}:

stdenv.mkDerivation rec {
  pname = "atf";
  version = "bao/demo";

  src = fetchFromGitHub {
    owner = "bao-project";
    repo = "arm-trusted-firmware";
    rev = "4487d59f811f987232796870c578a0831136d3a2"; #branch: bao/demo
    sha256 = "sha256-KQdsoBlqhYQWmsPRBXHxV8s+g6hn0gniOcs/qN8xwEY=";
  };

  nativeBuildInputs = [ toolchain u-boot openssl dtc ];

  buildPhase = ''
    export CROSS_COMPILE=aarch64-none-elf-
    gic_version=$(echo "${setup-cfg.irq_flags}" | grep -oP '(?<=GIC_VERSION=)[^ ]+')
  
    if [ "${platform}" == "qemu-aarch64-virt" ]; then
      make PLAT=qemu bl1 fip BL33=${u-boot}/bin/u-boot.bin \
           QEMU_USE_GIC_DRIVER=QEMU_$gic_version
    elif [ "${platform}" == "fvp-a" ]; then
      make PLAT=fvp bl1 fip BL33=${u-boot}/bin/u-boot.bin \
           QEMU_USE_GIC_DRIVER=QEMU_$gic_version ARCH=${arch}
    fi
  '';

  installPhase = ''
    mkdir -p $out/bin/${platform}

    if [ "${platform}" == "qemu-aarch64-virt" ]; then
      dd if=./build/qemu/release/bl1.bin      of=$out/bin/${platform}/flash.bin
      dd if=./build/qemu/release/fip.bin      of=$out/bin/${platform}/flash.bin seek=64 bs=4096 conv=notrunc
    elif [ "${platform}" = "fvp-a" ] || [ "${platform}" = "fvp-a-aarch32" ]; then
      cp ./build/fvp/release/bl1.bin      $out/bin/${platform}/
      cp ./build/fvp/release/fip.bin      $out/bin/${platform}/
    fi
  '';
}
