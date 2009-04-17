! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors words sequences math prettyprint kernel arrays io
io.styles namespaces assocs kernel.private strings combinators
sorting math.parser vocabs definitions tools.profiler.private
continuations generic compiler.units sets classes fry ;
IN: tools.profiler

: profile ( quot -- )
    [ t profiling call ] [ f profiling ] [ ] cleanup ; inline

: filter-counts ( alist -- alist' )
    [ second 0 > ] filter ;

: map-counters ( obj quot -- alist )
    { } map>assoc filter-counts ; inline

: counters ( words -- alist )
    [ dup counter>> ] map-counters ;

: cumulative-counters ( obj quot -- alist )
    '[ dup @ [ counter>> ] sigma ] map-counters ; inline

: vocab-counters ( -- alist )
    vocabs [ words [ predicate? not ] filter ] cumulative-counters ;

: generic-counters ( -- alist )
    all-words [ subwords ] cumulative-counters ;

: methods-on ( class -- methods )
    dup implementors [ method ] with map ;

: class-counters ( -- alist )
    classes [ methods-on ] cumulative-counters ;

: method-counters ( -- alist )
    all-words [ subwords ] map concat counters ;

: profiler-usage ( word -- words )
    [ smart-usage [ word? ] filter ]
    [ compiled-generic-usage keys ]
    [ compiled-usage keys ]
    tri 3append prune ;

: usage-counters ( word -- alist )
    profiler-usage counters ;

: counters. ( assoc -- )
    sort-values simple-table. ;

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
    usage-counters counters. ;

: vocabs-profile. ( -- )
    "Call counts for all vocabularies:" print
    vocab-counters counters. ;

: generic-profile. ( -- )
    "Call counts for methods on generic words:" print
    generic-counters counters. ;

: class-profile. ( -- )
    "Call counts for methods on classes:" print
    class-counters counters. ;

: method-profile. ( -- )
    "Call counts for all methods:" print
    method-counters counters. ;
