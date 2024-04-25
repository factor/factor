USING: accessors assocs deques dlists growable kernel math
sequences sets ;

IN: containers

GENERIC: count ( obj -- n )

M: sequence count length ;
M: assoc count assoc-size ;
M: set count cardinality ;

GENERIC: capacity ( obj -- n )

M: object capacity count ;
M: growable capacity underlying>> length ;

GENERIC: contains? ( elt obj -- ? )

M: sequence contains? member? ;
M: assoc contains? key? ;
M: set contains? sets:in? ;
M: deque contains? deque-member? ;

GENERIC: items ( obj -- seq )

M: sequence items ;
M: set items members ;
M: assoc items >alist ;
M: dlist items dlist>sequence ;

GENERIC: empty? ( obj -- ? )

M: object empty? count zero? ; inline
M: dlist empty? front>> not ; inline
M: deque empty? deque-empty? ; inline

GENERIC: add ( elt obj -- )

M: sequence add push ;
M: set add adjoin ;

GENERIC: lookup ( key obj -- elt )
M: sequence lookup nth ;
M: assoc lookup at ;

! XXX: at ( key obj -- elt ) and of ( obj key -- elt )

GENERIC: remove ( elt obj -- )

M: sequence remove remove-nth! drop ;
M: set remove delete ;

GENERIC: remove-all ( obj -- )

M: sequence remove-all delete-all ;
M: assoc remove-all clear-assoc ;
M: set remove-all clear-set ;
M: deque remove-all clear-deque ;

GENERIC: like ( obj exemplar -- newobj )

M: sequence like sequences:like ;
M: assoc like assoc-like ;
M: set like set-like ;

GENERIC: clone-like ( obj exemplar -- newobj )

M: sequence clone-like sequences:clone-like ;
M: assoc clone-like assoc-clone-like ;
