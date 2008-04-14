! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces db.tuples math.parser
accessors fry locals hashtables
http.server
http.server.actions
http.server.components
http.server.forms
http.server.validators ;
IN: http.server.crud

:: <view-action> ( form ctor -- action )
    <action>
        { { "id" [ v-number ] } } >>get-params

        [ "id" get ctor call select-tuple from-tuple ] >>init

        [
            "text/html" <content>
            [ form view-form ] >>body
        ] >>display ;

: <id-redirect> ( id next -- response )
    swap number>string "id" associate <permanent-redirect> ;

:: <create-action> ( form ctor next -- action )
    <action>
        [ f ctor call from-tuple form set-defaults ] >>init

        [
            "text/html" <content>
            [ form edit-form ] >>body
        ] >>display

        [
            f ctor call from-tuple

            form validate-form

            values-tuple insert-tuple

            "id" value next <id-redirect>
        ] >>submit ;

:: <edit-action> ( form ctor next -- action )
    <action>
        { { "id" [ v-number ] } } >>get-params
        [ "id" get ctor call select-tuple from-tuple ] >>init

        [
            "text/html" <content>
            [ form edit-form ] >>body
        ] >>display

        [
            f ctor call from-tuple

            form validate-form

            values-tuple update-tuple

            "id" value next <id-redirect>
        ] >>submit ;

:: <delete-action> ( ctor next -- action )
    <action>
        { { "id" [ v-number ] } } >>post-params

        [
            "id" get ctor call delete-tuple

            next f <permanent-redirect>
        ] >>submit ;
