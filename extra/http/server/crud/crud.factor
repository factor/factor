! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces db.tuples math.parser
accessors fry locals hashtables validators
http.server
http.server.actions
http.server.components
http.server.forms ;
IN: http.server.crud

:: <view-action> ( form ctor -- action )
    <action>
        { { "id" [ v-number ] } } >>get-params

        [ "id" get ctor call select-tuple from-tuple ] >>init

        [ form view-form ] >>display ;

: <id-redirect> ( id next -- response )
    swap "id" associate <standard-redirect> ;

:: <edit-action> ( form ctor next -- action )
    <action>
        { { "id" [ [ v-number ] v-optional ] } } >>get-params

        [
            "id" get ctor call

            "id" get
            [ select-tuple from-tuple ]
            [ from-tuple form set-defaults ]
            if
        ] >>init

        [ form edit-form ] >>display

        [
            f ctor call from-tuple

            form validate-form

            values-tuple
            "id" value [ update-tuple ] [ insert-tuple ] if

            "id" value next <id-redirect>
        ] >>submit ;

:: <delete-action> ( ctor next -- action )
    <action>
        { { "id" [ v-number ] } } >>post-params

        [
            "id" get ctor call delete-tuples

            next f <standard-redirect>
        ] >>submit ;

:: <list-action> ( form ctor -- action )
    <action>
        [
            blank-values

            f ctor call select-tuples "list" set-value

            form view-form
        ] >>display ;
