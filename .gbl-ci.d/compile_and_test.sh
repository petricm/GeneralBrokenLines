#!/bin/bash

source /GBL/.gbl-ci.d/init_x86_64.sh

cd /GBL/cpp
mkdir build
cd build
cmake -GNinja .. && \
ninja
