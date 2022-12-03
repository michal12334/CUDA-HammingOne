#!/bin/bash

g++ -o cpu ../cpuVersion/main.cpp
nvcc -o gpu ../gpuVersion/main.cu
g++ -o inputGenerator ../inputGenerator/main.cpp

mkdir -p in out

for i in {1..1000}
do
    echo TEST$i
    ./inputGenerator 10 1000 4 > in/in$i.in
    ./cpu < in/in$i.in > out/cpuOut$i.out
    ./gpu < in/in$i.in > out/gpuOut$i.out
    diff out/cpuOut$i.out out/gpuOut$i.out
done

rm cpu
rm gpu
rm inputGenerator
