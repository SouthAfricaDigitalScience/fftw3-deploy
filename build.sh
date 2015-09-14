#!/bin/bash

module add ci
module add openmpi
# first check if the directory has been checked out at all
SOURCE_FILE=$NAME-$VERSION.tar.gz


echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p $WORKSPACE
mkdir -p $SRC_DIR
mkdir -p $SOFT_DIR

#  Download the source file

if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
  echo "seems like this is the first build - let's get the source"
  mkdir -p $SRC_DIR
  wget $URL/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
else
  echo "continuing from previous builds, using source at " $SRC_DIR/$SOURCE_FILE
fi
tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
cd $WORKSPACE/$NAME-$VERSION
./configure --prefix $SOFT_DIR --enable-mpi --enable-shared CFLAGS='-fPIC'
make -j 8
