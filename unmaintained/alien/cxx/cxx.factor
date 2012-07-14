! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.cxx.parser alien.marshall
alien.inline.types classes.mixin classes.tuple kernel namespaces
assocs sequences parser classes.parser alien.marshall.syntax
interpolate locals effects io strings make vocabs.parser words
generic fry quotations ;
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

: define-c++-class ( name superclass-mixin -- )
    [ [ class-tuple-word ] [ class-mixin ] bi dup ] dip
    add-mixin-instance define-class-tuple ;

:: define-c++-method ( class-name generic name types effect virtual -- )
    [ name % "_" % class-name H{ { CHAR: : CHAR: _ } } substitute % ] "" make           :> name'
    effect [ in>> "self" suffix ] [ out>> ] bi <effect> :> effect'
    types class-name "*" append suffix                  :> types'
    effect in>> "," join                                :> args
    class-name virtual [ "#" append ] unless current-vocab lookup                  :> class
    SBUF" " clone dup [ I[ return self->${name}(${args});]I ] with-output-stream >string :> body
    name' types' effect' body define-c-marshalled
    class generic create-method name' current-vocab lookup 1quotation define ;
