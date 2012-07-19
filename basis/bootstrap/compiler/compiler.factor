! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors cpu.architecture vocabs system
sequences namespaces parser kernel kernel.private classes
classes.private arrays hashtables vectors classes.tuple sbufs
hashtables.private sequences.private math classes.tuple.private
growable namespaces.private assocs words command-line io
io.encodings.string libc splitting math.parser memory compiler.units
math.order quotations quotations.private assocs.private vocabs.loader ;
FROM: compiler => enable-optimizer ;
IN: bootstrap.compiler

"profile-compiler" get [
    "bootstrap.compiler.timing" require
] when

! Don't bring this in when deploying, since it will store a
! reference to 'eval' in a global variable
"deploy-vocab" get "staging" get or [
    "alien.remote-control" require
] unless

{ "boostrap.compiler" "prettyprint" } "alien.prettyprint" require-when
{ "boostrap.compiler" "debugger" } "alien.debugger" require-when

"cpu." cpu name>> append require

enable-optimizer

! Push all tuple layouts to tenured space to improve method caching
gc

: compile-unoptimized ( words -- )
    [ [ subwords ] map ] keep suffix concat
    [ optimized? not ] filter compile ;

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
        curry? compose? callable?
        quotation?

        curry compose uncurry

        array-nth set-array-nth

        wrap probe

        namestack*

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
        hashcode* = equal? assoc-stack (assoc-stack) get set
    } compile-unoptimized

    "." write flush

    {
        member-eq? split harvest sift cut cut-slice start index clone
        set-at reverse push-all class-of number>string string>number
        like clone-like
    } compile-unoptimized

    "." write flush

    {
        lines prefix suffix unclip new-assoc assoc-union!
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

    vocabs [ words compile-unoptimized "." write flush ] each

    " done" print flush

    "alien.syntax" require
    "io.streams.byte-array.fast" require

] unless
