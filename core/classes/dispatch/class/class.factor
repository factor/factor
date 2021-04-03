USING: accessors arrays classes classes.algebra classes.algebra.private
classes.dispatch classes.private generic kernel make present sequences
stack-checker.dependencies words ;

IN: classes.dispatch.class

! * Dispatching on Classes

! Allows implementing class methods.

TUPLE: class-specializer { class maybe{ class } read-only } ;

C: <class-specializer> class-specializer
INSTANCE: class-specializer dispatch-type

M: class-specializer predicate-def
    class>> [ class<= ] curry ;

M: class-specializer class-name class>> present "class<=" prepend ;

M: class-specializer implementor-classes class>> 1array ;

! NOTE: Not yet 100% sure here if the semantics are correct.  While the cover of
! a class itself is actually `{ word }`, the cover of a tuple class is '{ tuple }'.
! The main point of this is to make sure that the methods are correctly assigned
! to built-in or tuple classes for dispatch decision tree building.  Since
! we want to dispatch on words, this needs to be a word, then...
M: class-specializer (flatten-class) drop word , ;

! This implements the actual hierarchy.  For class methods, we want to delegate
! to superclasses.  Classes and objects are incomparable, so these live in their
! own scope.
M: class-specializer left-dispatch<=
    dup class-specializer?
    [ right-dispatch<= ] [ 2drop f ] if ;

M: class-specializer right-dispatch<=
    over class-specializer?
    [ [ class>> ] bi@ class<= ] [ 2drop f ] if ;

! Two classes intersect, if there are objects that can be an instance of both.
! Two class specializers intersect, if their classes intersect.  No other
! dispatch type can overlap with a class-specializer (Except for eql
! specializers on class words ?)
M: class-specializer (classes-intersect?)
    over class-specializer?
    [ [ class>> ] bi@ classes-intersect? ] [ 2drop f ] if ;

M: class-specializer add-depends-on-class
    class>> add-depends-on-class ;
