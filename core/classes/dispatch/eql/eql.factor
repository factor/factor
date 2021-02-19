USING: accessors arrays classes classes.algebra classes.algebra.private
classes.dispatch classes.private generic generic.single kernel make present
sequences ;

IN: classes.dispatch.eql

! * Eql specializers

TUPLE: eql-specializer { obj read-only } ;

C: <eql-specializer> eql-specializer
INSTANCE: eql-specializer dispatch-type

! M: wrapper class>dispatch wrapped>> <eql-specializer> ;

M: eql-specializer predicate-def
    obj>> [ = ] curry picker prepose ;

! TODO: Does present introduce dep cycle here?
M: eql-specializer class-name obj>> present "=" prepend ;

M: eql-specializer implementor-classes obj>> class-of 1array ;

M: eql-specializer (flatten-class) obj>> class-of , ;

GENERIC#: eql-specializer-dispatch<= 1 ( class1 class2 -- ? )

M: eql-specializer dispatch<= eql-specializer-dispatch<= ;
M: eql-specializer eql-specializer-dispatch<=
    [ obj>> class-of ] bi@ class<= ;
M: classoid eql-specializer-dispatch<=
    obj>> class-of class<= ;

! Only occurs in nested context dispatching on top of stack
! M: eql-specializer nth-dispatch-class
!     obj>> class-of nth-dispatch-class ;

! M: eql-specializer nth-dispatch-applicable?

! TODO: maybe intersection should not be lowered to this.  Instead, the covariant-tuple context could cover this in covariant-classes?
M: eql-specializer (classes-intersect?)
    [ dup eql-specializer? [ obj>> class-of ] when ] dip
    obj>> class-of classes-intersect? ;
