! Copyright (C) 2007, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs sorting sequences kernel accessors
hashtables sequences.lib db.types db.tuples db combinators
calendar calendar.format math.parser rss urls xml.writer
xmode.catalog validators
html.components
html.templates.chloe
http.server
http.server.dispatchers
http.server.redirection
furnace
furnace.actions
furnace.auth
furnace.auth.login
furnace.boilerplate
furnace.rss ;
IN: webapps.pastebin

TUPLE: pastebin < dispatcher ;

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

TUPLE: paste < entity annotations ;

\ paste "PASTES" { } define-persistent

: <paste> ( id -- paste )
    \ paste new
        swap >>id ;

: pastes ( -- pastes )
    f <paste> select-tuples ;

TUPLE: annotation < entity parent ;

annotation "ANNOTATIONS"
{
    { "parent" "PARENT" INTEGER +not-null+ }
} define-persistent

: <annotation> ( parent id -- annotation )
    annotation new
        swap >>id
        swap >>parent ;

: paste ( id -- paste )
    [ <paste> select-tuple ]
    [ f <annotation> select-tuples ]
    bi >>annotations ;

! ! !
! LINKS, ETC
! ! !

: pastebin-url ( -- url )
    URL" $pastebin/list" ;

: paste-url ( id -- url )
    "$pastebin/paste" >url swap "id" set-query-param ;

M: paste entity-url
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
        [ pastes <reversed> ] >>entries ;

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
            ] nest-values
        ] >>init

        { pastebin "paste" } >>template ;

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
        { "captcha" [ v-captcha ] }
    } validate-params ;

: deposit-entity-slots ( tuple -- )
    now >>date
    { "summary" "author" "mode" "contents" } deposit-slots ;

: <new-paste-action> ( -- action )
    <page-action>
        [
            "factor" "mode" set-value
            mode-names "modes" set-value
        ] >>init

        { pastebin "new-paste" } >>template

        [ mode-names "modes" set-value ] >>validate

        [
            validate-entity

            f <paste>
            [ deposit-entity-slots ]
            [ insert-tuple ]
            [ id>> paste-url <redirect> ]
            tri
        ] >>submit ;

: <delete-paste-action> ( -- action )
    <action>
        [ validate-integer-id ] >>validate

        [
            "id" value <paste> delete-tuples
            "id" value f <annotation> delete-tuples
            URL" $pastebin/list" <redirect>
        ] >>submit ;

! ! !
! ANNOTATIONS
! ! !

: <new-annotation-action> ( -- action )
    <action>
        [
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

: <delete-annotation-action> ( -- action )
    <action>
        [ { { "id" [ v-number ] } } validate-params ] >>validate

        [
            f "id" value <annotation> select-tuple
            [ delete-tuples ]
            [ parent>> paste-url <redirect> ]
            bi
        ] >>submit ;

SYMBOL: can-delete-pastes?

can-delete-pastes? define-capability

: <pastebin> ( -- responder )
    pastebin new-dispatcher
        <pastebin-action> "list" add-main-responder
        <pastebin-feed-action> "list.atom" add-responder
        <paste-action> "paste" add-responder
        <paste-feed-action> "paste.atom" add-responder
        <new-paste-action> "new-paste" add-responder
        <delete-paste-action> <protected>
            "delete pastes" >>description
            { can-delete-pastes? } >>capabilities "delete-paste" add-responder
        <new-annotation-action> "new-annotation" add-responder
        <delete-annotation-action> <protected>
            "delete annotations" >>description
            { can-delete-pastes? } >>capabilities "delete-annotation" add-responder
    <boilerplate>
        { pastebin "pastebin-common" } >>template ;

: init-pastes-table \ paste ensure-table ;

: init-annotations-table annotation ensure-table ;
