using BinaryBuilder

platforms = [
  BinaryProvider.Windows(:i686),
  BinaryProvider.Windows(:x86_64),
  BinaryProvider.Linux(:i686, :glibc),
  BinaryProvider.Linux(:x86_64, :glibc),
  #BinaryProvider.Linux(:aarch64, :glibc),
  #BinaryProvider.Linux(:armv7l, :glibc),
  #BinaryProvider.Linux(:powerpc64le, :glibc),
  BinaryProvider.MacOS()
]

sources = [
    "https://downloads.xiph.org/releases/flac/flac-1.3.2.tar.xz" =>
    "91cfc3ed61dc40f47f050a109b08610667d73477af6ef36dcad31c31a4a8d53f",
]

dependencies = [
    # We need libogg to build FLAC
    "https://github.com/staticfloat/OggBuilder/releases/download/v1.3.3-0/build.jl"
]

script = raw"""
cd $WORKSPACE/srcdir/flac-1.3.2

# We need to add ${prefix}/lib onto the end of $LD_LIRBARY_PATH because ./configure
# here is going to try and run programs that link against libogg, but don't set their
# RPATH's properly.  Le sigh.
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${prefix}/lib

# Do the building dance
./configure --prefix=${prefix} --host=${target} --disable-avx
make -j${nproc}
make install
"""

products = prefix -> [
  LibraryProduct(prefix, "libflac"),
]

# Be quiet unless we've passed `--verbose`
verbose = "--verbose" in ARGS
ARGS = filter!(x -> x != "--verbose", ARGS)

# Choose which platforms to build for; if we've got an argument use that one,
# otherwise default to just building all of them!
build_platforms = platforms
if length(ARGS) > 0
    build_platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(build_platforms), ", "))")


autobuild(pwd(), "FLAC", build_platforms, sources, script, products; dependencies=dependencies, verbose=verbose)
