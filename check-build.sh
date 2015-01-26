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
prepend-path FFTW_INCLUDE_DIR   $::env(FFTW_DIR)/include
prepend-path CPATH             $::env(FFTW_DIR)/include
MODULE_FILE
) > modules/$VERSION

mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME

module avail
#module add  openmpi-x86_64
module add $NAME/$VERSION
cd $WORKSPACE
echo "Working directory is $PWD with : "
ls
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
echo "Compiling serial code"
g++ -lfftw3 hello-world.cpp -o hello-world -L$FFTW_DIR/lib
echo "executing serial code"
./hello-world

# now try mpi version
echo "Compiling MPI code"
mpic++ hello-world-mpi.cpp -lfftw3l -lfftw3_mpi  -lfftw3 -L$FFTW_DIR/lib -I$FFTW_DIR/include -o hello-world-mpi
#mpic++ -lfftw3 hello-world-mpi.cpp -o hello-world-mpi -L$FFTW_DIR/lib -I$FFTW_DIR/include
echo "Executing MPI code"
mpirun ./hello-world-mpi
