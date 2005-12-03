! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: arrays errors hashtables kernel kernel-internals lists
namespaces parser sequences strings words vectors math
math-internals ;

! A simple single-dispatch generic word system.

! Maps lists of builtin type numbers to class objects.
SYMBOL: typemap

! Global vector mapping type numbers to builtin class objects.
SYMBOL: builtins

: type>class ( n -- symbol ) builtins get nth ;

: predicate-word ( word -- word )
    word-name "?" append create-in ;

: define-predicate ( class predicate quot -- )
    #! predicate may be f, in which case it is ignored.
    over [
        dupd define-compound
        2dup unit "predicate" set-word-prop
        swap "predicating" set-word-prop
    ] [
        3drop
    ] if ;

: superclass "superclass" word-prop ;

: members "members" word-prop ;

: (flatten) ( class -- )
    dup members [ [ (flatten) ] each ] [ dup set ] ?if ;

: flatten ( class -- classes )
    #! Outputs a sequence of classes whose union is this class.
    [ (flatten) ] make-hash ;

: (types) ( class -- )
    #! Only valid for a flattened class.
    flatten [
        drop dup superclass
        [ (types) ] [ "type" word-prop dup set ] ?if
    ] hash-each ;

: types ( class -- types )
    [ (types) ] make-hash hash-keys ;

DEFER: class<

: superclass< ( cls1 cls2 -- ? )
    >r superclass r> 2dup and [ class< ] [ 2drop f ] if ;

: union-class< ( cls1 cls2 -- ? )
    [ flatten hash-keys ] 2apply
    swap [ swap [ class< ] contains-with? ] all-with? ;

: class< ( cls1 cls2 -- ? )
    #! Test if class1 is a subclass of class2.
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over flatten hash-empty? ] [ 2drop t ] }
        { [ 2dup superclass< ] [ 2drop t ] }
        { [ 2dup [ members ] 2apply or not ] [ 2drop f ] }
        { [ t ] [ union-class< ] }
    } cond ;

: class-compare ( cls1 cls2 -- -1/0/1 )
    2dup eq? [ 2drop 0 ] [ class< 1 -1 ? ] if ;

: methods ( generic -- alist )
    "methods" word-prop hash>alist
    [ [ first ] 2apply class-compare ] sort ;

: order ( generic -- list )
    "methods" word-prop hash-keys [ class-compare ] sort ;

PREDICATE: compound generic ( word -- ? )
    "combination" word-prop ;

M: generic definer drop \ G: ;

: make-generic ( word -- )
    dup dup "combination" word-prop call define-compound ;

: class? ( word -- ? ) "class" word-prop ;

: check-method ( class generic -- )
    dup generic? [
        dup word-name " is not a generic word" append throw
    ] unless
    over "class" word-prop [
        over word-name " is not a class" append throw
    ] unless 2drop ;

: with-methods ( word quot -- | quot: methods -- )
    #! Applies a quotation to the method hash and regenerates
    #! the generic.
    swap [ "methods" word-prop swap call ] keep make-generic ;
    inline

: define-method ( definition class generic -- )
    >r bootstrap-word r> 2dup check-method
    [ set-hash ] with-methods ;

: forget-method ( class generic -- )
    [ remove-hash ] with-methods ;

: init-methods ( word -- )
     dup "methods" word-prop
     [ drop ] [ H{ } clone "methods" set-word-prop ] if ;

! Defining generic words

: bootstrap-combination ( quot -- quot )
    #! Bootstrap hack.
    global [ [ dup word? [ target-word ] when ] map ] bind ;

: define-generic* ( word combination -- )
    bootstrap-combination
    dupd "combination" set-word-prop
    dup init-methods make-generic ;

: lookup-union ( class-set -- class )
    #! The class set is a hashtable with equal keys/values.
    typemap get hash [ object ] unless* ;

: (builtin-supertypes) ( class -- )
    dup members [
        [ (builtin-supertypes) ] each
    ] [
        dup superclass [
            (builtin-supertypes)
        ] [
            dup set
        ] ?if
    ] ?if ;

: builtin-supertypes ( class -- classes )
    #! Outputs a sequence of builtin classes whose union is the
    #! smallest union of builtin classes that contains this
    #! class.
    [ (builtin-supertypes) ] make-hash ;

: (class-and) ( class class -- class )
    [ builtin-supertypes ] 2apply hash-intersect lookup-union ;

: class-and ( class class -- class )
    #! Return a class that is a subclass of both, or null in
    #! the degenerate case.
    {
        { [ 2dup class< ] [ drop ] }
        { [ 2dup swap class< ] [ nip ] }
        { [ t ] [ (class-and) ] }
    } cond ;

: classes-intersect? ( class class -- ? )
    class-and flatten hash-empty? not ;

: min-class ( class seq -- class/f )
    #! Is this class the smallest class in the sequence?
    [ dupd classes-intersect? ] subset reverse-slice
    tuck [ class< ] all-with? over empty? not and
    [ first ] [ drop f ] if ;

: define-class ( class -- )
    dup t "class" set-word-prop
    dup flatten typemap get set-hash ;

: implementors ( class -- list )
    #! Find a list of generics that implement a method
    #! specializing on this class.
    [ "methods" word-prop ?hash* nip ] word-subset-with ;

: classes ( -- list )
    #! Output a list of all defined classes.
    [ class? ] word-subset ;

! Predicate classes for generalized predicate dispatch.
: define-predicate-class ( class predicate definition -- )
    pick define-class
    3dup nip "definition" set-word-prop
    pick superclass "predicate" word-prop
    [ \ dup , % , [ drop f ] , \ if , ] [ ] make
    define-predicate ;

PREDICATE: word predicate "definition" word-prop ;

! Union classes for dispatch on multiple classes.
: union-predicate ( members -- list )
    [
        "predicate" word-prop \ dup swons [ drop t ] 2array
    ] map [ drop f ] swap alist>quot ;

: set-members ( class members -- )
    [ bootstrap-word ] map "members" set-word-prop ;

: define-union ( class predicate members -- )
    3dup nip set-members pick define-class
    union-predicate define-predicate ;

PREDICATE: word union members ;
