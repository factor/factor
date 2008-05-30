! Copyright (C) 2007, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs sorting sequences kernel accessors
hashtables sequences.lib db.types db.tuples db combinators
calendar calendar.format math.parser rss xml.writer
xmode.catalog validators html.components html.templates.chloe
http.server
http.server.actions
http.server.auth
http.server.auth.login
http.server.boilerplate ;
IN: webapps.pastebin

! ! !
! DOMAIN MODEL
! ! !

TUPLE: paste id summary author mode date contents annotations ;

\ paste "PASTE"
{
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "summary" "SUMMARY" { VARCHAR 256 } +not-null+ }
    { "author" "AUTHOR" { VARCHAR 256 } +not-null+ }
    { "mode" "MODE" { VARCHAR 256 } +not-null+ }
    { "date" "DATE" DATETIME +not-null+ , }
    { "contents" "CONTENTS" TEXT +not-null+ }
} define-persistent

: <paste> ( id -- paste )
    \ paste new
        swap >>id ;

: pastes ( -- pastes )
    f <paste> select-tuples ;

TUPLE: annotation aid id summary author mode contents date ;

annotation "ANNOTATION"
{
    { "aid" "AID" INTEGER +db-assigned-id+ }
    { "id" "ID" INTEGER +not-null+ }
    { "summary" "SUMMARY" { VARCHAR 256 } +not-null+ }
    { "author" "AUTHOR" { VARCHAR 256 } +not-null+ }
    { "mode" "MODE" { VARCHAR 256 } +not-null+ }
    { "date" "DATE" DATETIME +not-null+ }
    { "contents" "CONTENTS" TEXT +not-null+ }
} define-persistent

: <annotation> ( id aid -- annotation )
    annotation new
        swap >>aid
        swap >>id ;

: fetch-annotations ( paste -- paste )
    dup annotations>> [
        dup id>> f <annotation> select-tuples >>annotations
    ] unless ;

: paste ( id -- paste )
    <paste> select-tuple fetch-annotations ;

: <id-redirect> ( id next -- response )
    swap "id" associate <standard-redirect> ;

! ! !
! LINKS, ETC
! ! !

: pastebin-link ( -- url )
    "$pastebin/list" f link>string ;

GENERIC: entity-link ( entity -- url )

M: paste entity-link
    id>> "id" associate "$pastebin/paste" swap link>string ;

M: annotation entity-link
    [ id>> "id" associate "$pastebin/paste" swap link>string ]
    [ aid>> number>string "#" prepend ] bi
    append ;

: pastebin-template ( name -- template )
    "resource:extra/webapps/pastebin/" swap ".xml" 3append <chloe> ;

! ! !
! PASTE LIST
! ! !

: <pastebin-action> ( -- action )
    <page-action>
        [ pastes "pastes" set-value ] >>init
        "pastebin" pastebin-template >>template ;

: pastebin-feed-entries ( seq -- entries )
    <reversed> 20 short head [
        entry new
            swap
            [ summary>> >>title ]
            [ date>> >>pub-date ]
            [ entity-link >>link ]
            tri
    ] map ;

: pastebin-feed ( -- feed )
    feed new
        "Factor Pastebin" >>title
        pastebin-link >>link
        pastes pastebin-feed-entries >>entries ;

: <pastebin-feed-action> ( -- action )
    <feed-action> [ pastebin-feed ] >>feed ;

! ! !
! PASTES
! ! !

: <paste-action> ( -- action )
    <page-action>
        [
            validate-integer-id
            "id" value paste from-tuple

            "id" value
            "new-annotation" [
                "id" set-value
                mode-names "modes" set-value
                "factor" "mode" set-value
            ] nest-values
        ] >>init

        "paste" pastebin-template >>template ;

: paste-feed-entries ( paste -- entries )
    fetch-annotations annotations>> pastebin-feed-entries ;

: paste-feed ( paste -- feed )
    feed new
        swap
        [ "Paste #" swap id>> number>string append >>title ]
        [ entity-link >>link ]
        [ paste-feed-entries >>entries ]
        tri ;

: <paste-feed-action> ( -- action )
    <feed-action>
        [ validate-integer-id ] >>init
        [ "id" value paste annotations>> paste-feed ] >>feed ;

: validate-paste ( -- )
    {
        { "summary" [ v-one-line ] }
        { "author" [ v-one-line ] }
        { "mode" [ v-mode ] }
        { "contents" [ v-required ] }
        { "captcha" [ v-captcha ] }
    } validate-params ;

: deposit-paste-slots ( tuple -- )
    now >>date
    { "summary" "author" "mode" "contents" } deposit-slots ;

: <new-paste-action> ( -- action )
    <page-action>
        [
            "factor" "mode" set-value
            mode-names "modes" set-value
        ] >>init

        "new-paste" pastebin-template >>template

        [
            validate-paste

            f <paste>
            [ deposit-paste-slots ]
            [ insert-tuple ]
            [ id>> "$pastebin/paste" <id-redirect> ]
            tri
        ] >>submit ;

: <delete-paste-action> ( -- action )
    <action>
        [ validate-integer-id ] >>validate

        [
            "id" value <paste> delete-tuples
            "id" value f <annotation> delete-tuples
            "$pastebin/list" f <permanent-redirect>
        ] >>submit ;

! ! !
! ANNOTATIONS
! ! !

: <new-annotation-action> ( -- action )
    <page-action>
        [ validate-paste ] >>validate

        [ "id" param "$pastebin/paste" <id-redirect> ] >>display

        [
            f f <annotation>
            {
                [ deposit-paste-slots ]
                [ { "id" } deposit-slots ]
                [ insert-tuple ]
                [
                    ! Add anchor here
                    id>> "$pastebin/paste" <id-redirect>
                ]
            } cleave
        ] >>submit ;

: <delete-annotation-action> ( -- action )
    <action>
        [ { { "aid" [ v-number ] } } validate-params ] >>validate

        [
            f "aid" value <annotation> select-tuple
            [ delete-tuples ]
            [ id>> "$pastebin/paste" <id-redirect> ]
            bi
        ] >>submit ;

TUPLE: pastebin < dispatcher ;

SYMBOL: can-delete-pastes?

can-delete-pastes? define-capability

: <pastebin> ( -- responder )
    pastebin new-dispatcher
        <pastebin-action> "list" add-main-responder
        <pastebin-feed-action> "list.atom" add-responder
        <paste-action> "paste" add-responder
        <paste-feed-action> "paste.atom" add-responder
        <new-paste-action> "new-paste" add-responder
        <delete-paste-action> { can-delete-pastes? } <protected> "delete-paste" add-responder
        <new-annotation-action> "new-annotation" add-responder
        <delete-annotation-action> { can-delete-pastes? } <protected> "delete-annotation" add-responder
    <boilerplate>
        "pastebin-common" pastebin-template >>template ;

: init-pastes-table \ paste ensure-table ;

: init-annotations-table annotation ensure-table ;
