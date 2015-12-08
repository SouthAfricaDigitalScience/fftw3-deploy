#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
# first check if the directory has been checked out at all
SOURCE_FILE=${NAME}-${VERSION}.tar.gz

echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  mkdir -p $SRC_DIR
  wget http://www.fftw.org/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
tar -xvzf ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE}
cd ${WORKSPACE}/${NAME}-${VERSION}
mkdir build-${BUILD_NUMBER}
cd build-${BUILD_NUMBER}
CFLAGS='-fPIC' ../configure --prefix $SOFT_DIR-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} --enable-mpi --enable-shared --enable-static
make
