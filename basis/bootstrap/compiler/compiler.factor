! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler cpu.architecture vocabs.loader system
sequences namespaces parser kernel kernel.private classes
classes.private arrays hashtables vectors classes.tuple sbufs
hashtables.private sequences.private math classes.tuple.private
growable namespaces.private assocs words command-line vocabs io
io.encodings.string libc splitting math.parser
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

: compile-uncompiled ( words -- )
    [ compiled>> not ] filter compile ;

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
} compile-uncompiled

"." write flush

{
    bitand bitor bitxor bitnot
} compile-uncompiled

"." write flush

{
    + 1+ 1- 2/ < <= > >= shift
} compile-uncompiled

"." write flush

{
    new-sequence nth push pop peek flip
} compile-uncompiled

"." write flush

{
    hashcode* = get set
} compile-uncompiled

"." write flush

{
    memq? split harvest sift cut cut-slice start index clone
    set-at reverse push-all class number>string string>number
} compile-uncompiled

"." write flush

{
    lines prefix suffix unclip new-assoc update
    word-prop set-word-prop 1array 2array 3array ?nth
} compile-uncompiled

"." write flush

{
    malloc calloc free memcpy
} compile-uncompiled

"." write flush

{ build-tree } compile-uncompiled

"." write flush

{ optimize-tree } compile-uncompiled

"." write flush

{ optimize-cfg } compile-uncompiled

"." write flush

{ (compile) } compile-uncompiled

"." write flush

vocabs [ words compile-uncompiled "." write flush ] each

" done" print flush
