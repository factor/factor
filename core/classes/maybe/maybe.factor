! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.algebra
classes.algebra.private classes.private classes.union.private
kernel words ;
IN: classes.maybe

! The class slot has to be a union of a word and a classoid
! for TUPLE: foo { a maybe{ foo } } ; and maybe{ union{ integer float } }
! to work.
! In the first case, foo is not yet a tuple-class when maybe{ is reached,
! thus it's not a classoid yet. union{ is a classoid, so the second case works.
! words are not generally classoids, so classoid alone is insufficient.
TUPLE: maybe { class union{ word classoid } initial: object read-only } ;

C: <maybe> maybe

INSTANCE: maybe classoid

M: maybe instance?
    over [ class>> instance? ] [ 2drop t ] if ;

: maybe-class-or ( maybe -- classoid )
    class>> \ f class-or ;

M: maybe normalize-class
    maybe-class-or ;

M: maybe valid-classoid? class>> valid-classoid? ;

M: maybe rank-class drop 6 ;

M: maybe (flatten-class)
    maybe-class-or (flatten-class) ;

M: maybe union-of-builtins?
    class>> union-of-builtins? ;

M: maybe class-name
    class>> class-name ;

M: maybe predicate-def
    class>> predicate-def [ [ t ] if* ] curry ;
