# Bao Nix Packages  

This repo provides a set of nix recipes (i.e., packages) to be used by
[bao-tests](https://github.com/bao-project/bao-tests). The recipes are used to 
define all necessary tools and dependencies required to build the software stack
, e.g., compilers, cross-compilers, build utilities, and specific libraries.

---

## -1. Install dependencies

Install Nix:

```
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

## 1. Setup environment

Clone this repo and cd to it:

```
git clone https://github.com/bao-project/bao-nix.git
cd bao-nix
```

Or add it as a submodule:

```
git submodule add https://github.com/bao-project/bao-nix.git
cd bao-nix
```

---
<!-- ## 2. Use the Packages

You need to create a defautl.nix recipe. This recipe should call several 
packages to define a test setup.  -->

<!-- Just execute:

**Note:** For now, only qemu-aarch64-virt is supported [Appendix I](#Appendix-I).
```
nix-build --argstr platform qemu-aarch64-virt --argstr list_tests TEST_A --argstr list_suites ABCD

```

And all the needed source and images will be automatically downloaded and built. 

---

## 3. Deploy the environment

If you are targetting an emulator platform like QEMU, after building 
you can start it with:

```
./run_qemu.sh
```

In this case, if you don't have qemu for the target architecture installed, 
it will build it for you.

--- -->

<!-- ## Appendix I -->
## 3. Supported Platforms

| | PLATFORM | ARCH
|--|--|--|
| QEMU Aarch64 virt | qemu-aarch64-virt | aarch64
<!-- | Xilinx ZCU102 | zcu102 | aarch64 -->
<!-- | Xilinx ZCU104 | zcu104 | aarch64 -->
<!-- | NXP i.MX8QM | imx8qm | aarch64 -->
<!-- | Nvidia TX2 | tx2 | aarch64 -->
<!-- | Raspberry 4 Model B | rpi4 | aarch64 -->
<!-- | QEMU RV64 virt | qemu-riscv64-virt | riscv64 -->
<!-- TODO -->
<!-- | NXP i.MX8MQ | imx8mq | -->
<!-- | Avnet Ultra96 | ultra96 | -->
<!-- | Rocket on ZynqMP | rocket-fpga | -->
<!-- | Rocket on Firesim | rocket-firesim | -->
<!-- | Hikey 960 | hikey960 | -->
<!-- | Rock 960 | rock960 | -->

---
