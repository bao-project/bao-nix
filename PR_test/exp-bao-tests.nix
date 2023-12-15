{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/22.11.tar.gz";
    sha256 = "sha256:11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
  }) {},
  platform ? " ",
  list_tests ? " ",
  list_suites ? " "
}:

with pkgs;

let
  packages = rec {

    plat_cfg = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/platforms/platforms.nix {
      inherit platform;
    };

    aarch64-none-elf = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/toolchains/aarch64-none-elf-11-3.nix{};
    demos = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/demos/demos.nix {};
    bao-tests = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/bao-tests/bao-tests.nix {};
    tests = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/tests/tests.nix {};

# Baremetal Remote
    # baremetal = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/guest/baremetal-remote.nix
    #             { 
    #               toolchain = aarch64-none-elf;
    #               guest_name = "baremetal";
    #               platform_cfg = plat_cfg;
    #             };

# Baremetal Local
    # baremetal = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/guest/baremetal-local.nix
    #             { 
    #               toolchain = aarch64-none-elf;
    #               guest_name = "baremetal";
    #               platform_cfg = plat_cfg;
    #               baremetal_srcs_path = ./bao-baremetal-guest; # /home/diogo/Desktop/bao-git/tests-workspace/bao-nix/PR_test/bao-baremetal-guest;
    #             };

# Baremetal Local TF
    # baremetal = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/guest/baremetal-local-tf.nix
    #             { 
    #               toolchain = aarch64-none-elf;
    #               guest_name = "baremetal";
    #               platform_cfg = plat_cfg;
    #               inherit list_tests; 
    #               inherit list_suites;
    #               baremetal_srcs_path = ./bao-baremetal-guest;
    #             };

# Baremetal Remote TF
    baremetal = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/guest/baremetal-remote-tf.nix
                { 
                  toolchain = aarch64-none-elf;
                  guest_name = "baremetal";
                  platform_cfg = plat_cfg;
                  inherit list_tests; 
                  inherit list_suites;
                  inherit bao-tests;
                  tests_srcs = /home/diogo/Desktop/bao-git/tests-workspace/bao-nix/PR_test/tests;
                  testf_patch = ./baremetal.patch;
                };

    bao = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/bao/bao_tf.nix 
                { 
                  toolchain = aarch64-none-elf; 
                  guest = baremetal; 
                  inherit demos; 
                  platform_cfg = plat_cfg;
                };

    u-boot = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/u-boot/u-boot.nix 
                { 
                  toolchain = aarch64-none-elf; 
                };

    atf = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/atf/atf.nix 
                { 
                  toolchain = aarch64-none-elf; 
                  inherit u-boot; 
                  inherit platform;
                };

    inherit pkgs;
  };
in
  packages


