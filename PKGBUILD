# Maintainer: Pison Jay <PisonJay@outlook.com>
# Based on xrt-git PKGBUILD by Gökçe Aydos <aur2024@aydos.de>

pkgrel=1
arch=(x86_64)
pkgver=r351.0d43441
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
    1502_00.sbin::https://gitlab.com/kernel-firmware/drm-firmware/-/raw/amd-ipu-staging/amdnpu/1502_00/npu.sbin.1.5.2.378
    17f0_00.sbin::https://gitlab.com/kernel-firmware/drm-firmware/-/raw/amd-ipu-staging/amdnpu/17f0_00/npu.sbin.0.7.22.185
    17f0_10.sbin::https://gitlab.com/kernel-firmware/drm-firmware/-/raw/amd-ipu-staging/amdnpu/17f0_10/npu.sbin.1.0.0.61
    17f0_11.sbin::https://gitlab.com/kernel-firmware/drm-firmware/-/raw/amd-ipu-staging/amdnpu/17f0_11/npu.sbin.1.0.0.164
    99-amdxdna.rules
#    0001-Revert-bitfield-for-__counted_by-attribute.patch
#    0002-make-xdna-driver-compile-on-linux-amd-drm-next.patch
#    0003-updated-dpu-validate-bin.patch
)
sha256sums=('SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            '6b9a3a645818abad79bf5d670cb457718343b5fa553bdc7a173c71307913bcd9'
            'e87bd717207fa940c502f813e360c712c6d87a53da5358fc1c31efca736ed33a'
            '46dbfa0c0f60748083297cb36a53bb598cde22ac315b1a033905a07f231d10a1'
            'c0c11be5c759648a4b6a080118f53a5eca75dca1633d15ec3b71fe7455f24e83'
            'ebf17c2e000c52fb31b1abfba1ce41a107dc8d277925e8644cddac2e3c41b1d9'
            )
prepare() {
    cd $srcdir/xdna-driver
    git submodule init
    git config submodule.xrt.url $srcdir/xrt
    git -c protocol.file.allow=always submodule update
    cat ../*.patch | git am --whitespace=fix --reject 
    
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
    cp -r $srcdir/xdna-driver/tools/bins ${DRV_SRC_DIR}
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
