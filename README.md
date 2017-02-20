# fftw3-deploy

[![Build Status](https://ci.sagrid.ac.za/buildStatus/icon?job=fftw3-deploy)](https://ci.sagrid.ac.za/job/fftw3-deploy)

Build and test scripts necessary to deploy FFTW3

# Versions

We build versions :

  * 3.3.6

# Dependencies

The following dependencies are required by these builds :

  * GCC (several versions)
  * OpenMPI (several versions)


# Build configuration

Using only SSE2 for mixed precision. Configuration is :

```
--prefix=$SOFT_DIR-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} \
--enable-mpi \
--enable-openmp \
--enable-shared \
--enable-threads \
--enable-sse2 \
--with-pic
```

# Citing
