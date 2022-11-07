#!/bin/bash -l

# Copyright (c) 2020 ETH Zurich
#
# SPDX-License-Identifier: BSL-1.0
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

set -eux

orig_src_dir="$(pwd)"
src_dir="/dev/shm/kokkos-hpx-ci/src"
build_dir="/dev/shm/kokkos-hpx-ci/build"

# Copy source directory to /dev/shm for faster builds
mkdir -p "${build_dir}"
cp -r "${orig_src_dir}" "${src_dir}"

source ${src_dir}/.jenkins/cscs/env-common.sh
source ${src_dir}/.jenkins/cscs/env-${configuration_name}.sh

git clone \
    --branch ${hpx_version} \
    --single-branch \
    --depth 1 \
    https://github.com/STEllAR-GROUP/hpx.git /dev/shm/hpx/src
cmake \
    -S /dev/shm/hpx/src \
    -B /dev/shm/hpx/build \
    -DCMAKE_INSTALL_PREFIX=/dev/shm/hpx/install \
    ${hpx_configure_extra_options}
cmake --build /dev/shm/hpx/build
cmake --install /dev/shm/hpx/build

kokkos_src_dir="/dev/shm/kokkos/src"
kokkos_build_dir="/dev/shm/kokkos/build"

git clone \
    --branch ${kokkos_version} \
    --single-branch \
    --depth 1 \
    https://github.com/msimberg/kokkos.git "${kokkos_src_dir}"

# Copy CTest config file to Kokkos root, where it will be found by CTest
cp "${src_dir}/CTestConfig.cmake" "${kokkos_src_dir}"

set +e
ctest \
    --verbose \
    -S ${src_dir}/.jenkins/cscs/ctest.cmake \
    -DCTEST_CONFIGURE_EXTRA_OPTIONS="${configure_extra_options} -DHPX_DIR=/dev/shm/hpx/install/lib64/cmake/HPX" \
    -DCTEST_BUILD_CONFIGURATION_NAME="${configuration_name_with_options}" \
    -DCTEST_SOURCE_DIRECTORY="${kokkos_src_dir}" \
    -DCTEST_BINARY_DIRECTORY="${kokkos_build_dir}"
set -e

# Copy the testing directory for saving as an artifact
cp -r "${kokkos_build_dir}/Testing" ${orig_src_dir}/${configuration_name_with_options}-Testing

# Things went wrong by default
ctest_exit_code=$?
file_errors=1
configure_errors=1
build_errors=1
test_errors=1
if [[ -f ${kokkos_build_dir}/Testing/TAG ]]; then
    file_errors=0
    tag="$(head -n 1 ${kokkos_build_dir}/Testing/TAG)"

    if [[ -f "${kokkos_build_dir}/Testing/${tag}/Configure.xml" ]]; then
        configure_errors=$(grep '<Error>' "${kokkos_build_dir}/Testing/${tag}/Configure.xml" | wc -l)
    fi

    if [[ -f "${kokkos_build_dir}/Testing/${tag}/Build.xml" ]]; then
        build_errors=$(grep '<Error>' "${kokkos_build_dir}/Testing/${tag}/Build.xml" | wc -l)
    fi

    if [[ -f "${kokkos_build_dir}/Testing/${tag}/Test.xml" ]]; then
        test_errors=$(grep '<Test Status=\"failed\">' "${kokkos_build_dir}/Testing/${tag}/Test.xml" | wc -l)
    fi
fi
ctest_status=$((ctest_exit_code + file_errors + configure_errors + build_errors + test_errors))

echo "${ctest_status}" >"jenkins-kokkos-${configuration_name_with_options}-ctest-status.txt"
exit $ctest_status
