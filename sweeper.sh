#!/bin/bash

MIN_THREADS=32
MAX_THREADS=32
MIN_M=64
MAX_M=128
MIN_K=256*256
MAX_K=256*256
MIN_N=64
MAX_N=128

path=$1

# Extract algorithm name
IFS='/' read -ra algArr <<< "$path"
len=${#algArr[@]}
alg=${algArr[$len-1]}
if [ ${alg: -2} != ".c" ]; then
  echo -e "\e[0;31mERROR: You must pass in only .c files\e[0m"
  rm data_gatherer
  exit
fi
alg="${alg%??}"

echo -e "\e[01;34mcompiling $alg...\e[0m"

icc -mkl -o data_gatherer -O3 -ipo -xHOST -no-prec-div -fno-strict-aliasing -fno-omit-frame-pointer data_gatherer.c $path

echo -e "\e[0;32mrunning $alg...\e[0m"

export MKL_DYNAMIC=FALSE

if [ `echo $alg | tr [:upper:] [:lower:]` = "mkl" ]; then
  MKL=true
else
  MKL=false
fi

for (( threads=$MIN_THREADS; threads<=$MAX_THREADS; threads*=2 )); do
  if $MKL; then
    export MKL_NUM_THREADS=$threads
  else
    export MKL_NUM_THREADS=1
    export CILK_NWORKERS=$threads
  fi

  for (( m=$MIN_M; m<=$MAX_M; m*=2 )); do
    for (( k=$MIN_K; k<=$MAX_K; k*=2 )); do
      for (( n=$MIN_N; n<=$MAX_N; n*=2 )); do
        ./data_gatherer $alg $m $k $n $threads
      done
    done
  done
done

rm data_gatherer