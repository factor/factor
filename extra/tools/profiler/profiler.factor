! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences math prettyprint kernel arrays
io io.styles namespaces assocs kernel.private generator
compiler strings combinators sorting math.parser
math.vectors vocabs definitions tools.profiler.private ;
IN: tools.profiler

: reset-counters ( -- )
    all-words [ 0 swap set-profile-counter ] each ;

: counters ( words -- assoc )
    [ dup profile-counter ] { } map>assoc ;

GENERIC: (profile.) ( obj -- )

TUPLE: usage-profile word ;

C: <usage-profile> usage-profile

M: word (profile.)
    dup unparse swap <usage-profile> write-object ;

TUPLE: vocab-profile vocab ;

C: <vocab-profile> vocab-profile

M: string (profile.)
    dup <vocab-profile> write-object ;

: counter. ( obj n -- )
    [
        >r [ (profile.) ] with-cell r>
        [ number>string write ] with-cell
    ] with-row ;

: counters. ( assoc -- )
    [ second 0 > ] subset sort-values
    standard-table-style [
        [ counter. ] assoc-each
    ] tabular-output ;

: enable-profiler ( -- )
    t profiler-prologues set-global recompile-all
    "Profiler enabled; use disable-profiler to disable" print ;

: disable-profiler ( -- )
    f profiler-prologues set-global recompile-all ;

: check-profiler ( -- )
    profiler-prologues get-global [
        "Enable the profiler by calling enable-profiler first"
        throw
    ] unless ;

: profile ( quot -- )
    check-profiler
    reset-counters
    t profiling
    call
    f profiling ;

: profile. ( -- )
    "Call counts for all words:" print
    all-words counters counters. ;

: vocab-profile. ( vocab -- )
    "Call counts for words in the " write
    dup dup vocab write-object
    " vocabulary:" print
    words counters counters. ;

: usage-profile. ( word -- )
    "Call counts for words which call " write
    dup pprint
    ":" print
    usage [ word? ] subset counters counters. ;

: vocabs-profile. ( -- )
    "Call counts for all vocabularies:" print
    vocabs [
        dup words [ profile-counter ] map sum
    ] { } map>assoc counters. ;
