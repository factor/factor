! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.tuple kernel sequences slots ;
IN: classes.tuple.change-tracking

TUPLE: change-tracking-tuple
    { changed? boolean } ;

PREDICATE: change-tracking-tuple-class < tuple-class
    change-tracking-tuple subclass-of? ;

: changed? ( tuple -- changed? ) changed?>> ; inline
: clear-changed ( tuple -- tuple ) f >>changed? ; inline

: filter-changed ( sequence -- sequence' ) [ changed? ] filter ; inline

<PRIVATE

M: change-tracking-tuple-class writer-quot ( class slot-spec -- quot )
    [ call-next-method ]
    [ name>> "changed?" = [ '[ _ [ t >>changed? drop ] bi ] ] unless ] bi ;

PRIVATE>
