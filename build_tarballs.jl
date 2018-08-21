using BinaryBuilder

name = "FLAC"
version = v"1.3.2"

# Collection of sources required to build Ipopt
sources = [
    "https://downloads.xiph.org/releases/flac/flac-1.3.2.tar.xz" =>
    "91cfc3ed61dc40f47f050a109b08610667d73477af6ef36dcad31c31a4a8d53f",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/flac-*

# For programs with older configure steps, we often need to update and regenerate them
update_configure_scripts
autoreconf -i -f

# Do the building dance
./configure --prefix=${prefix} --host=${target} --disable-avx
make -j${nproc} V=1
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line.
platforms = supported_platforms()

dependencies = [
    # We want libogg to power up our FLAC
    "https://github.com/staticfloat/OggBuilder/releases/download/v1.3.3-7/build.jl",
]

# The products that we will ensure are always built
products = prefix -> [
    LibraryProduct(prefix, "libFLAC", :libflac),
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
