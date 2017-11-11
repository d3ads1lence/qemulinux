#!/bin/bash

KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.13.11.tar.xz"
QEMU_URL="https://download.qemu.org/qemu-2.10.1.tar.xz"
BUSYBOX_URL="https://busybox.net/downloads/busybox-1.27.2.tar.bz2"

LINUX_PKG="linux-4.13.11.tar.xz"
QEMU_PKG="qemu-2.10.1.tar.xz"
BUSYBOX_PKG="busybox-1.27.2.tar.bz2"

function prepare_dirs {
	mkdir -p srcdir
	mkdir -p src
	mkdir -p tmp/linux
	mkdir -p tmp/busybox
	mkdir -p tmp/qemu
    mkdir -p tmp/initramfs
}

function download_all {
	cd srcdir
	if [ ! -f ${LINUX_PKG} ]; then wget ${KERNEL_URL}; fi
	if [ ! -f ${QEMU_PKG} ]; then wget ${QEMU_URL}; fi
	if [ ! -f ${BUSYBOX_PKG} ]; then wget ${BUSYBOX_URL}; fi
	cd ..
}

function unpack_all {
	cd src
	if [ ! -d "linux" ]; then tar xvf ../srcdir/${LINUX_PKG} && mv linux-4.13.11 linux; fi
    	if [ ! -d "busybox" ]; then tar xvf ../srcdir/${BUSYBOX_PKG} && mv busybox-1.27.2 busybox; fi
    	if [ ! -d "qemu" ]; then tar xvf ../srcdir/${QEMU_PKG} && mv qemu-2.10.1 qemu; fi
    	cd ..
}

function configure_linux {
        cd src/linux
        make O=../../tmp/linux x86_64_defconfig
        cd -
}

function build_linux {
        cd src/linux
        make O=../../tmp/linux 
        cd -
}

function configure_busybox {
        cd src/busybox
        make defconfig
        echo "CONFIG_STATIC=y" >> ../../tmp/busybox/.config
        cd -
}

function build_busybox {
        cd src/busybox
        make
        make CONFIG_PREFIX=../../tmp/busybox install
        cd -
}

function configure_qemu {
        cd src/qemu
        ./configure --prefix=$(pwd)/../../tmp/qemu
        cd -
}

function build_qemu {
        cd src/qemu
        make -j8
        make install
        cd -
}


function build_initramfs {
        cd tmp/initramfs
        mkdir -pv {bin,dev,etc,home,mnt,proc,sys,usr}
        cd ./dev 
        sudo mknod sda b 8 0 
	sudo mknod console c 5 1
        cp ../../init .
        chmod +x init
	cp -av ../../tmp/busybox/* .
	find . -print0 | cpio --null -ov --format=newc > rootfs.cpio 
	gzip ./rootfs.cpio
        cd -
}


function make_all {
        configure_linux
        configure_busybox
        configure_qemu

        build_linux
        build_busybox
        build_qemu
        build_initramfs
}

function run_qemu {
        tmp/qemu/bin/qemu-system-x86_64 \
        		-kernel tmp/linux/arch/x86/boot/bzImage \
                -initrd tmp/initramfs/rootfs.cpio.gz \
                -nographic -append "console=ttyS0"
}

prepare_dirs
download_all
unpack_all