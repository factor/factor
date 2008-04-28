! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler cpu.architecture vocabs.loader system sequences
namespaces parser kernel kernel.private classes classes.private
arrays hashtables vectors classes.tuple sbufs inference.dataflow
hashtables.private sequences.private math classes.tuple.private
growable namespaces.private assocs words generator command-line
vocabs io prettyprint libc compiler.units math.order ;
IN: bootstrap.compiler

! Don't bring this in when deploying, since it will store a
! reference to 'eval' in a global variable
"deploy-vocab" get [
    "alien.remote-control" require
] unless

"cpu." cpu word-name append require

enable-compiler

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
    tuple? sbuf? node? tombstone?

    array-capacity array-nth set-array-nth

    wrap probe

    underlying

    find-pair-next namestack*

    bitand bitor bitxor bitnot
} compile

"." write flush

{
    + 1+ 1- 2/ < <= > >= shift min
} compile

"." write flush

{
    new-sequence nth push pop peek
} compile

"." write flush

{
    hashcode* = get set
} compile

"." write flush

{
    . lines
} compile

"." write flush

{
    malloc calloc free memcpy
} compile

vocabs [ words [ compiled? not ] filter compile "." write flush ] each

" done" print flush
