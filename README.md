# howto
## prerequisites
First of all shpuld install SDL: 
sudo apt-get install libsdl1.2-dev libsdl1.2debian

## usage
in simplest case you need just to source setup.sh script:
> source setup.sh

this will automatically download needed packages (linux, busybox, qemu) and unpack them. After that you can start build by:
> make_all

after while you should have everyting build in $(pwd)/tmp directory
To run your kernel with initial ramdisk type:
> run_qemu -initrd
If you want run kernel with hdd image type:
> run_qemu -hda
