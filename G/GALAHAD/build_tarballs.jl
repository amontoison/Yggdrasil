# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "GALAHAD"
version = v"5.3.0"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/ralna/GALAHAD.git", "05da8b3e4d7e251dce2dec22b894048734e276cd")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
# Update Ninja
cp ${host_prefix}/bin/ninja /usr/bin/ninja
cd ${WORKSPACE}/srcdir/GALAHAD
if [[ "${target}" == *mingw* ]]; then   LBT="blastrampoline-5";   HWLOC="hwloc-15"; else   LBT="blastrampoline";   HWLOC="hwloc"; fi
QUADRUPLE="true"
if [[ "${target}" == *arm* ]] || [[ "${target}" == *aarch64-linux* ]] || [[ "${target}" == *aarch64-unknown-freebsd* ]] || [[ "${target}" == *powerpc64le-linux-gnu* ]] || [[ "${target}" == *riscv64* ]]; then     QUADRUPLE="false"; fi
meson setup builddir_int32 --cross-file=${MESON_TARGET_TOOLCHAIN%.*}_gcc.meson                            --prefix=$prefix                            -Dint64=false                            -Dlibhwloc=$HWLOC                            -Dlibblas=$LBT                            -Dliblapack=$LBT                            -Dlibsmumps=smumps                            -Dlibdmumps=dmumps                            -Dlibcutest_single=cutest_single                            -Dlibcutest_double=cutest_double                            -Dlibcutest_quadruple=                            -Dlibcutest_modules=$prefix/modules                            -Dsingle=true                            -Ddouble=true                            -Dquadruple=false                            -Dbinaries=true                            -Dtests=false                            -Dlibhsl=hsl_subset                            -Dlibhsl_modules=$prefix/modules
meson compile -C builddir_int32
meson compile -C builddir_int32
meson compile -C builddir_int32
meson compile -C builddir_int32
meson compile -C builddir_int32
meson compile -C builddir_int32
meson compile -C builddir_int32
meson compile -C builddir_int32
ls
rm builddir_int32/
rm -rf builddir_int32/
cp ${prefix}/bin/ninja /usr/bin/ninja
nonja -v
ninja -v
ninja -h
ninja --version
cd ${WORKSPACE}/srcdir/GALAHAD
if [[ "${target}" == *mingw* ]]; then   LBT="blastrampoline-5";   HWLOC="hwloc-15"; else   LBT="blastrampoline";   HWLOC="hwloc"; fi
QUADRUPLE="true"
if [[ "${target}" == *arm* ]] || [[ "${target}" == *aarch64-linux* ]] || [[ "${target}" == *aarch64-unknown-freebsd* ]] || [[ "${target}" == *powerpc64le-linux-gnu* ]] || [[ "${target}" == *riscv64* ]]; then     QUADRUPLE="false"; fi
meson setup builddir_int32 --cross-file=${MESON_TARGET_TOOLCHAIN%.*}_gcc.meson                            --prefix=$prefix                            -Dint64=false                            -Dlibhwloc=$HWLOC                            -Dlibblas=$LBT                            -Dliblapack=$LBT                            -Dlibsmumps=smumps                            -Dlibdmumps=dmumps                            -Dlibcutest_single=cutest_single                            -Dlibcutest_double=cutest_double                            -Dlibcutest_quadruple=                            -Dlibcutest_modules=$prefix/modules                            -Dsingle=true                            -Ddouble=true                            -Dquadruple=false                            -Dbinaries=true                            -Dtests=false                            -Dlibhsl=hsl_subset                            -Dlibhsl_modules=$prefix/modules
meson compile -C builddir_int32
meson setup builddir_int64 --cross-file=${MESON_TARGET_TOOLCHAIN%.*}_gcc.meson                            --prefix=$prefix                            -Dint64=true                            -Dlibhwloc=$HWLOC                            -Dlibblas=$LBT                            -Dliblapack=$LBT                            -Dlibsmumps=                            -Dlibdmumps=                            -Dlibcutest_single=                            -Dlibcutest_double=                            -Dlibcutest_quadruple=                            -Dlibcutest_modules=$prefix/modules                            -Dsingle=true                            -Ddouble=true                            -Dquadruple=false                            -Dbinaries=false                            -Dtests=false                            -Dlibhsl=hsl_subset_64                            -Dlibhsl_modules=$prefix/modules
meson compile -C builddir_int64
if [[ "$QUADRUPLE" == "true" ]]; then     meson setup builddir_quad_int32 --cross-file=${MESON_TARGET_TOOLCHAIN%.*}_gcc.meson                                     --prefix=$prefix                                     -Dint64=false                                     -Dlibhwloc=$HWLOC                                     -Dlibblas=                                     -Dliblapack=                                     -Dlibsmumps=                                     -Dlibdmumps=                                     -Dlibcutest_single=cutest_single                                     -Dlibcutest_double=cutest_double                                     -Dlibcutest_quadruple=                                     -Dlibcutest_modules=$prefix/modules                                     -Dsingle=false                                     -Ddouble=false                                     -Dquadruple=true                                     -Dbinaries=true                                     -Dtests=false                                     -Dlibhsl=                                     -Dlibhsl_modules=$prefix/modules     meson compile -C builddir_quad_int32     meson setup builddir_quad_int64 --cross-file=${MESON_TARGET_TOOLCHAIN%.*}_gcc.meson                                     --prefix=$prefix                                     -Dint64=true                                     -Dlibhwloc=$HWLOC                                     -Dlibblas=                                     -Dliblapack=                                     -Dlibsmumps=                                     -Dlibdmumps=                                     -Dlibcutest_single=                                     -Dlibcutest_double=                                     -Dlibcutest_quadruple=                                     -Dlibcutest_modules=$prefix/modules                                     -Dsingle=false                                     -Ddouble=false                                     -Dquadruple=true                                     -Dbinaries=false                                     -Dtests=false                                     -Dlibhsl=                                     -Dlibhsl_modules=$prefix/modules     meson compile -C builddir_quad_int64; fi
meson install -C builddir_int32
meson install -C builddir_int64
if [[ "$QUADRUPLE" == "true" ]]; then     meson install -C builddir_quad_int32;     meson install -C builddir_quad_int64; fi
exit
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Platform("x86_64", "linux"; libc = "glibc")
]


# The products that we will ensure are always built
products = [
    LibraryProduct("libgalahad_single_64", :libgalahad_single_64),
    LibraryProduct("libgalahad_single", :libgalahad_single),
    LibraryProduct("libgalahad_quadruple", :libgalahad_quadruple),
    LibraryProduct("libgalahad_double", :libgalahad_double),
    LibraryProduct("libgalahad_double_64", :libgalahad_double_64),
    LibraryProduct("libgalahad_quadruple_64", :libgalahad_quadruple_64),
    ExecutableProduct("runarc_sif_double", :runarc_sif_double),
    ExecutableProduct("runeqp_sif_double", :runeqp_sif_double),
    ExecutableProduct("runcqp_qplib_double", :runcqp_qplib_double),
    ExecutableProduct("rundqp_sif_single", :rundqp_sif_single),
    ExecutableProduct("runqp_sif_single", :runqp_sif_single),
    ExecutableProduct("runqpa_sif_double", :runqpa_sif_double),
    ExecutableProduct("runqpc_qplib_single", :runqpc_qplib_single),
    ExecutableProduct("runfdh_sif_double", :runfdh_sif_double),
    ExecutableProduct("runcdqp_qplib_single", :runcdqp_qplib_single),
    ExecutableProduct("runcdqp_sif_single", :runcdqp_sif_single),
    ExecutableProduct("runarc_sif_single", :runarc_sif_single),
    ExecutableProduct("rungltr_sif_single", :rungltr_sif_single),
    ExecutableProduct("rundlp_qplib_quadruple", :rundlp_qplib_quadruple),
    ExecutableProduct("runqpb_qplib_quadruple", :runqpb_qplib_quadruple),
    ExecutableProduct("runsls_sif_double", :runsls_sif_double),
    ExecutableProduct("runugo_sif_single", :runugo_sif_single),
    ExecutableProduct("runlancelot_sif_single", :runlancelot_sif_single),
    ExecutableProduct("runqpa_sif_single", :runqpa_sif_single),
    ExecutableProduct("runqpa_qplib_quadruple", :runqpa_qplib_quadruple),
    ExecutableProduct("runglrt_sif_double", :runglrt_sif_double),
    ExecutableProduct("runlqr_sif_double", :runlqr_sif_double),
    ExecutableProduct("runtrb_sif_single", :runtrb_sif_single),
    ExecutableProduct("run_lancelot_simple_single", :run_lancelot_simple_single),
    ExecutableProduct("runbqp_qplib_double", :runbqp_qplib_double),
    ExecutableProduct("rundqp_sif_double", :rundqp_sif_double),
    ExecutableProduct("runfiltrane_sif_single", :runfiltrane_sif_single),
    ExecutableProduct("runlpb_sif_double", :runlpb_sif_double),
    ExecutableProduct("runpresolve_sif_double", :runpresolve_sif_double),
    ExecutableProduct("runlqr_sif_single", :runlqr_sif_single),
    ExecutableProduct("runfiltrane_sif_double", :runfiltrane_sif_double),
    ExecutableProduct("runqpc_qplib_quadruple", :runqpc_qplib_quadruple),
    ExecutableProduct("runexpo_sif_double", :runexpo_sif_double),
    ExecutableProduct("rundqp_qplib_quadruple", :rundqp_qplib_quadruple),
    ExecutableProduct("runbllsb_sif_single", :runbllsb_sif_single),
    ExecutableProduct("runcdqp_qplib_double", :runcdqp_qplib_double),
    ExecutableProduct("runlancelot_steering_sif_single", :runlancelot_steering_sif_single),
    ExecutableProduct("runccqp_qplib_double", :runccqp_qplib_double),
    ExecutableProduct("runqpa_qplib_double", :runqpa_qplib_double),
    ExecutableProduct("runwcp_sif_double", :runwcp_sif_double),
    ExecutableProduct("runlqt_sif_double", :runlqt_sif_double),
    ExecutableProduct("rundemo_sif_single", :rundemo_sif_single),
    ExecutableProduct("rundgo_sif_single", :rundgo_sif_single),
    ExecutableProduct("runbllsb_sif_double", :runbllsb_sif_double),
    ExecutableProduct("runcqp_qplib_quadruple", :runcqp_qplib_quadruple),
    ExecutableProduct("runl1qp_sif_double", :runl1qp_sif_double),
    ExecutableProduct("runl1qp_sif_single", :runl1qp_sif_single),
    ExecutableProduct("runmiqr_sif_double", :runmiqr_sif_double),
    ExecutableProduct("runlpa_sif_single", :runlpa_sif_single),
    ExecutableProduct("runlpb_qplib_single", :runlpb_qplib_single),
    ExecutableProduct("runqpb_qplib_single", :runqpb_qplib_single),
    ExecutableProduct("runqpb_sif_double", :runqpb_sif_double),
    ExecutableProduct("runqpc_sif_single", :runqpc_sif_single),
    ExecutableProduct("runsha_sif_double", :runsha_sif_double),
    ExecutableProduct("runcqp_sif_single", :runcqp_sif_single),
    ExecutableProduct("runlpb_qplib_quadruple", :runlpb_qplib_quadruple),
    ExecutableProduct("runlls_sif_single", :runlls_sif_single),
    ExecutableProduct("runbgo_sif_double", :runbgo_sif_double),
    ExecutableProduct("runccqp_qplib_single", :runccqp_qplib_single),
    ExecutableProduct("runlsrt_sif_single", :runlsrt_sif_single),
    ExecutableProduct("runrqs_sif_double", :runrqs_sif_double),
    ExecutableProduct("runqp_qplib_single", :runqp_qplib_single),
    ExecutableProduct("runl2rt_sif_single", :runl2rt_sif_single),
    ExecutableProduct("rungltr_sif_double", :rungltr_sif_double),
    ExecutableProduct("runlls_sif_double", :runlls_sif_double),
    ExecutableProduct("runnodend_sif_single", :runnodend_sif_single),
    ExecutableProduct("runclls_sif_single", :runclls_sif_single),
    ExecutableProduct("rundps_sif_single", :rundps_sif_single),
    ExecutableProduct("runexpo_sif_single", :runexpo_sif_single),
    ExecutableProduct("runlqt_sif_single", :runlqt_sif_single),
    ExecutableProduct("galahad_error", :galahad_error),
    ExecutableProduct("runblls_sif_single", :runblls_sif_single),
    ExecutableProduct("runbqpb_qplib_double", :runbqpb_qplib_double),
    ExecutableProduct("runccqp_sif_double", :runccqp_sif_double),
    ExecutableProduct("runccqp_sif_single", :runccqp_sif_single),
    ExecutableProduct("runqpc_sif_double", :runqpc_sif_double),
    ExecutableProduct("rundgo_sif_double", :rundgo_sif_double),
    ExecutableProduct("runlpb_sif_single", :runlpb_sif_single),
    ExecutableProduct("runrqs_sif_single", :runrqs_sif_single),
    ExecutableProduct("runqpb_qplib_double", :runqpb_qplib_double),
    ExecutableProduct("runnls_sif_double", :runnls_sif_double),
    ExecutableProduct("runsils_sif_double", :runsils_sif_double),
    ExecutableProduct("runtrs_sif_double", :runtrs_sif_double),
    ExecutableProduct("runlpa_qplib_quadruple", :runlpa_qplib_quadruple),
    ExecutableProduct("runbqp_sif_double", :runbqp_sif_double),
    ExecutableProduct("runbqpb_qplib_single", :runbqpb_qplib_single),
    ExecutableProduct("runlpa_sif_double", :runlpa_sif_double),
    ExecutableProduct("runugo_sif_double", :runugo_sif_double),
    ExecutableProduct("runwarm_sif_single", :runwarm_sif_single),
    ExecutableProduct("runtrs_sif_single", :runtrs_sif_single),
    ExecutableProduct("runbqpb_qplib_quadruple", :runbqpb_qplib_quadruple),
    ExecutableProduct("rundps_sif_double", :rundps_sif_double),
    ExecutableProduct("rundlp_qplib_double", :rundlp_qplib_double),
    ExecutableProduct("runslls_sif_single", :runslls_sif_single),
    ExecutableProduct("runblls_sif_double", :runblls_sif_double),
    ExecutableProduct("runcdqp_sif_double", :runcdqp_sif_double),
    ExecutableProduct("runwarm_sif_double", :runwarm_sif_double),
    ExecutableProduct("runlancelot_steering_sif_double", :runlancelot_steering_sif_double),
    ExecutableProduct("runtrb_sif_double", :runtrb_sif_double),
    ExecutableProduct("runqp_qplib_double", :runqp_qplib_double),
    ExecutableProduct("runqp_sif_double", :runqp_sif_double),
    ExecutableProduct("runfdh_sif_single", :runfdh_sif_single),
    ExecutableProduct("runcdqp_qplib_quadruple", :runcdqp_qplib_quadruple),
    ExecutableProduct("runlsrt_sif_double", :runlsrt_sif_double),
    ExecutableProduct("runqp_qplib_quadruple", :runqp_qplib_quadruple),
    ExecutableProduct("rundlp_qplib_single", :rundlp_qplib_single),
    ExecutableProduct("runeqp_sif_single", :runeqp_sif_single),
    ExecutableProduct("runnodend_sif_double", :runnodend_sif_double),
    ExecutableProduct("runsbls_sif_double", :runsbls_sif_double),
    ExecutableProduct("runl2rt_sif_double", :runl2rt_sif_double),
    ExecutableProduct("runbqpb_sif_double", :runbqpb_sif_double),
    ExecutableProduct("runcqp_sif_double", :runcqp_sif_double),
    ExecutableProduct("runlpqp_sif_double", :runlpqp_sif_double),
    ExecutableProduct("runsbls_sif_single", :runsbls_sif_single),
    ExecutableProduct("runsha_sif_single", :runsha_sif_single),
    ExecutableProduct("runqpb_sif_single", :runqpb_sif_single),
    ExecutableProduct("runnls_sif_single", :runnls_sif_single),
    ExecutableProduct("runlpa_qplib_double", :runlpa_qplib_double),
    ExecutableProduct("runpresolve_sif_single", :runpresolve_sif_single),
    ExecutableProduct("runsils_sif_single", :runsils_sif_single),
    ExecutableProduct("runlancelot_sif_double", :runlancelot_sif_double),
    ExecutableProduct("runccqp_qplib_quadruple", :runccqp_qplib_quadruple),
    ExecutableProduct("runbgo_sif_single", :runbgo_sif_single),
    ExecutableProduct("runbqp_sif_single", :runbqp_sif_single),
    ExecutableProduct("runcqp_qplib_single", :runcqp_qplib_single),
    ExecutableProduct("buildspec", :buildspec),
    ExecutableProduct("rundqp_qplib_single", :rundqp_qplib_single),
    ExecutableProduct("runbqpb_sif_single", :runbqpb_sif_single),
    ExecutableProduct("rundlp_sif_double", :rundlp_sif_double),
    ExecutableProduct("runlpb_qplib_double", :runlpb_qplib_double),
    ExecutableProduct("runsls_sif_single", :runsls_sif_single),
    ExecutableProduct("runmiqr_sif_single", :runmiqr_sif_single),
    ExecutableProduct("runqpc_qplib_double", :runqpc_qplib_double),
    ExecutableProduct("runlpqp_sif_single", :runlpqp_sif_single),
    ExecutableProduct("runbqp_qplib_quadruple", :runbqp_qplib_quadruple),
    ExecutableProduct("run_lancelot_simple_double", :run_lancelot_simple_double),
    ExecutableProduct("runlpa_qplib_single", :runlpa_qplib_single),
    ExecutableProduct("runlstr_sif_double", :runlstr_sif_double),
    ExecutableProduct("rundqp_qplib_double", :rundqp_qplib_double),
    ExecutableProduct("runclls_sif_double", :runclls_sif_double),
    ExecutableProduct("runwcp_sif_single", :runwcp_sif_single),
    ExecutableProduct("runtru_sif_single", :runtru_sif_single),
    ExecutableProduct("rundemo_sif_double", :rundemo_sif_double),
    ExecutableProduct("rundlp_sif_single", :rundlp_sif_single),
    ExecutableProduct("runqpa_qplib_single", :runqpa_qplib_single),
    ExecutableProduct("runbqp_qplib_single", :runbqp_qplib_single),
    ExecutableProduct("runglrt_sif_single", :runglrt_sif_single),
    ExecutableProduct("runlstr_sif_single", :runlstr_sif_single),
    ExecutableProduct("runtru_sif_double", :runtru_sif_double),
    ExecutableProduct("runslls_sif_double", :runslls_sif_double)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(name="Ninja_jll", uuid="76642167-d241-5cee-8c94-7a494e8cb7b7"))
    Dependency(PackageSpec(name="CompilerSupportLibraries_jll", uuid="e66e0078-7015-5450-92f7-15fbd957f2ae"))
    Dependency(PackageSpec(name="libblastrampoline_jll", uuid="8e850b90-86db-534c-a0d3-1478176c7d93"))
    Dependency(PackageSpec(name="Hwloc_jll", uuid="e33a78d0-f292-5ffc-b300-72abe9b543c8"))
    Dependency(PackageSpec(name="MUMPS_seq_jll", uuid="d7ed1dd3-d0ae-5e8e-bfb4-87a502085b8d"))
    Dependency(PackageSpec(name="HSL_jll", uuid="017b0a0e-03f4-516a-9b91-836bbd1904dd"))
    Dependency(PackageSpec(name="CUTEst_jll", uuid="bb5f6f25-f23d-57fd-8f90-3ef7bad1d825"))
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6", preferred_gcc_version = v"9.1.0")
