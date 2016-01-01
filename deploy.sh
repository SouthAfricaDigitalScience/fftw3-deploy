#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
module add mpc
module add mpfr
module add gmp
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}

echo ${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
make distclean
echo "All tests have passed, will now build into ${SOFT_DIR}-gcc-${GCC_VERSION}"
echo "Configuring the deploy"
CFLAGS='-fPIC' ../configure  \
--prefix=$SOFT_DIR-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} \
--enable-mpi \
--enable-openmp \
--enable-shared \
--enable-static \
--enable-long-double \
--enable-threads \
--enable-sse
make install
echo "Creating the modules file directory ${LIBRARIES_MODULES}"
mkdir -p ${LIBRARIES_MODULES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}
module add gmp
module add mpfr
module add mpc
module add ncurses
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}

module-whatis   "$NAME $VERSION. compiled for OpenMPI ${OPENMPI_VERSION} and GCC version ${GCC_VERSION}"
setenv       FFTW_VERSION       $VERSION
setenv       FFTW_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

prepend-path 	  PATH            $::env(FFTW_DIR)/bin
prepend-path    PATH            $::env(FFTW_DIR)/include
prepend-path    PATH            $::env(FFTW_DIR)/bin
prepend-path    MANPATH         $::env(FFTW_DIR)/man
prepend-path    LD_LIBRARY_PATH $::env(FFTW_DIR)/lib
MODULE_FILE
) > ${LIBRARIES_MODULES}/${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}


# Testing module
module avail
module list
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
echo "PATH is : $PATH"
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
# confirm openmpi

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
echo "executing MPI code"
mpirun ./hello-world-mpi
