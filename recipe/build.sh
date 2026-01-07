#!/usr/bin/env bash
set -euxo pipefail

# Create bin directory
mkdir -p "${PREFIX}/bin"

# OpenMPI cross-compilation helper (mainly relevant for osx-arm64 build_platform mapping)
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
  export OPAL_PREFIX="${PREFIX}"
fi

FC=mpifort
CC=mpicc

# Use conda flags
FC_OPTS="${FFLAGS} -O3 -fdefault-real-8 -fdefault-double-8 -fopenmp -ffree-form"
CC_OPTS="${CFLAGS} -O -std=c99"

# Libraries
LDF="-L${PREFIX}/lib -lHYPRE -ljsonfortran -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz"

# Build default binary
make PREFIX="${PREFIX}" \
  FC="${FC}" CC="${CC}" LINKER="${FC}" \
  FC_OPTS="${FC_OPTS}" \
  CC_OPTS="${CC_OPTS}" \
  LDF="${LDF}"

cp -v ./bin/qpad.e "${PREFIX}/bin/qpad.e"

# Build openPMD-enabled binary
make clean
make PREFIX="${PREFIX}" IF_OPENPMD=1 \
  FC="${FC}" CC="${CC}" LINKER="${FC}" \
  FC_OPTS="${FC_OPTS}" \
  CC_OPTS="${CC_OPTS}" \
  LDF="${LDF}"

cp -v ./bin/qpad.e "${PREFIX}/bin/qpad-pmd.e"

