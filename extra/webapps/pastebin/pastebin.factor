! Copyright (C) 2007, 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar db db.tuples db.types furnace.actions
furnace.auth furnace.boilerplate furnace.recaptcha
furnace.redirection furnace.syndication furnace.utilities
html.forms http.server.dispatchers http.server.responses kernel
math.parser namespaces present sequences smtp sorting splitting
urls validators xmode.catalog ;
IN: webapps.pastebin

TUPLE: pastebin < dispatcher ;

SYMBOL: can-delete-pastes?

SYMBOL: pastebin-email-from
SYMBOL: pastebin-email-to

can-delete-pastes? define-capability

! ! !
! DOMAIN MODEL
! ! !

TUPLE: entity id summary author mode date contents ;

entity f
{
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "summary" "SUMMARY" { VARCHAR 256 } +not-null+ }
    { "author" "AUTHOR" { VARCHAR 256 } +not-null+ }
    { "mode" "MODE" { VARCHAR 256 } +not-null+ }
    { "date" "DATE" DATETIME +not-null+ }
    { "contents" "CONTENTS" TEXT +not-null+ }
} define-persistent

GENERIC: entity-url ( entity -- url )

M: entity feed-entry-title summary>> ;

M: entity feed-entry-date date>> ;

M: entity feed-entry-url entity-url ;

TUPLE: paste-state < entity annotations ;

\ paste-state "PASTES" { } define-persistent

: <paste-state> ( id -- paste )
    \ paste-state new
        swap >>id ;

: pastes ( -- pastes )
    f <paste-state> select-tuples
    [ date>> ] sort-by
    reverse ;

TUPLE: annotation < entity parent ;

\ annotation "ANNOTATIONS"
{
    { "parent" "PARENT" INTEGER +not-null+ }
} define-persistent

: <annotation> ( parent id -- annotation )
    \ annotation new
        swap >>id
        swap >>parent ;

: lookup-annotation ( id -- annotation )
    [ f ] dip <annotation> select-tuple ;

: paste ( id -- paste/f )
    [ <paste-state> select-tuple ] keep over [
        f <annotation> select-tuples >>annotations
    ] [ drop ] if ;

! ! !
! LINKS, ETC
! ! !

CONSTANT: pastebin-url URL" $pastebin/"

: paste-url ( id -- url )
    "$pastebin/paste" >url swap "id" set-query-param ;

M: paste-state entity-url
    id>> paste-url ;

: annotation-url ( parent id -- url )
    "$pastebin/paste" >url
        swap number>string >>anchor
        swap "id" set-query-param ;

M: annotation entity-url
    [ parent>> ] [ id>> ] bi annotation-url ;

! ! !
! PASTE LIST
! ! !

: <pastebin-action> ( -- action )
    <page-action>
        [ pastes "pastes" set-value ] >>init
        { pastebin "pastebin" } >>template ;

: <pastebin-feed-action> ( -- action )
    <feed-action>
        [ pastebin-url ] >>url
        [ "Factor Pastebin" ] >>title
        [ pastes ] >>entries ;

! ! !
! PASTES
! ! !

: <paste-action> ( -- action )
    <page-action>
        [
            validate-integer-id
            "id" value paste from-object

            "id" value
            "new-annotation" [
                "parent" set-value
                mode-names "modes" set-value
                "factor" "mode" set-value
            ] nest-form
        ] >>init

        { pastebin "paste" } >>template ;

: <raw-paste-action> ( -- action )
    <action>
        [ validate-integer-id "id" value paste from-object ] >>init
        [ "contents" value <text-content> ] >>display ;

: <paste-feed-action> ( -- action )
    <feed-action>
        [ validate-integer-id ] >>init
        [ "id" value paste-url ] >>url
        [ "Paste " "id" value number>string append ] >>title
        [ "id" value f <annotation> select-tuples ] >>entries ;

: validate-entity ( -- )
    {
        { "summary" [ v-one-line ] }
        { "author" [ v-one-line ] }
        { "mode" [ v-mode ] }
        { "contents" [ v-required ] }
    } validate-params
    validate-recaptcha ;

: deposit-entity-slots ( tuple -- )
    now >>date
    { "summary" "author" "mode" "contents" } to-object ;

: email-on-paste ( url -- )
    pastebin-email-to get-global [
        drop
    ] [
        <email>
            swap >>to
            swap adjust-url present >>body
        pastebin-email-from get-global >>from
        "New paste!" >>subject
        send-email
    ] if-empty ;

: <new-paste-action> ( -- action )
    <page-action>
        [
            "factor" "mode" set-value
            mode-names "modes" set-value
        ] >>init

        { pastebin "new-paste" } >>template

        [
            mode-names "modes" set-value
            validate-entity
        ] >>validate

        [
            f <paste-state>
            [ deposit-entity-slots ]
            [ insert-tuple ]
            [ id>> paste-url [ email-on-paste ] [ <redirect> ] bi ]
            tri
        ] >>submit ;

: <delete-paste-action> ( -- action )
    <action>

        [ validate-integer-id ] >>validate

        [
            [
                "id" value <paste-state> delete-tuples
                "id" value f <annotation> delete-tuples
            ] with-transaction
            pastebin-url <redirect>
        ] >>submit

        <protected>
            "delete pastes" >>description
            { can-delete-pastes? } >>capabilities ;

! ! !
! ANNOTATIONS
! ! !

: <new-annotation-action> ( -- action )
    <action>
        [
            mode-names "modes" set-value
            { { "parent" [ v-integer ] } } validate-params
            validate-entity
        ] >>validate

        [
            "parent" value f <annotation>
            [ deposit-entity-slots ]
            [ insert-tuple ]
            [ entity-url <redirect> ]
            tri
        ] >>submit ;

: <raw-annotation-action> ( -- action )
    <action>
        [ validate-integer-id "id" value lookup-annotation from-object ] >>init
        [ "contents" value <text-content> ] >>display ;

: <delete-annotation-action> ( -- action )
    <action>

        [ { { "id" [ v-number ] } } validate-params ] >>validate

        [
            "id" value lookup-annotation
            [ delete-tuples ]
            [ parent>> paste-url <redirect> ]
            bi
        ] >>submit

    <protected>
        "delete annotations" >>description
        { can-delete-pastes? } >>capabilities ;

: <pastebin> ( -- responder )
    pastebin new-dispatcher
        <pastebin-action> "" add-responder
        <pastebin-feed-action> "list.atom" add-responder
        <paste-action> "paste" add-responder
        <raw-paste-action> "paste.txt" add-responder
        <paste-feed-action> "paste.atom" add-responder
        <new-paste-action> "new-paste" add-responder
        <delete-paste-action> "delete-paste" add-responder
        <new-annotation-action> "new-annotation" add-responder
        <raw-annotation-action> "annotation.txt" add-responder
        <delete-annotation-action> "delete-annotation" add-responder
    <boilerplate>
        { pastebin "pastebin-common" } >>template ;
