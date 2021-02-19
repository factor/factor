USING: accessors arrays classes classes.algebra classes.algebra.private
classes.dispatch classes.private combinators generic generic.single kernel make
present sequences ;

IN: classes.dispatch.eql

! * Eql specializers

TUPLE: eql-specializer { obj read-only } ;

C: <eql-specializer> eql-specializer
INSTANCE: eql-specializer dispatch-type

! M: wrapper class>dispatch wrapped>> <eql-specializer> ;

M: eql-specializer predicate-def
    obj>> [ = ] curry ;

! TODO: Does present introduce dep cycle here?
M: eql-specializer class-name obj>> present "=" prepend ;

M: eql-specializer implementor-classes obj>> class-of 1array ;

M: eql-specializer (flatten-class) obj>> class-of , ;

! An instance of an eql specializer is a proper subset of all instances of the
! corresponding base class.
! A base class can not be an instance of an eql specializer, (except for if it is
! a singleton class with the same name)?
M: eql-specializer right-dispatch<=
    over eql-specializer? [ [ obj>> ] bi@ = ] [ 2drop f ] if ;
M: eql-specializer left-dispatch<=
    [ obj>> class-of ] dip class<= ;


! Instances of an eql specializer do only intersect iff they are the same
M: eql-specializer (classes-intersect?)
    { { [ over eql-specializer? ] [ [ obj>> ] same? ] }
      [ obj>> class-of classes-intersect? ] } cond ;
