! (c)2009 Joe Groff bsd license
USING: accessors classes classes.tuple fry kernel sequences slots ;
IN: classes.tuple.change-tracking

TUPLE: change-tracking-tuple
    { changed? boolean } ;

PREDICATE: change-tracking-tuple-class < tuple-class
    change-tracking-tuple subclass-of? ;

: changed? ( tuple -- changed? ) changed?>> ; inline
: clear-changed ( tuple -- tuple ) f >>changed? ; inline

: filter-changed ( sequence -- sequence' ) [ changed? ] filter ; inline

<PRIVATE

M: change-tracking-tuple-class writer-quot ( class slot-spec -- )
    [ call-next-method ]
    [ name>> "changed?" = [ '[ _ [ t >>changed? drop ] bi ] ] unless ] bi ;

PRIVATE>

