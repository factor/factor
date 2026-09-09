FROM: alien.c-types => double ;
USING: alien.syntax arrays benchmark.binary-trees benchmark.csv
benchmark.fannkuch benchmark.lcs benchmark.msgpack benchmark.nbody
benchmark.nbody-simd benchmark.spectral-norm benchmark.struct-arrays
benchmark.tuple-arrays compiler.cfg.metrics kernel kernel.private
math math.private math.vectors math.vectors.simd locals sequences
specialized-arrays memory prettyprint ;
IN: allocator-runtime-comparison
LIBRARY: allocator-counters
FUNCTION: double allocator_ffi_mix ( double x, double y )

:: float-pressure ( x -- value )
    x { float } declare :> y
    y 1.0 + :> a1
    y 2.0 + :> a2
    y 3.0 + :> a3
    y 4.0 + :> a4
    y 5.0 + :> a5
    y 6.0 + :> a6
    y 7.0 + :> a7
    y 8.0 + :> a8
    y 9.0 + :> a9
    y 10.0 + :> a10
    y 11.0 + :> a11
    y 12.0 + :> a12
    y 13.0 + :> a13
    y 14.0 + :> a14
    y 15.0 + :> a15
    y 16.0 + :> a16
    y 17.0 + :> a17
    y 18.0 + :> a18
    y 19.0 + :> a19
    y 20.0 + :> a20
    y 21.0 + :> a21
    y 22.0 + :> a22
    y 23.0 + :> a23
    y 24.0 + :> a24
    y 25.0 + :> a25
    y 26.0 + :> a26
    y 27.0 + :> a27
    y 28.0 + :> a28
    y 29.0 + :> a29
    y 30.0 + :> a30
    y 31.0 + :> a31
    y 32.0 + :> a32
    a1 a17 *
    a2 a18 * +
    a3 a19 * +
    a4 a20 * +
    a5 a21 * +
    a6 a22 * +
    a7 a23 * +
    a8 a24 * +
    a9 a25 * +
    a10 a26 * +
    a11 a27 * +
    a12 a28 * +
    a13 a29 * +
    a14 a30 * +
    a15 a31 * +
    a16 a32 * +
    ;
: float-pressure-work ( -- )
    0.0 1000 [ 32 <iota> [ >float float-pressure + ] each ] times
    546048000.0 assert= ;

:: ffi-pressure ( x -- value )
    x { float } declare :> y
    y 1.0 + :> a1
    y 2.0 + :> a2
    y 3.0 + :> a3
    y 4.0 + :> a4
    y 5.0 + :> a5
    y 6.0 + :> a6
    y 7.0 + :> a7
    y 8.0 + :> a8
    y 9.0 + :> a9
    y 10.0 + :> a10
    y 11.0 + :> a11
    y 12.0 + :> a12
    y 13.0 + :> a13
    y 14.0 + :> a14
    y 15.0 + :> a15
    y 16.0 + :> a16
    y 17.0 + :> a17
    y 18.0 + :> a18
    y 19.0 + :> a19
    y 20.0 + :> a20
    y 21.0 + :> a21
    y 22.0 + :> a22
    y 23.0 + :> a23
    y 24.0 + :> a24
    y 25.0 + :> a25
    y 26.0 + :> a26
    y 27.0 + :> a27
    y 28.0 + :> a28
    y 29.0 + :> a29
    y 30.0 + :> a30
    y 31.0 + :> a31
    y 32.0 + :> a32
    y 3.0 allocator_ffi_mix :> z
    a1 a17 *
    a2 a18 * +
    a3 a19 * +
    a4 a20 * +
    a5 a21 * +
    a6 a22 * +
    a7 a23 * +
    a8 a24 * +
    a9 a25 * +
    a10 a26 * +
    a11 a27 * +
    a12 a28 * +
    a13 a29 * +
    a14 a30 * +
    a15 a31 * +
    a16 a32 * +
    z +
    ;
: ffi-pressure-work ( -- )
    0.0 1000 [ 32 <iota> [ >float ffi-pressure + ] each ] times
    547136000.0 assert= ;

:: branch-pressure ( x -- value )
    x { float } declare :> y
    y 1.0 + :> a1
    y 2.0 + :> a2
    y 3.0 + :> a3
    y 4.0 + :> a4
    y 5.0 + :> a5
    y 6.0 + :> a6
    y 7.0 + :> a7
    y 8.0 + :> a8
    y 9.0 + :> a9
    y 10.0 + :> a10
    y 11.0 + :> a11
    y 12.0 + :> a12
    y 13.0 + :> a13
    y 14.0 + :> a14
    y 15.0 + :> a15
    y 16.0 + :> a16
    y 17.0 + :> a17
    y 18.0 + :> a18
    y 19.0 + :> a19
    y 20.0 + :> a20
    y 21.0 + :> a21
    y 22.0 + :> a22
    y 23.0 + :> a23
    y 24.0 + :> a24
    y 25.0 + :> a25
    y 26.0 + :> a26
    y 27.0 + :> a27
    y 28.0 + :> a28
    y 29.0 + :> a29
    y 30.0 + :> a30
    y 31.0 + :> a31
    y 32.0 + :> a32
    y 16.0 < [ a1 a17 * ] [ a1 a17 + ] if
    a2 a18 * +
    a3 a19 * +
    a4 a20 * +
    a5 a21 * +
    a6 a22 * +
    a7 a23 * +
    a8 a24 * +
    a9 a25 * +
    a10 a26 * +
    a11 a27 * +
    a12 a28 * +
    a13 a29 * +
    a14 a30 * +
    a15 a31 * +
    a16 a32 * +
    ;
: branch-pressure-work ( -- )
    0.0 1000 [ 32 <iota> [ >float branch-pressure + ] each ] times
    530872000.0 assert= ;

:: integer-pressure ( x -- value )
    x { fixnum } declare :> y
    y 1 fixnum+fast :> a1
    y 2 fixnum+fast :> a2
    y 3 fixnum+fast :> a3
    y 4 fixnum+fast :> a4
    y 5 fixnum+fast :> a5
    y 6 fixnum+fast :> a6
    y 7 fixnum+fast :> a7
    y 8 fixnum+fast :> a8
    y 9 fixnum+fast :> a9
    y 10 fixnum+fast :> a10
    y 11 fixnum+fast :> a11
    y 12 fixnum+fast :> a12
    y 13 fixnum+fast :> a13
    y 14 fixnum+fast :> a14
    y 15 fixnum+fast :> a15
    y 16 fixnum+fast :> a16
    y 17 fixnum+fast :> a17
    y 18 fixnum+fast :> a18
    y 19 fixnum+fast :> a19
    y 20 fixnum+fast :> a20
    y 21 fixnum+fast :> a21
    y 22 fixnum+fast :> a22
    y 23 fixnum+fast :> a23
    y 24 fixnum+fast :> a24
    y 25 fixnum+fast :> a25
    y 26 fixnum+fast :> a26
    y 27 fixnum+fast :> a27
    y 28 fixnum+fast :> a28
    y 29 fixnum+fast :> a29
    y 30 fixnum+fast :> a30
    y 31 fixnum+fast :> a31
    y 32 fixnum+fast :> a32
    y 33 fixnum+fast :> a33
    y 34 fixnum+fast :> a34
    y 35 fixnum+fast :> a35
    y 36 fixnum+fast :> a36
    y 37 fixnum+fast :> a37
    y 38 fixnum+fast :> a38
    y 39 fixnum+fast :> a39
    y 40 fixnum+fast :> a40
    a1
    a2 fixnum+fast
    a3 fixnum+fast
    a4 fixnum+fast
    a5 fixnum+fast
    a6 fixnum+fast
    a7 fixnum+fast
    a8 fixnum+fast
    a9 fixnum+fast
    a10 fixnum+fast
    a11 fixnum+fast
    a12 fixnum+fast
    a13 fixnum+fast
    a14 fixnum+fast
    a15 fixnum+fast
    a16 fixnum+fast
    a17 fixnum+fast
    a18 fixnum+fast
    a19 fixnum+fast
    a20 fixnum+fast
    a21 fixnum+fast
    a22 fixnum+fast
    a23 fixnum+fast
    a24 fixnum+fast
    a25 fixnum+fast
    a26 fixnum+fast
    a27 fixnum+fast
    a28 fixnum+fast
    a29 fixnum+fast
    a30 fixnum+fast
    a31 fixnum+fast
    a32 fixnum+fast
    a33 fixnum+fast
    a34 fixnum+fast
    a35 fixnum+fast
    a36 fixnum+fast
    a37 fixnum+fast
    a38 fixnum+fast
    a39 fixnum+fast
    a40 fixnum+fast
    ;
: integer-pressure-work ( -- )
    0 1000 [ 32 <iota> [ integer-pressure + ] each ] times
    46080000 assert= ;

:: simd-pressure ( x -- value )
    x >float dup dup dup float-4-boa :> y
    y float-4{ 1 1 1 1 } v+ :> a1
    y float-4{ 2 2 2 2 } v+ :> a2
    y float-4{ 3 3 3 3 } v+ :> a3
    y float-4{ 4 4 4 4 } v+ :> a4
    y float-4{ 5 5 5 5 } v+ :> a5
    y float-4{ 6 6 6 6 } v+ :> a6
    y float-4{ 7 7 7 7 } v+ :> a7
    y float-4{ 8 8 8 8 } v+ :> a8
    y float-4{ 9 9 9 9 } v+ :> a9
    y float-4{ 10 10 10 10 } v+ :> a10
    y float-4{ 11 11 11 11 } v+ :> a11
    y float-4{ 12 12 12 12 } v+ :> a12
    y float-4{ 13 13 13 13 } v+ :> a13
    y float-4{ 14 14 14 14 } v+ :> a14
    y float-4{ 15 15 15 15 } v+ :> a15
    y float-4{ 16 16 16 16 } v+ :> a16
    y float-4{ 17 17 17 17 } v+ :> a17
    y float-4{ 18 18 18 18 } v+ :> a18
    y float-4{ 19 19 19 19 } v+ :> a19
    y float-4{ 20 20 20 20 } v+ :> a20
    y float-4{ 21 21 21 21 } v+ :> a21
    y float-4{ 22 22 22 22 } v+ :> a22
    y float-4{ 23 23 23 23 } v+ :> a23
    y float-4{ 24 24 24 24 } v+ :> a24
    y float-4{ 25 25 25 25 } v+ :> a25
    y float-4{ 26 26 26 26 } v+ :> a26
    y float-4{ 27 27 27 27 } v+ :> a27
    y float-4{ 28 28 28 28 } v+ :> a28
    y float-4{ 29 29 29 29 } v+ :> a29
    y float-4{ 30 30 30 30 } v+ :> a30
    y float-4{ 31 31 31 31 } v+ :> a31
    y float-4{ 32 32 32 32 } v+ :> a32
    a1 a17 v*
    a2 a18 v* v+
    a3 a19 v* v+
    a4 a20 v* v+
    a5 a21 v* v+
    a6 a22 v* v+
    a7 a23 v* v+
    a8 a24 v* v+
    a9 a25 v* v+
    a10 a26 v* v+
    a11 a27 v* v+
    a12 a28 v* v+
    a13 a29 v* v+
    a14 a30 v* v+
    a15 a31 v* v+
    a16 a32 v* v+
    sum
    ;
: simd-pressure-work ( -- )
    0.0 1000 [ 32 <iota> [ simd-pressure + ] each ] times
    2184192000.0 assert= ;

:: gc-pressure ( x -- value )
    x 1 + 1array :> a1
    x 2 + 1array :> a2
    x 3 + 1array :> a3
    x 4 + 1array :> a4
    x 5 + 1array :> a5
    x 6 + 1array :> a6
    x 7 + 1array :> a7
    x 8 + 1array :> a8
    x 9 + 1array :> a9
    x 10 + 1array :> a10
    x 11 + 1array :> a11
    x 12 + 1array :> a12
    x 13 + 1array :> a13
    x 14 + 1array :> a14
    x 15 + 1array :> a15
    x 16 + 1array :> a16
    x 17 + 1array :> a17
    x 18 + 1array :> a18
    x 19 + 1array :> a19
    x 20 + 1array :> a20
    x 21 + 1array :> a21
    x 22 + 1array :> a22
    x 23 + 1array :> a23
    x 24 + 1array :> a24
    x 25 + 1array :> a25
    x 26 + 1array :> a26
    x 27 + 1array :> a27
    x 28 + 1array :> a28
    x 29 + 1array :> a29
    x 30 + 1array :> a30
    x 31 + 1array :> a31
    x 32 + 1array :> a32
    gc
    a1 first
    a2 first +
    a3 first +
    a4 first +
    a5 first +
    a6 first +
    a7 first +
    a8 first +
    a9 first +
    a10 first +
    a11 first +
    a12 first +
    a13 first +
    a14 first +
    a15 first +
    a16 first +
    a17 first +
    a18 first +
    a19 first +
    a20 first +
    a21 first +
    a22 first +
    a23 first +
    a24 first +
    a25 first +
    a26 first +
    a27 first +
    a28 first +
    a29 first +
    a30 first +
    a31 first +
    a32 first +
    ;
: gc-pressure-work ( -- ) 0 4 <iota> [ gc-pressure + ] each 2304 assert= ;

: metric-workloads ( -- words )
    { float-pressure ffi-pressure branch-pressure integer-pressure simd-pressure gc-pressure
      benchmark.spectral-norm:spectral-norm benchmark.nbody:nbody benchmark.nbody-simd:nbody
      benchmark.fannkuch:fannkuch benchmark.binary-trees:binary-trees
      benchmark.struct-arrays:struct-arrays-bench } ;
: workloads ( -- words )
    { norm-work nbody-work nbody-simd-work trees-work fannkuch-work sieve-work
      pi-work md5-work sha1-work base64-work base32-work benchmark.csv:csv-benchmark json-work
      benchmark.msgpack:msgpack-benchmark benchmark.lcs:lcs-benchmark benchmark.tuple-arrays:tuple-arrays-benchmark struct-work
      matrix-work matrix-simd-work gc-work
      float-pressure-work ffi-pressure-work branch-pressure-work integer-pressure-work
      simd-pressure-work gc-pressure-work } ;
