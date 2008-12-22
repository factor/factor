! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors words sequences math prettyprint kernel arrays io
io.styles namespaces assocs kernel.private strings combinators
sorting math.parser vocabs definitions tools.profiler.private
continuations generic compiler.units sets classes ;
IN: tools.profiler

: profile ( quot -- )
    [ t profiling call ] [ f profiling ] [ ] cleanup ;

: filter-counts ( alist -- alist' )
    [ second 0 > ] filter ;

: counters ( words -- alist )
    [ dup counter>> ] { } map>assoc filter-counts ;

: vocab-counters ( -- alist )
    vocabs [
        dup
        words
        [ predicate? not ] filter
        [ counter>> ] sigma
    ] { } map>assoc ;

: counters. ( assoc -- )
    standard-table-style [
        sort-values simple-table.
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
    vocab-counters counters. ;

: method-profile. ( -- )
    all-words [ subwords ] map concat
    counters counters. ;
