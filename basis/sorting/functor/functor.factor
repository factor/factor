! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: functors2 quotations strings ;
IN: sorting.functor

INLINE-FUNCTOR: sorting ( name: name quot: string -- ) [=[
    : ${name}<=> ( obj1 obj2 -- <=> ) ${quot} compare ;
    : ${name}>=< ( obj1 obj2 -- >=< ) ${name}<=> invert-comparison ;
]=]
