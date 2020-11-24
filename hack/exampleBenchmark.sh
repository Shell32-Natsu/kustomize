#!/usr/bin/env bash
#
# Copyright 2019 The Kubernetes Authors.
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o pipefail

TMP_DIR=

function prepare {
    # create a place to work
    TMP_DIR=$(mktemp -d -t kustomize-example-benchmark-XXXX)
    echo "Working directory $TMP_DIR"

    # generate benchmark codes
    mdrip --mode print --label testAgainstLatestRelease examples >> $TMP_DIR/benchmark.sh
}

function clean {
    rm -r $TMP_DIR
}

function benchmark {
    # run benchmark codes
    bash $TMP_DIR/benchmark.sh > /dev/null
}

if [ "$1" != "--doIt" ]; then
  echo "Usage: $0 --doIt"
  echo " "
  echo "This script measures performance of kustomize."
  echo "Benchmark resources are from the examples in kustomize"
  echo "repo."
  exit 1
fi

prepare

# edit this value to run multiple times.
loop=1
begin_time=$(date +%s%N)

for ((i = 0; i < $loop; i++))
do
    echo -en "\r$i/$loop..."
    benchmark
done

end_time=$(date +%s%N)
time_diff=$(($end_time - $begin_time))
time_diff_s=$(echo "${time_diff} / 1000 / 1000 / 1000" | bc -l)
echo -e "Time used:"
echo "${time_diff_s}s"

clean
