#!/bin/sh
# build testcase
./build_test.sh $@
# copy test input
if [ -f ./testcase/$@.in ]; then cp ./testcase/$@.in ./test/test.in; fi
# copy test output
if [ -f ./testcase/$@.ans ]; then cp ./testcase/$@.ans ./test/test.ans; fi
# add your own test script here
# Example:
prefix='/mnt/d/courses/CA/cpu4/risc-v-cpu-5011c3efd989cace06541057476bc7a8f8f6bcf5'
# prefix='/mnt/d/courses/CA/cpu1/cpu1.srcs/sources_1/new'
path='/mnt/d/courses/CA/Arch2019_Assignment-master/riscv'

cp -rf ${prefix}/* ${path}
cp ./test/test.data ${path}

iverilog -o ${path}/cpu  ${path}/testbench/*.v ${path}/*.v ${path}/common/block_ram/*.v ${path}/common/fifo/*.v ${path}/common/uart/*.v


vvp ${path}/cpu 
#> ${path}/cpu.out

#tail -n +2 ${path}/my.tmp > ${path}/my.out

#cat ${path}/my.out

# - diff ./test/test.ans ./test/test.out
