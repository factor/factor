! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: functors2 quotations strings ;
IN: sorting.functor

SAME-FUNCTOR: sorting ( NAME: name QUOT: string -- ) [[
    : ${NAME}<=> ( obj1 obj2 -- <=> ) ${QUOT} compare ;
    : ${NAME}>=< ( obj1 obj2 -- >=< ) ${NAME}<=> invert-comparison ;
]]
