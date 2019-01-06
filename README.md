# os-dev  

git clone https://github.com/alanvivona/os-dev.git  
cd os-dev  
sudo docker run --mount src=(pwd)/dev,target=/shared,type=bind joshwyant/gcc-cross /shared/utils/gen-kernel  
qemu-system-i386 -kernel dev/bin/kernel-20190106195936.elf  

