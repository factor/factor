USING: accessors arrays classes classes.algebra classes.algebra.private
classes.dispatch classes.private combinators generalizations kernel math
math.order sequences ;

IN: classes.dispatch.covariant-tuples

TUPLE: covariant-tuple { classes read-only } ;
INSTANCE: covariant-tuple classoid
INSTANCE: covariant-tuple dispatch-type

M: covariant-tuple class-name
    classes>> <reversed> [ class-name ] map "->" join ;

M: covariant-tuple class>dispatch ;

: <covariant-tuple> ( classes -- classoid )
    [ classoid check-instance ] { } map-as covariant-tuple boa ;

: remove-redundant ( classes -- classes )
    dup [ object class= not ] find
    [ tail-slice ] [ 2drop f ] if ;

M: covariant-tuple dispatch-arity classes>>
    remove-redundant length ;

M: covariant-tuple nth-dispatch-class
    classes>> <reversed> ?nth object or ;

M: covariant-tuple nth-dispatch-applicable?
    classes>> <reversed> ?nth [ class<= ] [ drop t ] if* ;

M: class class>dispatch 1array <covariant-tuple> ;

! * Sorting
: covariant-classes ( first second -- first second )
    [ dup covariant-tuple? [ classes>> ] [ 1array ] if ] bi@
    object [ 2dup max-length ] dip [ pad-head ] 2curry bi@ ; inline

GENERIC#: covariant-tuple<= 1 ( class1 class2 -- ? )
M: covariant-tuple covariant-tuple<=
    covariant-classes [ class<= ] 2all? ;
M: covariant-tuple dispatch<=
    covariant-tuple<= ;

! TODO Dispatch falls back to this to call a lexicographically ordered more
! specific method right now, although this should never happen if ambiguity
! errors are caught correctly.  It is always done as a first step of sorting
! classes though.
M: covariant-tuple <=>
    covariant-classes <reversed> <=> ;

! Union and intersection should (union definitely) be distributive over
! covariant tuples.
PREDICATE: covariant-tuple-intersection < anonymous-intersection
    participants>> [ f ] [ [ covariant-tuple? ] all? ] if-empty ;

M: covariant-tuple-intersection normalize-class
    participants>> [ classes>> ] map flip
    [ <anonymous-intersection> ] map <covariant-tuple> ;

PREDICATE: covariant-tuple-union < anonymous-union
    members>> [ f ] [ [ covariant-tuple? ] all? ] if-empty ;

M: covariant-tuple-union normalize-class
    members>> [ classes>> ] map flip
    [ <anonymous-union> ] map <covariant-tuple> ;

! TODO: Check if semantics are correct here!
! It is stated that the intersection is empty, if no object can be an instance
! of both classes at the same time.  With dispatch in mind, I would say that if
! there is any position that can not be an instance of both, two dispatches are
! exclusive.
M: covariant-tuple (classes-intersect?)
    covariant-classes
    [ classes-intersect? ] 2all? ;


M: covariant-tuple dispatch-predicate-def
    classes>> <reversed>
    [ 1 + swap '{ [ _ npick _ instance? not ] [ f ] } ] map-index
    [ t ] suffix
    '[ _ cond ] ;
