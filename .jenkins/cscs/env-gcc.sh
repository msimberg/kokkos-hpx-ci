# Copyright (c) 2020 ETH Zurich
#
# SPDX-License-Identifier: BSL-1.0
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

export CRAYPE_LINK_TYPE=dynamic
export CXX_STD="17"

module load daint-gpu
module switch PrgEnv-cray PrgEnv-gnu
module load cudatoolkit/11.0.2_3.38-8.1__g5b73779
module load Boost/1.78.0-CrayGNU-21.09
module load hwloc/2.4.1

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

if [[ "${cuda}" == "ON" ]]; then
    configure_extra_options+=" -DCMAKE_CXX_COMPILER=/dev/shm/kokkos/src/bin/nvcc_wrapper"
fi

hpx_configure_extra_options="-DCMAKE_BUILD_TYPE=${build_type}"
hpx_configure_extra_options+=" -DHPX_WITH_EXAMPLES=OFF"
hpx_configure_extra_options+=" -DHPX_WITH_UNITY_BUILD=ON"
hpx_configure_extra_options+=" -DHPX_WITH_MALLOC=system"
hpx_configure_extra_options+=" -DHPX_WITH_NETWORKING=OFF"
hpx_configure_extra_options+=" -DHPX_WITH_DISTRIBUTED_RUNTIME=OFF"
hpx_configure_extra_options+=" -DHPX_WITH_FETCH_ASIO=ON"
hpx_configure_extra_options+=" -DHPX_WITH_CXX_STANDARD=${CXX_STD}"
hpx_configure_extra_options+=" -DHPX_WITH_CUDA=${cuda}"
hpx_configure_extra_options+=" -DHWLOC_ROOT=${EBROOTHWLOC}"
