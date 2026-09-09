USING: vocabs.loader vocabs.refresh ;

USING: accessors alien alien.c-types alien.libraries alien.syntax
arrays assocs base32 base64 byte-arrays checksums checksums.md5
checksums.sha command-line compiler compiler.crossref compiler.units compiler.errors compiler.utilities
compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.chordal
compiler.cfg.value-numbering deques dlists hex-strings io io.streams.string
json kernel locals math math.parser math.matrices math.matrices.simd memory namespaces
prettyprint sequences sets sorting strings system tools.crossref tools.time vocabs words
benchmark.spectral-norm benchmark.nbody benchmark.nbody-simd
benchmark.binary-trees benchmark.fannkuch benchmark.sieve benchmark.pidigits
benchmark.md5 benchmark.sha1 benchmark.base64 benchmark.base32
benchmark.csv benchmark.json benchmark.msgpack benchmark.lcs
benchmark.tuple-arrays benchmark.struct-arrays benchmark.gc1
benchmark.matrix-exponential-scalar benchmark.matrix-exponential-simd ;
IN: allocator-runtime-comparison
<< "allocator-counters" "./reference/allocator-speed-crossarch-20260908/counters" cdecl add-library >>
LIBRARY: allocator-counters
FUNCTION: ulonglong compiler_instructions ( )
FUNCTION: double compiler_cpu_seconds ( )

: norm-work ( -- ) 500 spectral-norm . ;
: nbody-work ( -- ) 100000 benchmark.nbody:nbody ;
: nbody-simd-work ( -- ) 100000 benchmark.nbody-simd:nbody ;
: trees-work ( -- ) 14 binary-trees ;
: fannkuch-work ( -- ) 8 fannkuch ;
: sieve-work ( -- ) 10000000 sieve 664579 assert= ;
: pi-work ( -- ) 1000 pidigits ;
: md5-work ( -- ) 2000000 <iota> >byte-array md5 checksum-bytes bytes>hex-string print ;
: sha1-work ( -- ) 2000000 <iota> >byte-array sha1 checksum-bytes bytes>hex-string print ;
: base64-work ( -- )
    65535 <iota> [ 255 bitand ] "" map-as
    [ 20 [ >base64 base64> ] times >byte-array ] [ >byte-array ] bi assert= ;
: base32-work ( -- )
    65535 <iota> [ 255 bitand ] "" map-as
    [ 20 [ >base32 base32> ] times >byte-array ] [ >byte-array ] bi assert= ;
: json-work ( -- )
    200 <iota> [ [ number>string ] keep ] H{ } map>assoc
    [ 1000 [ >json json> ] times ] keep assoc= t assert= ;
: struct-work ( -- ) 2 [ 100000 struct-arrays-bench ] times ;
: matrix-work ( -- )
    f 4 <identity-matrix> 1000 [ swap drop dup 20 e^m swap ] times drop . ;
: matrix-simd-work ( -- )
    f 1000 [ drop identity-matrix4 20 e^m4 ] times . ;
: gc-work ( -- ) 600000 <iota> [ >bignum 1 + ] map sum 180000300000 assert= ;

: workloads ( -- words )
    { norm-work nbody-work nbody-simd-work trees-work fannkuch-work sieve-work
      pi-work md5-work sha1-work base64-work base32-work csv-benchmark json-work
      msgpack-benchmark lcs-benchmark tuple-arrays-benchmark struct-work
      matrix-work matrix-simd-work gc-work } ;

:: allocation-callees ( word -- words )
    word uses word load-dependencies append word subwords append [ word? ] filter ;
:: benchmark-closure ( roots -- words )
    HS{ } clone :> seen
    <dlist> :> queue
    roots queue push-all-back
    [ queue deque-empty? ] [
        queue pop-front :> word
        word seen ?adjoin [ word allocation-callees queue push-all-back ] when
    ] until
    seen members [ compile? ] filter [ [ vocabulary>> ] [ name>> ] bi 2array ] sort-by ;
: emit ( assoc -- ) >json print flush ;
: word-id ( word -- id ) [ vocabulary>> ] [ name>> ] bi ":" glue >string ;
:: select-allocator ( name -- )
    name "linear-scan" = [ "compiler.cfg.register-allocation" ]
    [ "compiler.cfg.register-allocation." name append ] if :> vocab
    name "-allocator" append vocab lookup-word execute( -- allocator )
    register-allocator namespaces:set ;
:: invoke ( word -- output ) [ word execute( -- ) ] with-string-writer ;
:: sample ( word trial -- )
    gc
    compiler_instructions :> before
    compiler_cpu_seconds :> cpu
    [ word invoke ] benchmark :> ( output ns )
    compiler_cpu_seconds cpu - :> elapsed
    compiler_instructions before - :> instructions
    H{ } clone
    "runtime" "kind" pick set-at
    word word-id "word" pick set-at
    trial "trial" pick set-at
    output "output" pick set-at
    ns "ns" pick set-at
    elapsed "cpu_seconds" pick set-at
    instructions "instructions" pick set-at emit ;
SYMBOL: benchmark-words
:: main ( -- )
    command-line get first :> allocator
    command-line get second "check" = :> checked
    allocator select-allocator
    checked check-allocation? namespaces:set
    checked check-ssa? namespaces:set
    f global-value-numbering? namespaces:set
    [ ] yield-hook namespaces:set
    benchmark-words get-global :> selected
    H{ } clone "scope" "kind" pick set-at
    allocator "allocator" pick set-at
    checked "checked" pick set-at
    selected [ [ word-id ] [ number>string ] bi* "|" glue ] map-index "words" pick set-at emit
    compiler_instructions :> before
    compiler_cpu_seconds :> cpu
    [ selected compile ] benchmark :> ns
    compiler-errors get assoc-size 0 assert=
    H{ } clone "compile" "kind" pick set-at
    ns "ns" pick set-at
    compiler_cpu_seconds cpu - "cpu_seconds" pick set-at
    compiler_instructions before - "instructions" pick set-at emit
    workloads [| word | word -1 sample ] each
    checked [ ] [ 5 [| trial | workloads [| word | word trial sample ] each ] each-integer ] if ;
