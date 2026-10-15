! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.private classes
classes.tuple.private compiler.units cpu.architecture generic grouping growable hashtables
hashtables.private io kernel libc math math.parser memory
namespaces namespaces.private quotations quotations.private
sbufs sequences sequences.private splitting system vectors
vocabs vocabs.loader words ;
FROM: compiler => enable-optimizer ;
IN: bootstrap.compiler

! Don't bring this in when deploying, since it will store a
! reference to 'eval' in a global variable
"staging" get [
    "alien.remote-control" require
] unless

{ "boostrap.compiler" "prettyprint" } "alien.prettyprint" require-when

"cpu." cpu name>> append require

enable-cpu-features

enable-optimizer

! Push all tuple layouts to tenured space to improve method caching
gc

: compile-unoptimized ( words -- )
    [ [ subwords ] map ] keep suffix concat
    [ word-optimized? ] reject compile ;

! Preserve each vocabulary's subword-then-word expansion before batching.
: bootstrap-vocab-words ( vocab -- words )
    vocab-words [ [ subwords ] map ] keep suffix concat ;

: compile-bootstrap-vocab-batch ( vocabs -- )
    [ [ bootstrap-vocab-words ] map concat
      [ word-optimized? ] reject compile ]
    [ [ drop "." write ] each flush ] bi ;

! Freeze the original subword/word queue before publishing any code.
! Publishing each warm-up word lets later words use compiled helpers.
: compile-bootstrap-warmup ( words -- )
    [ [ subwords ] map ] keep suffix concat
    [ word-optimized? ] reject
    [ 1array compile ] each ;

"debug-compiler" get [

    nl
    "Compiling..." write flush

    ! Compile a set of words ahead of the full compile.
    ! This set of words was determined semi-empirically
    ! using the profiler. It improves bootstrap time
    ! significantly, because frequently called words
    ! which are also quick to compile are replaced by
    ! compiled definitions as soon as possible.
    {
        not ? integer?

        2over

        array? hashtable? vector?
        tuple? sbuf? tombstone?
        ! callable? delegates to quotation-like?. Compile both before
        ! curry and compose are used throughout compiler bootstrap.
        curried? composed? quotation-like? callable?
        quotation?

        curry compose uncurry uncompose

        array-nth set-array-nth

        wrap probe

        (get-namestack)

        layout-of
    } compile-bootstrap-warmup

    "." write flush

    ! These fixed-effect leaves remain hot during compiler bootstrap.
    M\ array length M\ growable length 2array compile-bootstrap-warmup
    M\ array nth-unsafe M\ growable nth-unsafe M\ array length>>
    3array compile-bootstrap-warmup

    ! Compiler passes use these methods heavily. Compile them before the
    ! larger arithmetic and sequence batches.
    M\ hashtable at* M\ hashtable set-at 2array compile-bootstrap-warmup

    ! Hash-table growth and mutation remain separate calls in compiler code.
    M\ hashtable delete-at \ grow-hash \ maybe-set-at 3array compile-bootstrap-warmup

    {
        bitand bitor bitxor bitnot
    } compile-bootstrap-warmup

    "." write flush

    {
        + * 2/ < <= > >= shift
    } compile-bootstrap-warmup

    "." write flush

    {
        new-sequence nth push pop last flip
    } compile-bootstrap-warmup

    "." write flush

    {
        hashcode* = equal? assoc-stack assoc-stack-from get set
    } compile-bootstrap-warmup

    "." write flush

    {
        member-eq? split harvest sift cut cut-slice subseq-start subseq-index
        index clone set-at reverse push-all class-of number>string string>number
        like clone-like
    } compile-bootstrap-warmup

    "." write flush

    {
        read-lines prefix suffix unclip new-assoc assoc-union!
        word-prop set-word-prop 1array 2array 3array ?nth
    } compile-bootstrap-warmup

    "." write flush

    os windows? [
        "GetLastError" "windows.kernel32" lookup-word
        "FormatMessageW" "windows.kernel32" lookup-word
        2array compile-bootstrap-warmup
    ] when

    os unix? [
        "(dlerror)" "alien.libraries.unix" lookup-word
        1array compile-bootstrap-warmup
    ] when

    {
        malloc calloc free memcpy
    } compile-bootstrap-warmup

    "." write flush

    ! Compile profiled helpers before the compiler passes that use them.
    ! Look up already-loaded words without changing vocabulary load order.
    nl "Optimizing bootstrap helpers..." print flush
    {
        { "compile" "compiler.units" }
        { "backend" "compiler" }
        { "infer-quot-here" "stack-checker.backend" }
        { "infer-quot" "stack-checker.backend" }
        { "sequence-operator" "sequences.private" }
        { "copy-unsafe" "sequences.private" }
        { "(infer-if)" "stack-checker.branches" }
        { "(adjoin)" "hash-sets.private" }
        { "infer-branches" "stack-checker.branches" }
        { "infer-ndip" "stack-checker.known-words" }
        { "struct-class?" "classes.struct" }
        { "update-code-heap" "compiler.units.private" }
        { "tuple-class?" "classes.tuple" }
        { "length-operator" "sequences.private" }
        { "concat-as" "sequences" }
        { "inline-recursive-word" "stack-checker.inlining" }
        { "apply-literal-values-transform" "stack-checker.transforms" }
        { "superclass-of" "classes" }
        { "hash-count+" "hashtables.private" }
        { "at" "assocs" }
        { "grow-hash" "hash-sets.private" }
        { "new-dlist-link" "dlists" }
        { "push-front" "deques" }
        { "nearest-class" "generic" }
        { "subseq-unsafe-as" "sequences.private" }
        { "(selector-as)" "sequences.private" }
        { "2nth-unsafe" "sequences.private" }
        { "interesting-classes" "generic.private" }
        { "infer-shuffle" "stack-checker.known-words" }
        { "length-iterator" "sequences.private" }
        { ">underlying<" "sequences.private" }
        { "search-alist" "assocs.private" }
        { "reset-hash" "hash-sets.private" }
        { "assoc-operator" "assocs.private" }
        { "<hash-array>" "hash-sets.private" }
        { "compress-path" "compiler.utilities" }
        { "meta-d" "stack-checker.state" }
        ! These run while compiling the compiler passes themselves.
        { "finalize" "compiler.tree.finalization" }
        { "finalize*" "compiler.tree.finalization" }
        { "cached-expansion" "compiler.tree.finalization" }
    } [ first2 lookup-word ] map compile-unoptimized

    ! Optimize the compiler passes before using them for the full sweep.
    { "compiler.tree" "compiler.cfg" } [
        dup "Optimizing " write write "..." print flush
        loaded-vocab-names swap [ head? ] curry filter
        [ vocab-words compile-unoptimized ] each
    ] each

    "Optimizing loaded vocabularies..." print flush
    loaded-vocab-names 4 group [ compile-bootstrap-vocab-batch ] each

    " done" print flush

    "alien.syntax" require
    "io.streams.byte-array.fast" require

] unless
