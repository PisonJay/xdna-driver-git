# Maintainer: Pison Jay <PisonJay@outlook.com>

pkgrel=1
arch=(x86_64)
pkgver=r310.8d79b38
url='https://github.com/amd/xdna-driver'
license=(Apache)

depends=(
    boost
    libtiff
    dkms
    elfutils
    gcc
    gdb
    gnuplot
    gnutls
    gtest
    json-glib
    curl
    libdrm
    libffi
    libjpeg-turbo
    util-linux-libs
    libyaml
    lm_sensors
    ncurses
    ocl-icd
    opencl-headers
    openssl
    pciutils
    perf
    protobuf
    python
    python-pip
    rapidjson
    strace
    unzip
    zlib
    pybind11
)

makedepends=(
    cmake
    git
)
options=(!debug !strip)

source=(
    xdna-driver::git+https://github.com/amd/xdna-driver
    xrt::git+https://github.com/Xilinx/XRT
    dma_ip_drivers::git+https://github.com/Xilinx/dma_ip_drivers.git
    elf::git+https://github.com/serge1/ELFIO.git
    gsl::git+https://github.com/microsoft/GSL.git
    aiebu::git+https://github.com/Xilinx/aiebu.git
    aie-rt::git+https://github.com/Xilinx/aie-rt.git#branch=release/main_aig
    1502_00.sbin::https://gitlab.com/kernel-firmware/drm-firmware/-/raw/amd-ipu-staging/amdnpu/1502_00/npu.sbin.1.4.2.329
    17f0_00.sbin::https://gitlab.com/kernel-firmware/drm-firmware/-/raw/amd-ipu-staging/amdnpu/17f0_00/npu.sbin.0.7.22.185
    17f0_10.sbin::https://gitlab.com/kernel-firmware/drm-firmware/-/raw/amd-ipu-staging/amdnpu/17f0_10/npu.sbin.0.7.35.35
    17f0_11.sbin::https://gitlab.com/kernel-firmware/drm-firmware/-/raw/amd-ipu-staging/amdnpu/17f0_11/npu.sbin.0.7.35.139
    99-amdxdna.rules
    0001-Revert-bitfield-for-__counted_by-attribute.patch
    0002-make-xdna-driver-compile-on-linux-amd-drm-next.patch
)
sha256sums=('SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'cdebef73283a4ca8e10d65bb0b18da46dd3b71a6e17f57216732c9e1761040b6'
            'e87bd717207fa940c502f813e360c712c6d87a53da5358fc1c31efca736ed33a'
            '5c19e5e77db4d8069ecfbbff81c66bff60777b77ddc555c17c5b15c673313816'
            '00d6dac7546ccc8d5b52a4679a11ff5a02f2df41639cd9ab2cad6a643726b45a'
            'ebf17c2e000c52fb31b1abfba1ce41a107dc8d277925e8644cddac2e3c41b1d9'
            '50431cf83e8caf5601b337f6af067b3ab0e700354db99c7b97d6c3124fe08b27'
            'c58ec8a07ca436ffa9857165a558b720f6a1ba156438a2c3a3d0b9395736d0ca')
prepare() {
    cd $srcdir/xdna-driver
    git submodule init
    git config submodule.xrt.url $srcdir/xrt
    git -c protocol.file.allow=always submodule update
    cat ../*.patch | git am
    
    pushd $srcdir/xdna-driver/xrt
    git checkout master
    git submodule init
    git config submodule.src/runtime_src/core/pcie/driver/linux/xocl/lib/libqdma.url $srcdir/dma_ip_drivers
    git config submodule.src/runtime_src/core/common/elf.url $srcdir/elf
    git config submodule.src/runtime_src/core/common/gs.url $srcdir/gsl
    git config submodule.src/runtime_src/core/common/aiebu.url $srcdir/aiebu
    git -c protocol.file.allow=always submodule update

    cd src/runtime_src/core/common/aiebu
    git submodule init
    git config submodule.lib/aie-rt.url $srcdir/aie-rt
    git config submodule.src/cpp/ELFIO.url $srcdir/elf
    git -c protocol.file.allow=always submodule update

    popd
    git commit -am "Bump xrt submodule version"
}
build() {
    # build XRT first
    cd $srcdir/xdna-driver/xrt
    mkdir -p clean-build && cd clean-build
    cmake_flags="-DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_INSTALL_PREFIX=/opt/xilinx -DXRT_ENABLE_WERROR=0 -DXRT_INSTALL_PREFIX=/opt/xilinx -DCMAKE_BUILD_TYPE=Release"
    cmake $cmake_flags ../src
    make -j$(nproc)

    # build xdma-driver
    cd $srcdir/xdna-driver
    mkdir -p clean-build && cd clean-build
    cmake -DCMAKE_INSTALL_PREFIX=/opt/xilinx \
        -DXRT_INSTALL_PREFIX=/opt/xilinx \
        -DCMAKE_BUILD_TYPE=Release -DUMQ_HELLO_TEST=n \
        ..
    make -j$(nproc)
}
pkgname=(xrt-git xdna-driver-git)

pkgver() {
    cd $srcdir/xdna-driver
	printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package_xrt-git() {
    # pkgver=$(_pkgver $srcdir/xdna-driver/xrt)
    pkgdesc="Xilinx runtime for Ultrascale, Versal and MPSoC-based FPGAs"
    provides=(xrt)
    conflicts=(xrt)
    url="https://xilinx.github.io/XRT/master/html/index.html"
    cd $srcdir/xdna-driver/xrt/clean-build
    DESTDIR=$pkgdir make -j$(nproc) install
    mv $pkgdir/usr/local/* $pkgdir/usr
    rm -rf $pkgdir/usr/local
}

devids=(1502_00 17f0_00 17f0_10 17f0_11)

package_xdna-driver-git() {
    # pkgver=$(_pkgver $srcdir/xdna-driver/xdma-driver)
    pkgdesc="AMD XDNA driver for NPU"
    provides=(xdna-driver)
    conflicts=(xdna-driver)
    url='https://github.com/amd/xdna-driver'
    cd $srcdir/xdna-driver/clean-build
    DESTDIR=$pkgdir make -j$(nproc) install
    rm -rf $pkgdir/bins

    # install firmware
    for devid in ${devids[@]}; do
        install -Dm644 $srcdir/$devid.sbin $pkgdir/usr/lib/firmware/amdnpu/$devid/npu.sbin
    done

    # dkms
    DRV_SRC_DIR=$pkgdir/opt/xilinx/xrt/amdxdna
    DKMS_PKG_NAME=`cat ${DRV_SRC_DIR}/dkms.conf | grep ^PACKAGE_NAME | awk -F= '{print $2}' | tr -d '"'`
    DKMS_PKG_VER=`cat ${DRV_SRC_DIR}/dkms.conf | grep ^PACKAGE_VERSION | awk -F= '{print $2}' | tr -d '"'`
    DKMS_DRV_DIR_NAME=${DKMS_PKG_NAME}-${DKMS_PKG_VER}
    DKMS_DRV_DIR=$pkgdir/usr/src/${DKMS_DRV_DIR_NAME}
    install -d ${DKMS_DRV_DIR}
    install -Dm644 $DRV_SRC_DIR/dkms.conf $DKMS_DRV_DIR/dkms.conf
    pushd $DKMS_DRV_DIR
    tar -xf $DRV_SRC_DIR/amdxdna.tar.gz
    popd
    rm $DRV_SRC_DIR/{amdxdna.tar.gz,dkms.conf,dkms_driver.sh}

    # udev rules
    udev_rules_d=$pkgdir/usr/lib/udev/rules.d
    amdxdna_rules_file=99-amdxdna.rules
    install -Dm644 $srcdir/99-amdxdna.rules ${udev_rules_d}/${amdxdna_rules_file}
}
