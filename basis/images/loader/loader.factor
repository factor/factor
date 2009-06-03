! Copyright (C) 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: constructors kernel splitting unicode.case combinators
accessors images io.pathnames namespaces assocs ;
IN: images.loader

ERROR: unknown-image-extension extension ;

<PRIVATE
SYMBOL: types
types [ H{ } clone ] initialize

: image-class ( path -- class )
    file-extension >lower types get ?at
    [ unknown-image-extension ] unless ;
PRIVATE>

: register-image-class ( extension class -- )
    swap types get set-at ;

: load-image ( path -- image )
    dup image-class new load-image* ;
