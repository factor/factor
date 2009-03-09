! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors regexp.classes math.bits assocs sequences
arrays sets regexp.dfa math fry regexp.minimize regexp.ast ;
IN: regexp.disambiguate

TUPLE: parts in out ;

: make-partition ( choices classes -- partition )
    zip [ first ] partition [ values ] bi@ parts boa ;

: powerset-partition ( classes -- partitions )
    [ length [ 2^ ] keep ] keep '[
        _ <bits> _ make-partition
    ] map rest ;

: partition>class ( parts -- class )
    [ out>> [ <not-class> ] map ]
    [ in>> <and-class> ] bi
    prefix <and-class> ;

: get-transitions ( partition state-transitions -- next-states )
    [ in>> ] dip '[ _ at ] gather sift ;

: new-transitions ( transitions -- assoc ) ! assoc is class, partition
    values [ keys ] gather
    [ tagged-epsilon? not ] filter
    powerset-partition
    [ [ partition>class ] keep ] { } map>assoc
    [ drop ] assoc-filter ;

: preserving-epsilon ( state-transitions quot -- new-state-transitions )
    [ [ drop tagged-epsilon? ] assoc-filter ] bi
    assoc-union H{ } assoc-like ; inline

: disambiguate ( nfa -- nfa )  
    [
        dup new-transitions '[
            [
                _ swap '[ _ get-transitions ] assoc-map
                [ nip empty? not ] assoc-filter 
            ] preserving-epsilon
        ] assoc-map
    ] change-transitions ;
