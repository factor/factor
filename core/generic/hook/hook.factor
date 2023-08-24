! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors definitions generic generic.single kernel
kernel.private namespaces quotations sequences words ;
QUALIFIED-WITH: generic.single.private gsp
IN: generic.hook

TUPLE: hook-combination < single-combination var ;

C: <hook-combination> hook-combination

PREDICATE: hook-generic < generic
    "combination" word-prop hook-combination? ;

M: hook-combination picker
    combination get var>> [ get ] curry ;

M: hook-combination dispatch# drop 0 ;

M: hook-combination mega-cache-quot
    1quotation picker [ gsp:lookup-method (execute) ] surround ;

M: hook-generic definer drop \ HOOK: f ;

M: hook-generic effective-method
    [ "combination" word-prop var>> get ] keep method-for-object ;

M: hook-combination make-consult-quot
    drop          ! combination no longer necessary
    [ drop ] 2dip ! consultation no longer necessary
    [ "combination" word-prop var>> swap ] keep ! (var quot word)
    '[ _ _ call swap [ _ execute ] with-variable ] ;
