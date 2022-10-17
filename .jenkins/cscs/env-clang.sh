# Copyright (c) 2020 ETH Zurich
#
# SPDX-License-Identifier: BSL-1.0
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

export CRAYPE_LINK_TYPE=dynamic
export APPS_ROOT="/apps/daint/SSL/HPX/packages"
export CXX_STD="17"
export HWLOC_ROOT="${APPS_ROOT}/hwloc-2.0.3-gcc-8.3.0"

module load daint-gpu
module load cudatoolkit/11.0.2_3.38-8.1__g5b73779
module load Boost/1.78.0-CrayGNU-21.09
module switch PrgEnv-gnu PrgEnv-cray

export CXX=`which CC`
export CC=`which cc`

configure_extra_options="-DCMAKE_BUILD_TYPE=${build_type}"
configure_extra_options+=" -DKokkos_ENABLE_TESTS=ON"
configure_extra_options+=" -DCMAKE_CXX_STANDARD=${CXX_STD}"
configure_extra_options+=" -DKokkos_ENABLE_SERIAL=OFF"
configure_extra_options+=" -DKokkos_ENABLE_HPX=ON"
configure_extra_options+=" -DKokkos_ENABLE_HPX_ASYNC_DISPATCH=${async_dispatch}"
configure_extra_options+=" -DKokkos_ENABLE_CUDA=${cuda}"
configure_extra_options+=" -DKokkos_ENABLE_CUDA_LAMBDA=${cuda}"
configure_extra_options+=" -DKokkos_ENABLE_CUDA_CONSTEXPR=${cuda}"
configure_extra_options+=" -DKokkos_ARCH_HSW=ON"
configure_extra_options+=" -DKokkos_ARCH_PASCAL60=${cuda}"

hpx_configure_extra_options="-DCMAKE_BUILD_TYPE=Debug"
hpx_configure_extra_options+=" -DHPX_WITH_EXAMPLES=OFF"
hpx_configure_extra_options+=" -DHPX_WITH_UNITY_BUILD=ON"
hpx_configure_extra_options+=" -DHPX_WITH_MALLOC=system"
hpx_configure_extra_options+=" -DHPX_WITH_NETWORKING=OFF"
hpx_configure_extra_options+=" -DHPX_WITH_DISTRIBUTED_RUNTIME=OFF"
hpx_configure_extra_options+=" -DHPX_WITH_FETCH_ASIO=ON"
hpx_configure_extra_options+=" -DHPX_WITH_CXX_STANDARD=${CXX_STD}"
hpx_configure_extra_options+=" -DHPX_WITH_CUDA=${cuda}"
hpx_configure_extra_options+=" -DCMAKE_CUDA_COMPILER=$(which $CXX)"
hpx_configure_extra_options+=" -DCMAKE_CUDA_ARCHITECTURES=60"

# This is a workaround for a bug in the Cray clang compiler and/or Boost. When
# compiling in device mode, Boost detects that float128 is available, but
# compilation later fails with an error message saying float128 is not
# available for the target.
#
# This sets a custom Boost user configuration, which is a concatenation of the
# clang and nvcc compiler configurations, with the exception that
# BOOST_HAS_FLOAT128 is unconditionally disabled.
#
# This also sets the Kokkos HPX backend implementation, because it has to be
# passed in the same variable.
export CXXFLAGS="-I/dev/shm/hpx/src/.jenkins/cscs/ -DBOOST_USER_CONFIG='<boost_user_config_cray_clang.hpp>'"
