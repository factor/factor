! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.private classes
classes.tuple.private compiler.units cpu.architecture hashtables
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
        not ?

        2over

        array? hashtable? vector?
        tuple? sbuf? tombstone?
        curried? composed? callable?
        quotation?

        curry compose uncurry

        array-nth set-array-nth

        wrap probe

        (get-namestack)

        layout-of
    } compile-unoptimized

    "." write flush

    {
        bitand bitor bitxor bitnot
    } compile-unoptimized

    "." write flush

    {
        + * 2/ < <= > >= shift
    } compile-unoptimized

    "." write flush

    {
        new-sequence nth push pop last flip
    } compile-unoptimized

    "." write flush

    {
        hashcode* = equal? assoc-stack assoc-stack-from get set
    } compile-unoptimized

    "." write flush

    {
        member-eq? split harvest sift cut cut-slice subseq-start subseq-index
        index clone set-at reverse push-all class-of number>string string>number
        like clone-like
    } compile-unoptimized

    "." write flush

    {
        read-lines prefix suffix unclip new-assoc assoc-union!
        word-prop set-word-prop 1array 2array 3array ?nth
    } compile-unoptimized

    "." write flush

    os windows? [
        "GetLastError" "windows.kernel32" lookup-word
        "FormatMessageW" "windows.kernel32" lookup-word
        2array compile-unoptimized
    ] when

    os unix? [
        "(dlerror)" "alien.libraries.unix" lookup-word
        1array compile-unoptimized
    ] when

    {
        malloc calloc free memcpy
    } compile-unoptimized

    "." write flush

    loaded-vocab-names [ vocab-words compile-unoptimized "." write flush ] each

    " done" print flush

    "alien.syntax" require
    "io.streams.byte-array.fast" require

] unless
