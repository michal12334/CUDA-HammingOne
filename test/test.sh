#!/bin/bash

func() {
    echo TEST$1
    ./inputGenerator $2 $3 $4 > in/in$1.in
    ./cpu < in/in$1.in > out/cpuOut$1.out
    ./gpu < in/in$1.in > out/gpuOut$1.out
    diff out/cpuOut$1.out out/gpuOut$1.out
}

g++ -o cpu ../cpuVersion/main.cpp
nvcc -o gpu ../gpuVersion/main.cu
g++ -o inputGenerator ../inputGenerator/main.cpp

mkdir -p in out

for i in {1..1000}
do
    func $i 10 10 4
done

for i in {1001..1500}
do
    func $i 10 1000 5
done

for i in {1501..2000}
do
    func $i 100 1000 60
done


# func 2001 10000 1000 2000

rm cpu
rm gpu
rm inputGenerator
