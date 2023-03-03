! Copyright (C) 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs effects kernel math math.bits
regexp.ast regexp.classes regexp.transition-tables sequences
sets ;
IN: regexp.disambiguate

TUPLE: parts in out ;

: make-partition ( choices classes -- partition )
    zip [ first ] partition [ values ] bi@ parts boa ;

: powerset-partition ( sequence -- partitions )
    [ length [ 2^ <iota> ] keep ] keep '[ _ <bits> _ make-partition ] map rest ;

: partition>class ( parts -- class )
    [ out>> [ <not-class> ] map ]
    [ in>> <and-class> ] bi prefix <and-class> ;

: singleton-partition ( integer non-integers -- {class,partition} )
    dupd
    '[ _ [ class-member? ] with filter ] keep
    prefix f parts boa
    2array ;

: add-out ( seq partition -- partition' )
    [ nip in>> ] [ out>> append ] 2bi parts boa ;

: meaningful-integers ( partition table -- integers )
    [ [ in>> ] [ out>> ] bi ] dip
    '[ [ _ at ] map intersect-all ] bi@ diff ;

: class-integers ( classes integers -- table )
    '[ _ over '[ _ class-member? ] filter ] H{ } map>assoc ;

: add-integers ( partitions classes integers -- partitions )
    class-integers '[
        [ _ meaningful-integers ] [ ] bi add-out
    ] map ;

:: class-partitions ( classes -- assoc )
    classes [ integer? ] partition :> ( integers classes )

    classes powerset-partition classes integers add-integers
    [ [ partition>class ] [ ] bi 2array ] map sift-keys
    integers [ classes singleton-partition ] map append ;

: new-transitions ( transitions -- assoc ) ! assoc is class, partition
    values [ keys ] gather [ tagged-epsilon? ] reject class-partitions ;

: get-transitions ( partition state-transitions -- next-states )
    [ in>> ] dip '[ _ at ] gather sift ;

: disambiguate ( nfa -- nfa )
    expand-ors [
        dup new-transitions '[
            [
                _ swap '[ _ get-transitions ] assoc-map
                harvest-values
            ] [
                [ drop tagged-epsilon? ] assoc-filter
            ] bi H{ } assoc-union-as
        ] assoc-map
    ] change-transitions ;
