#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add gmp
module add mpfr
module add mpc
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
echo ""
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "Making check"
make check
echo $?
echo "Running Make Install"
make install

mkdir -p modules

echo "Making CI module"
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION. Compiled for GCC ${GCC_VERSION} with OpenMPI version ${OPENMPI_VERSION}"
setenv       FFTW_VERSION       $VERSION
setenv       FFTW_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(FFTW_DIR)/lib
prepend-path FFTW_INCLUDE_DIR   $::env(FFTW_DIR)/include
prepend-path CPATH             $::env(FFTW_DIR)/include
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

mkdir -p ${LIBRARIES}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} ${LIBRARIES}/${NAME}

module avail
#module add  openmpi-x86_64
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
cd ${WORKSPACE}
echo "Working directory is $PWD with : "
ls
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
echo "Compiling serial code"
g++  -L${FFTW_DIR}/lib -I${FFTW_DIR}/include -lfftw3 -lm hello-world.cpp -o hello-world
echo "executing serial code"
./hello-world

# now try mpi version
echo "Compiling MPI code"
mpic++ hello-world-mpi.cpp -L${FFTW_DIR}/lib -I${FFTW_DIR}/include -lfftw3 -lfftw3_mpi  -o hello-world-mpi
#mpic++ -lfftw3 hello-world-mpi.cpp -o hello-world-mpi -L$FFTW_DIR/lib -I$FFTW_DIR/include
echo "executing MPI code for now"
time mpirun -np 2 ./hello-world-mpi
