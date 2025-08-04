! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.tuple effects
effects.parser kernel lexer parser sequences
sequences.generalizations sets words ;
IN: constructors

: all-slots-assoc ( class -- slots )
    superclasses-of [
        [ "slots" word-prop ] keep '[ _ ] map>alist
    ] map concat ;

MACRO:: slots>boa ( slots class -- quot )
    class all-slots-assoc slots [ '[ first name>> _ = ] find-last nip ] with map :> slot-assoc
    class all-slots-assoc [ [ ] [ first initial>> ] bi ] map>alist :> default-params
    slots length
    default-params length
    '[
        _ narray slot-assoc swap zip
        default-params swap assoc-union values _ firstn class boa
    ] ;

ERROR: repeated-constructor-parameters class effect ;

ERROR: unknown-constructor-parameters class effect unknown ;

: ensure-constructor-parameters ( class effect -- class effect )
    dup in>> all-unique? [ repeated-constructor-parameters ] unless
    2dup [ all-slots [ name>> ] map ] [ in>> ] bi* swap diff
    [ unknown-constructor-parameters ] unless-empty ;

: constructor-boa-quot ( constructor-word class effect -- word quot )
    in>> swap '[ _ _ slots>boa ] ; inline

: define-constructor ( constructor-word class effect -- )
    ensure-constructor-parameters
    [ constructor-boa-quot ] keep define-declared ;

: create-reset ( string -- word )
    create-word-in dup reset-generic ;

: scan-constructor ( -- word class )
    scan-new-word scan-class ;

: parse-constructor ( -- word class effect def )
    scan-constructor scan-effect ensure-constructor-parameters
    parse-definition ;

SYNTAX: CONSTRUCTOR:
    parse-constructor
    [ [ constructor-boa-quot ] dip compose ] keepd
    define-declared ;

: scan-rest-input-effect ( -- effect )
    ")" parse-effect-tokens nip
    { "obj" } <effect> ;

: scan-full-input-effect ( -- effect )
    "(" expect scan-rest-input-effect ;

SYNTAX: SLOT-CONSTRUCTOR:
    scan-new-word [ name>> "(" append create-reset ] keep
    '[ scan-rest-input-effect in>> _ '[ _ _ slots>boa ] append! ] define-syntax ;
