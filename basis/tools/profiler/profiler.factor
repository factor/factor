! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors words sequences math prettyprint kernel arrays io
io.styles namespaces assocs kernel.private strings combinators
sorting math.parser vocabs definitions tools.profiler.private
continuations generic compiler.units sets ;
IN: tools.profiler

: profile ( quot -- )
    [ t profiling call ] [ f profiling ] [ ] cleanup ;

: counters ( words -- assoc )
    [ dup counter>> ] { } map>assoc ;

GENERIC: (profile.) ( obj -- )

TUPLE: usage-profile word ;

C: <usage-profile> usage-profile

M: word (profile.)
    [ name>> "( no name )" or ] [ <usage-profile> ] bi write-object ;

TUPLE: vocab-profile vocab ;

C: <vocab-profile> vocab-profile

M: string (profile.)
    dup <vocab-profile> write-object ;

M: method-body (profile.)
    [ synopsis ] [ "method-generic" word-prop <usage-profile> ] bi
    write-object ;

: counter. ( obj n -- )
    [
        [ [ (profile.) ] with-cell ] dip
        [ number>string write ] with-cell
    ] with-row ;

: counters. ( assoc -- )
    [ second 0 > ] filter sort-values
    standard-table-style [
        [ counter. ] assoc-each
    ] tabular-output ;

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
    [ smart-usage [ word? ] filter ]
    [ compiled-generic-usage keys ]
    [ compiled-usage keys ]
    tri 3append prune counters counters. ;

: vocabs-profile. ( -- )
    "Call counts for all vocabularies:" print
    vocabs [
        dup words
        [ "predicating" word-prop not ] filter
        [ counter>> ] map sum
    ] { } map>assoc counters. ;

: method-profile. ( -- )
    all-words [ subwords ] map concat
    counters counters. ;
