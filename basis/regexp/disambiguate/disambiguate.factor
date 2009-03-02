! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors regexp.classes math.bits assocs sequences
arrays sets regexp.dfa math fry regexp.minimize ;
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
    [ in>> ] dip '[ _ at ] map prune ;

: disambiguate ( dfa -- nfa )  
    [
        [
            [ keys powerset-partition ] keep '[
                [ partition>class ]
                [ _ get-transitions ] bi
            ] H{ } map>assoc
            [ drop ] assoc-filter 
        ] assoc-map
    ] change-transitions ;

USE: sorting

: nfa>dfa ( nfa -- dfa )
    construct-dfa minimize
    disambiguate
    construct-dfa minimize ;
