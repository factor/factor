! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel parser vocabs.parser words ;
IN: enter
! main words are usually only used for entry, doing initialization, etc
! it makes sense, then to define it all at once, rather than factoring it out into a seperate word
! and then declaring it main
SYNTAX: ENTER: gensym [ parse-definition (( -- )) define-declared ] keep current-vocab (>>main) ;