#!/bin/bash

#Determine which OS you are using
if [ "$(uname)" == "Darwin" ]; then
    if [ $(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}') == "10.13" ]; then
        OS=mac1013
        COMPILER_TYPE=llvm
        COMPILER_VERSION=llvm90
    else
        echo "Bootstrap only works on macOS High Sierra (10.13)"
    fi
elif [ "$(uname)" == "Linux" ]; then
    if [ "$( cat /etc/*-release | grep Scientific )" ]; then
        OS=slc6
    elif [ "$( cat /etc/*-release | grep CentOS )" ]; then
        OS=centos7
    fi
else
    echo "UNKNOWN OS"
    exit 1
fi

#Determine is you have CVMFS installed
if [ ! -d "/cvmfs" ]; then
    echo "No CVMFS detected, please install it."
    exit 1
fi

if [ ! -d "/cvmfs/clicdp.cern.ch" ]; then
    echo "No clicdp CVMFS repository detected, please add it."
    exit 1
fi


#Determine which compiler to use
if [ -z ${COMPILER_TYPE} ]; then
    COMPILER_TYPE="gcc"
fi
if [ ${COMPILER_TYPE} == "gcc" ]; then
    COMPILER_VERSION="gcc8"
fi
if [[ ${COMPILER_TYPE} == "llvm" && ${OS} != "mac1013" ]]; then
    COMPILER_VERSION="llvm6"
fi


#Choose build type
if [ -z ${BUILD_TYPE} ]; then
    BUILD_TYPE=opt
fi


# General variables
CLICREPO=/cvmfs/clicdp.cern.ch
BUILD_FLAVOUR=x86_64-${OS}-${COMPILER_VERSION}-${BUILD_TYPE}

#--------------------------------------------------------------------------------
#     Compiler
#--------------------------------------------------------------------------------

if [[ ${COMPILER_TYPE} == "gcc" && ${OS} != "mac1013" ]]; then
    source ${CLICREPO}/compilers/gcc/8.1.0/x86_64-${OS}/setup.sh
fi
if [[ ${COMPILER_TYPE} == "llvm" && ${OS} != "mac1013" ]]; then
    source ${CLICREPO}/compilers/llvm/6.0.0/x86_64-${OS}/setup.sh
fi

#--------------------------------------------------------------------------------
#     CMake
#--------------------------------------------------------------------------------

export CMAKE_HOME=${CLICREPO}/software/CMake/3.11.1/${BUILD_FLAVOUR}
export PATH=${CMAKE_HOME}/bin:$PATH

#--------------------------------------------------------------------------------
#     Python
#--------------------------------------------------------------------------------

export PYTHONDIR=${CLICREPO}/software/Python/2.7.15/${BUILD_FLAVOUR}
export PATH=${PYTHONDIR}/bin:$PATH
export LD_LIBRARY_PATH=${PYTHONDIR}/lib:${LD_LIBRARY_PATH}

#--------------------------------------------------------------------------------
#     ROOT
#--------------------------------------------------------------------------------

export ROOTSYS=${CLICREPO}/software/ROOT/6.12.06/${BUILD_FLAVOUR}
export PYTHONPATH="$ROOTSYS/lib:$PYTHONPATH"
export PATH="$ROOTSYS/bin:$PATH"
export LD_LIBRARY_PATH="$ROOTSYS/lib:$LD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="$ROOTSYS:$CMAKE_PREFIX_PATH"

#--------------------------------------------------------------------------------
#     Eigen
#--------------------------------------------------------------------------------

export Eigen_HOME=${CLICREPO}/software/Eigen/3.3.4/${BUILD_FLAVOUR}/
export Eigen3_DIR=${Eigen_HOME}/share/eigen3/cmake/
export CMAKE_PREFIX_PATH="$Eigen3_DIR:$CMAKE_PREFIX_PATH"

#--------------------------------------------------------------------------------
#     Ninja
#--------------------------------------------------------------------------------

export Ninja_HOME=${CLICREPO}/software/Ninja/1.8.2/${BUILD_FLAVOUR}
export PATH="$Ninja_HOME:$PATH"

#--------------------------------------------------------------------------------
#     Doxygen
#--------------------------------------------------------------------------------

export Doxygen_HOME=${CLICREPO}/software/Doxygen/1.8.14/${BUILD_FLAVOUR}
export PATH="$Doxygen_HOME/bin:$PATH"
