! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.cxx.parser alien.marshall
alien.inline.types classes.mixin classes.tuple kernel namespaces
assocs sequences parser classes.parser ;
IN: alien.cxx

<PRIVATE
: class-mixin ( str -- word )
    create-class-in [ define-mixin-class ] keep ;

: class-tuple-word ( word -- word' )
    "#" append create-in ;

: define-class-tuple ( word mixin -- )
    [ drop class-wrapper { } define-tuple-class ]
    [ add-mixin-instance ] 2bi ;
PRIVATE>

: define-c++-class ( str superclass-mixin -- )
    [ [ class-tuple-word ] [ class-mixin ] bi dup ] dip
    add-mixin-instance define-class-tuple ;
