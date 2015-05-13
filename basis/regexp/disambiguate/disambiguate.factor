! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors regexp.classes math.bits assocs sequences
arrays sets regexp.dfa math fry regexp.minimize regexp.ast
locals regexp.transition-tables ;
IN: regexp.disambiguate

TUPLE: parts in out ;

: make-partition ( choices classes -- partition )
    zip [ first ] partition [ values ] bi@ parts boa ;

: powerset-partition ( sequence -- partitions )
    [ length [ 2^ iota ] keep ] keep '[ _ <bits> _ make-partition ] map rest ;

: partition>class ( parts -- class )
    [ out>> [ <not-class> ] map ]
    [ in>> <and-class> ] bi
    prefix <and-class> ;

: singleton-partition ( integer non-integers -- {class,partition} )
    dupd
    '[ _ [ class-member? ] with filter ] keep
    prefix f parts boa
    2array ;

: add-out ( seq partition -- partition' )
    [ out>> append ] [ in>> ] bi swap parts boa ;

: intersection ( seq -- elts )
    [ f ] [ unclip [ intersect ] reduce ] if-empty ;

: meaningful-integers ( partition table -- integers )
    [ [ in>> ] [ out>> ] bi ] dip
    '[ [ _ at ] map intersection ] bi@ diff ;

: class-integers ( classes integers -- table )
    '[ _ over '[ _ class-member? ] filter ] H{ } map>assoc ;

: add-integers ( partitions classes integers -- partitions )
    class-integers '[
        [ _ meaningful-integers ] keep add-out
    ] map ;

:: class-partitions ( classes -- assoc )
    classes [ integer? ] partition :> ( integers classes )
    
    classes powerset-partition classes integers add-integers
    [ [ partition>class ] keep 2array ] map [ first ] filter
    integers [ classes singleton-partition ] map append ;

: new-transitions ( transitions -- assoc ) ! assoc is class, partition
    values [ keys ] gather
    [ tagged-epsilon? ] reject
    class-partitions ;

: get-transitions ( partition state-transitions -- next-states )
    [ in>> ] dip '[ _ at ] gather sift ;

: preserving-epsilon ( state-transitions quot -- new-state-transitions )
    [ [ drop tagged-epsilon? ] assoc-filter ] bi
    assoc-union H{ } assoc-like ; inline

: disambiguate ( nfa -- nfa )  
    expand-ors [
        dup new-transitions '[
            [
                _ swap '[ _ get-transitions ] assoc-map
                [ nip empty? ] assoc-reject 
            ] preserving-epsilon
        ] assoc-map
    ] change-transitions ;
