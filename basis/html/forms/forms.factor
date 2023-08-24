! Copyright (C) 2008, 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes continuations hashtables kernel
math mirrors namespaces sequences strings words xml.syntax
xml.writer ;
IN: html.forms

TUPLE: form errors values validation-failed ;

: <form> ( -- form )
    form new
        V{ } clone >>errors
        H{ } clone >>values ;

M: form clone
    call-next-method
        [ clone ] change-errors
        [ clone ] change-values ;

: check-value-name ( name -- name )
    string check-instance ;

: values ( -- assoc )
    form get values>> ;

: value ( name -- value )
    check-value-name values at ;

: set-value ( value name -- )
    check-value-name values set-at ;

: begin-form ( -- ) <form> form set ;

: prepare-value ( name object -- value name object )
    [ [ value ] keep ] dip ; inline

: from-object ( object -- )
    [ values ] [ make-mirror ] bi* assoc-union! drop ;

: to-object ( destination names -- )
    [ make-mirror ] [ values extract-keys ] bi* assoc-union! drop ;

: with-each-value ( name quot -- )
    [ value ] dip '[
        [
            form [ clone ] change
            1 + "index" set-value
            "value" set-value
            @
        ] with-scope
    ] each-index ; inline

: with-each-object ( name quot -- )
    [ value ] dip '[
        [
            begin-form
            1 + "index" set-value
            from-object
            @
        ] with-scope
    ] each-index ; inline

SYMBOL: nested-forms

: with-form ( name quot -- )
    '[
        _
        [ nested-forms [ swap prefix ] change ]
        [ value form set ]
        bi
        @
    ] with-scope ; inline

: nest-form ( name quot -- )
    swap [
        [
            <form> form set
            call
            form get
        ] with-scope
    ] dip set-value ; inline

TUPLE: validation-error-state value message ;

C: <validation-error-state> validation-error-state

: validation-error ( message -- )
    form get
    t >>validation-failed
    errors>> push ;

: validation-failed? ( -- ? )
    form get validation-failed>> ;

: define-validators ( class validators -- )
    >hashtable "validators" set-word-prop ;

: validate ( value quot -- result )
    '[ _ call( value -- validated ) ] [ <validation-error-state> ] recover ;

: validate-value ( name value quot -- )
    validate
    dup validation-error-state? [ form get t >>validation-failed drop ] when
    swap set-value ;

: validate-values ( assoc validators -- )
    swap '[ [ dup _ at ] dip validate-value ] assoc-each ;

: render-validation-errors ( -- )
    form get errors>>
    [
        [ [XML <li><-></li> XML] ] map
        [XML <ul class="errors"><-></ul> XML] write-xml
    ] unless-empty ;
