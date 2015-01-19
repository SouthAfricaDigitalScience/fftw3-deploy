module load ci
echo ""
cd $WORKSPACE/$NAME-$VERSION
make check


echo $?

make install # DESTDIR=$SOFT_DIR

mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       FFTW_VERSION       $VERSION
setenv       FFTW_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(FFTW_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(FFTW_DIR)/include
MODULE_FILE
) > modules/$VERSION

mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME

module avail
module add  openmpi-x86_64
module add $NAME/$VERSION

g++ -lfftw3 hello-world.cpp -o hello-world
./hello-world

# now try mpi version
mpic++ -lfftw3 hello-world-mpi.cpp -o hello-world-mpi
mpirun ./hello-world-mpi
