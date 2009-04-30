! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors definitions generic generic.single
generic.single.private kernel namespaces words kernel.private
quotations sequences ;
IN: generic.hook

TUPLE: hook-combination < single-combination var ;

C: <hook-combination> hook-combination

PREDICATE: hook-generic < generic
    "combination" word-prop hook-combination? ;

M: hook-combination picker
    combination get var>> [ get ] curry ;

M: hook-combination dispatch# drop 0 ;

M: hook-combination inline-cache-quot 2drop f ;

M: hook-combination mega-cache-quot
    1quotation picker [ lookup-method (execute) ] surround ;

M: hook-generic definer drop \ HOOK: f ;

M: hook-generic effective-method
    [ "combination" word-prop var>> get ] keep (effective-method) ;