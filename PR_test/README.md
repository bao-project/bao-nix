# Test on exp/bao-tests (@ Bao Hypervisor repo)

Define the current directory as the root directory of the PR test:
```sh
export ROOT_DIR=$(realpath .)
```
Clone the `exp/bao-tests` branch of the Bao hypervisor repo:
```sh
export BAO_EXP_TESTS=$ROOT_DIR/exp-bao-tests
git clone -b exp/bao-tests https://github.com/bao-project/bao-hypervisor.git\
    $BAO_EXP_TESTS
```
Init bao-nix git submodule:
```sh
cd $BAO_EXP_TESTS/tests
git submodule update --init
```

Checkout the submodule to the branch `update/guests-recipes`
```sh
git -C $BAO_EXP_TESTS/tests/bao-nix checkout update/guests-recipes
```

Build the test setup for `qemu-aarch64-virt` (tests compiled 
[here](./exp-bao-tests/tests/src/HELLO.c)):
```sh
cd $ROOT_DIR
nix-build exp-bao-tests.nix --argstr platform qemu-aarch64-virt\
    --argstr list_suites HELLO
```

Finally, run qemu to see the tests logging:
```sh
sh run_qemu.sh
```

To test the other guest recipes, change the [build recipe](exp-bao-tests.nix) as follows:

1. **baremetal-local.nix** - allows to test a baremetal build with local srcs:

Make the following changes in the build recipe:
```diff
-    baremetal = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/guest/baremetal.nix
                { 
                  toolchain = aarch64-none-elf;
                  guest_name = "baremetal";
                  platform_cfg = plat_cfg;
                };
+    baremetal = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/guest/baremetal_local.nix
                { 
                  toolchain = aarch64-none-elf;
                  guest_name = "baremetal";
                  platform_cfg = plat_cfg;
+                 baremetal_srcs_path = ./bao-baremetal-guest;
                };
```

Clone and patch the baremetal srcs from `bao-baremetal-guest` repo, clone the `bao-test` repo, 
and copy the PR test files:
```sh
cd $ROOT_DIR
git clone -b demo https://github.com/bao-project/bao-baremetal-guest.git
```

Build the test setup:
```sh
nix-build exp-bao-tests.nix --argstr platform qemu-aarch64-virt\
    --argstr list_suites HELLO
```

Finally, run qemu to see the tests logging:
```sh
sh run_qemu.sh
```

2. **baremetal-local-tf.nix** - allows to test a baremetal build with local srcs to run tests:

Make the following changes in the build recipe:
```diff
-    baremetal = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/guest/baremetal.nix
                { 
                  toolchain = aarch64-none-elf;
                  guest_name = "baremetal";
                  platform_cfg = plat_cfg;
                };
+    baremetal = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/guest/baremetal_local.nix
                { 
                  toolchain = aarch64-none-elf;
                  guest_name = "baremetal";
                  platform_cfg = plat_cfg;
+                 inherit list_tests; 
+                 inherit list_suites;
                  baremetal_srcs_path = ./bao-baremetal-guest;
                };
```

Clone and patch the baremetal srcs from `bao-baremetal-guest` repo, clone the `bao-test` repo, 
and copy the PR test files:
```sh
cd $ROOT_DIR
git -C ./bao-baremetal-guest apply $ROOT_DIR/baremetal.patch

cd $ROOT_DIR/bao-baremetal-guest
mkdir tests
cp -r $ROOT_DIR/tests/* ./tests
cd ./tests
git clone https://github.com/bao-project/bao-tests.git
```

Then, copy the `testf_entry.c` file to the `bao-test` directory:
```sh
cp $ROOT_DIR/tests/testf_entry.c $ROOT_DIR/bao-baremetal-guest/tests/bao-tests/src
```

Build the test setup:
```sh
cd $ROOT_DIR
nix-build exp-bao-tests.nix --argstr platform qemu-aarch64-virt\
    --argstr list_suites HELLO
```

Finally, run qemu to see the tests logging:
```sh
sh run_qemu.sh
```

3. **baremetal-remote-tf.nix** - allows to test a baremetal build with remote srcs to run tests:

Make the following changes in the build recipe:
```diff
-    baremetal = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/guest/baremetal.nix
                { 
                  toolchain = aarch64-none-elf;
                  guest_name = "baremetal";
                  platform_cfg = plat_cfg;
                };
+    baremetal = callPackage ./exp-bao-tests/tests/bao-nix/pkgs/guest/baremetal_local.nix
                { 
                  toolchain = aarch64-none-elf;
                  guest_name = "baremetal";
                  platform_cfg = plat_cfg;
                  inherit list_tests; 
                  inherit list_suites;
+                 inherit bao-tests;
+                 testf_patch = ./baremetal.patch;
-                 baremetal_srcs_path = ./bao-baremetal-guest;
                };
```

Build the test setup:
```sh
cd $ROOT_DIR
nix-build exp-bao-tests.nix --argstr platform qemu-aarch64-virt\
    --argstr list_suites HELLO
```

Finally, run qemu to see the tests logging:
```sh
sh run_qemu.sh
```