! Copyright (C) 2008, 2010 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel make math math.order math.parser
sequences sorting.functor strings unicode ;
IN: sorting.human

: cut-find ( sequence pred -- before after )
    [ drop ] [ find drop ] 2bi dup [ cut ] when ; inline

: cut3 ( sequence pred -- first mid last )
    [ cut-find ] keep [ not ] compose cut-find ; inline

: find-sequences ( sequence pred quot -- sequences )
    '[
        [
            _ cut3 [
                [ , ]
                [ [ @ , ] when* ] bi*
            ] dip dup
        ] loop drop
    ] { } make ; inline

: find-numbers ( sequence -- sequence' )
    [ digit? ] [ string>number ] find-sequences ;

! For comparing integers or sequences
TUPLE: alphanum obj ;

: <alphanum> ( obj -- alphanum )
    alphanum new
        swap >>obj ; inline

: <alphanum-insensitive> ( obj -- alphanum )
    alphanum new
        swap dup string? [ w/collation-key ] when >>obj ; inline

M: alphanum <=>
    [ obj>> ] bi@
    2dup [ integer? ] bi@ xor [
        drop integer? +lt+ +gt+ ?
    ] [
        <=>
    ] if ;

<< "human" [ find-numbers [ <alphanum> ] map ] define-sorting >>
<< "humani" [ find-numbers [ <alphanum-insensitive> ] map ] define-sorting >>
