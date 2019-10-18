! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences math prettyprint kernel arrays tools
io styles namespaces assocs ;
IN: profiler

: reset-counters ( -- )
    0 all-words [ set-profile-counter ] each-with ;

: counters ( words -- assoc )
    [ dup profile-counter ] { } map>assoc ;

: counters. ( assoc -- )
    [ second 0 > ] subset sort-values
    H{ } [
        [ [ [ pprint-cell ] each ] with-row ] each
    ] tabular-output ;

: profile ( quot -- )
    reset-counters
    t profiling
    call
    f profiling ;

: profile. ( -- ) all-words counters counters. ;

: vocab-profile. ( vocab -- ) words counters counters. ;

: usage-profile. ( word -- ) usage counters counters. ;

: vocabs-profile. ( -- )
    vocabularies get [
        values [ profile-counter ] map sum
    ] assoc-map >alist counters. ;
