! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler cpu.architecture vocabs.loader system
sequences namespaces parser kernel kernel.private classes
classes.private arrays hashtables vectors classes.tuple sbufs
hashtables.private sequences.private math classes.tuple.private
growable namespaces.private assocs words command-line vocabs io
io.encodings.string libc splitting math.parser memory
compiler.units math.order compiler.tree.builder
compiler.tree.optimizer compiler.cfg.optimizer ;
IN: bootstrap.compiler

! Don't bring this in when deploying, since it will store a
! reference to 'eval' in a global variable
"deploy-vocab" get "staging" get or [
    "alien.remote-control" require
] unless

"prettyprint" vocab [
    "stack-checker.errors.prettyprint" require
    "alien.prettyprint" require
] when

"cpu." cpu name>> append require

enable-compiler

! Push all tuple layouts to tenured space to improve method caching
gc

: compile-unoptimized ( words -- )
    [ optimized? not ] filter compile ;

nl
"Compiling..." write flush

! Compile a set of words ahead of the full compile.
! This set of words was determined semi-empirically
! using the profiler. It improves bootstrap time
! significantly, because frequenly called words
! which are also quick to compile are replaced by
! compiled definitions as soon as possible.
{
    roll -roll declare not

    array? hashtable? vector?
    tuple? sbuf? tombstone?

    array-nth set-array-nth

    wrap probe

    namestack*
} compile-unoptimized

"." write flush

{
    bitand bitor bitxor bitnot
} compile-unoptimized

"." write flush

{
    + 1+ 1- 2/ < <= > >= shift
} compile-unoptimized

"." write flush

{
    new-sequence nth push pop peek flip
} compile-unoptimized

"." write flush

{
    hashcode* = get set
} compile-unoptimized

"." write flush

{
    memq? split harvest sift cut cut-slice start index clone
    set-at reverse push-all class number>string string>number
} compile-unoptimized

"." write flush

{
    lines prefix suffix unclip new-assoc update
    word-prop set-word-prop 1array 2array 3array ?nth
} compile-unoptimized

"." write flush

{
    malloc calloc free memcpy
} compile-unoptimized

"." write flush

{ build-tree } compile-unoptimized

"." write flush

{ optimize-tree } compile-unoptimized

"." write flush

{ optimize-cfg } compile-unoptimized

"." write flush

{ compile-word } compile-unoptimized

"." write flush

vocabs [ words compile-unoptimized "." write flush ] each

" done" print flush
