using BinaryBuilder

# Collection of sources required to build Ipopt
sources = [
    "https://downloads.xiph.org/releases/flac/flac-1.3.2.tar.xz" =>
    "91cfc3ed61dc40f47f050a109b08610667d73477af6ef36dcad31c31a4a8d53f",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/flac-1.3.2

# We need to add ${prefix}/lib onto the end of $LD_LIRBARY_PATH because ./configure
# here is going to try and run programs that link against libogg, but don't set their
# RPATH's properly.  Le sigh.
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${prefix}/lib

# Do the building dance
./configure --prefix=${prefix} --host=${target} --disable-avx --enable-ogg --disable-oggtest
make -j${nproc} V=1
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line.
platforms = [
    Windows(:i686),
    Windows(:x86_64),
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    # These don't work yet
    #Linux(:aarch64, :glibc),
    #Linux(:armv7l, :glibc),
    #Linux(:powerpc64le, :glibc),
    MacOS(),
]


dependencies = [
    # We want libogg to power up our FLAC
    "https://github.com/staticfloat/OggBuilder/releases/download/v1.3.3-2/build.jl",
]

# The products that we will ensure are always built
products = prefix -> [
    LibraryProduct(prefix, "libFLAC", :libflac),
]

build_tarballs(ARGS, "FLAC", sources, script, platforms, products, dependencies)
