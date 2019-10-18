! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.short-circuit constructors
fry grouping kernel math math.vectors sequences sequences.deep
math.order parser ;
IN: arrays.shaped

: flat? ( array -- ? ) [ sequence? ] any? not ; inline

GENERIC: array-replace ( object -- shape )

M: f array-replace ;

M: object array-replace drop f ;

M: sequence array-replace
    dup flat? [
        length
    ] [
        [ array-replace ] map
    ] if ;

TUPLE: uniform-shape shape ;
C: <uniform-shape> uniform-shape

TUPLE: abnormal-shape shape ;
C: <abnormal-shape> abnormal-shape

GENERIC: wrap-shape ( object -- shape )

M: integer wrap-shape
    1array <uniform-shape> ;

M: sequence wrap-shape
    dup all-equal? [
        [ length ] [ first ] bi 2array <uniform-shape>
    ] [
        <abnormal-shape>
    ] if ;

GENERIC: shape ( array -- shape )

M: sequence shape array-replace wrap-shape ;

: ndim ( array -- n ) shape length ;

ERROR: no-negative-shape-components shape ;

: check-shape-domain ( seq -- seq )
    dup [ 0 < ] any? [ no-negative-shape-components ] when ;

GENERIC: shape-capacity ( shape -- n )

M: sequence shape-capacity check-shape-domain product ;

M: uniform-shape shape-capacity
    shape>> product ;

M: abnormal-shape shape-capacity
    shape>> 0 swap [
        [ dup sequence? [ drop ] [ + ] if ] [ 1 + ] if*
    ] deep-each ;

ERROR: underlying-shape-mismatch underlying shape ;

ERROR: no-abnormally-shaped-arrays underlying shape ;

GENERIC: check-underlying-shape ( underlying shape -- underlying shape )

M: abnormal-shape check-underlying-shape
    no-abnormally-shaped-arrays ;

M: uniform-shape check-underlying-shape
    shape>> check-underlying-shape ;
    
M: sequence check-underlying-shape
    2dup [ length ] [ shape-capacity ] bi*
    = [ underlying-shape-mismatch ] unless ; inline

ERROR: shape-mismatch shaped0 shaped1 ;

: check-shape ( shaped-array shaped-array -- shaped-array shaped-array )
    2dup [ shape>> ] bi@
    sequence= [ shape-mismatch ] unless ;

TUPLE: shaped-array underlying shape ;
TUPLE: row-array < shaped-array ;
TUPLE: col-array < shaped-array ;

M: shaped-array length underlying>> length ; inline

M: shaped-array shape shape>> ;

: make-shaped-array ( underlying shape class -- shaped-array )
    [ check-underlying-shape ] dip new
        swap >>shape
        swap >>underlying ; inline

: <shaped-array> ( underlying shape -- shaped-array )
    shaped-array make-shaped-array ; inline

: <row-array> ( underlying shape -- shaped-array )
    row-array make-shaped-array ; inline

: <col-array> ( underlying shape -- shaped-array )
    col-array make-shaped-array ; inline

GENERIC: >shaped-array ( array -- shaped-array )
GENERIC: >row-array ( array -- shaped-array )
GENERIC: >col-array ( array -- shaped-array )

M: sequence >shaped-array
    [ { } flatten-as ] [ shape ] bi <shaped-array> ;

M: shaped-array >shaped-array ;

M: shaped-array >row-array
    [ underlying>> ] [ shape>> ] bi <row-array> ;

M: shaped-array >col-array
    [ underlying>> ] [ shape>> ] bi <col-array> ;

M: sequence >col-array
    [ flatten ] [ shape ] bi <col-array> ;

: shaped+ ( a b -- c )
    check-shape
    [ [ underlying>> ] bi@ v+ ]
    [ drop shape>> clone ] 2bi shaped-array boa ;

: shaped-array>array ( shaped-array -- array )
    [ underlying>> ] [ shape>> ] bi
    dup [ zero? ] any? [
        2drop { }
    ] [
        [ rest-slice [ group ] each ] unless-empty
    ] if ;

: reshape ( shaped-array shape -- array )
    check-underlying-shape >>shape ;

: shaped-like ( shaped-array shape -- array )
    [ underlying>> clone ] dip <shaped-array> ;

: repeated-shaped ( shape element -- shaped-array )
    [ [ shape-capacity ] dip <array> ]
    [ drop 1 1 pad-head ] 2bi <shaped-array> ;

: zeros ( shape -- shaped-array ) 0 repeated-shaped ;

: ones ( shape -- shaped-array ) 1 repeated-shaped ;

: increasing ( shape -- shaped-array )
    [ shape-capacity iota >array ] [ ] bi <shaped-array> ;

: decreasing ( shape -- shaped-array )
    [ shape-capacity iota <reversed> >array ] [ ] bi <shaped-array> ;

: row-length ( shape -- n ) rest-slice product ; inline

: column-length ( shape -- n ) first ; inline

: each-row ( shaped-array quot -- )
    [ [ underlying>> ] [ shape>> row-length <groups> ] bi ] dip
    each ; inline

TUPLE: transposed shaped-array ;

: transposed-shape ( shaped-array -- shape )
    shape>> <reversed> ;

TUPLE: row-traverser shaped-array index ;

GENERIC: next-index ( object -- index )

SYNTAX: sa{ \ } [ >shaped-array ] parse-literal ;

USE: prettyprint.custom
! M: row-array pprint* shaped-array>array pprint* ;
! M: col-array pprint* shaped-array>array flip pprint* ;
M: shaped-array pprint-delims drop \ sa{ \ } ;
M: shaped-array >pprint-sequence shaped-array>array ;
M: shaped-array pprint* pprint-object ;
M: shaped-array pprint-narrow? drop f ;

: shaped-each ( .. sa quot -- )
    [ underlying>> ] dip each ; inline

: shaped-map! ( .. sa quot -- sa )
    '[ _ map ] change-underlying ; inline

: shaped-map ( .. sa quot -- sa' )
    [ [ underlying>> ] dip map ]
    [ drop shape>> ] 2bi <shaped-array> ; inline

: pad-shapes ( sa0 sa1 -- sa0' sa1' )
    2dup [ shape>> ] bi@
    2dup longer length '[ _ 1 pad-head ] bi@
    [ shaped-like ] bi-curry@ bi* ;

: output-shape ( sa0 sa1 -- shape )
    [ shape>> ] bi@
    [ 2dup [ zero? ] either? [ max ] [ 2drop 0 ] if ] 2map ;

: broadcast-shape-matches? ( sa broadcast-shape -- ? )
    [
        { [ drop 1 = ] [ = ] } 2||
    ] 2all? ;

: broadcastable? ( sa0 sa1 -- ? )
    pad-shapes
    [ [ shape>> ] bi@ ] [ output-shape ] 2bi
    '[ _ broadcast-shape-matches? ] both? ;
