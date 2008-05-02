USING: namespaces assocs sorting sequences kernel accessors
hashtables sequences.lib locals db.types db.tuples db
calendar calendar.format rss xml.writer
xmode.catalog
http.server
http.server.crud
http.server.actions
http.server.components
http.server.components.code
http.server.templating.chloe
http.server.auth
http.server.auth.login
http.server.boilerplate
http.server.validators
http.server.forms ;
IN: webapps.pastebin

: <mode> ( id -- component )
    modes keys natural-sort <choice> ;

: pastebin-template ( name -- template )
    "resource:extra/webapps/pastebin/" swap ".xml" 3append <chloe> ;

TUPLE: paste id summary author mode date contents annotations captcha ;

paste "PASTE"
{
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "summary" "SUMMARY" { VARCHAR 256 } +not-null+ }
    { "author" "AUTHOR" { VARCHAR 256 } +not-null+ }
    { "mode" "MODE" { VARCHAR 256 } +not-null+ }
    { "date" "DATE" DATETIME +not-null+ }
    { "contents" "CONTENTS" TEXT +not-null+ }
} define-persistent

: <paste> ( id -- paste )
    paste new
        swap >>id ;

: pastes ( -- pastes )
    f <paste> select-tuples ;

TUPLE: annotation aid id summary author mode contents date captcha ;

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

: <annotation-form> ( -- form )
    "paste" <form>
        "id" <integer>
            hidden >>renderer
            add-field
        "aid" <integer>
            hidden >>renderer
            add-field
        "annotation" pastebin-template >>view-template
        "summary" <string> add-field
        "author" <string> add-field
        "mode" <mode> add-field
        "contents" "mode" <code> add-field
        "date" <date> add-field ;

: <new-annotation-form> ( -- form )
    "paste" <form>
        "new-annotation" pastebin-template >>edit-template
        "id" <integer>
            hidden >>renderer
            t >>required add-field
        "summary" <string>
            t >>required add-field
        "author" <string>
            t >>required
            add-field
        "mode" <mode>
            "factor" >>default
            t >>required
            add-field
        "contents" "mode" <code>
            t >>required add-field
        "captcha" <captcha> add-field ;

: <paste-form> ( -- form )
    "paste" <form>
        "paste" pastebin-template >>view-template
        "paste-summary" pastebin-template >>summary-template
        "id" <integer>
            hidden >>renderer add-field
        "summary" <string> add-field
        "author" <string> add-field
        "mode" <mode> add-field
        "date" <date> add-field
        "contents" "mode" <code> add-field
        "annotations" <annotation-form> +plain+ <list> add-field ;

: <new-paste-form> ( -- form )
    "paste" <form>
        "new-paste" pastebin-template >>edit-template
        "summary" <string>
            t >>required add-field
        "author" <string>
            t >>required add-field
        "mode" <mode>
            "factor" >>default
            t >>required
            add-field
        "contents" "mode" <code>
            t >>required add-field
        "captcha" <captcha> add-field ;

: <paste-list-form> ( -- form )
    "pastebin" <form>
        "paste-list" pastebin-template >>view-template
        "pastes" <paste-form> +plain+ <list> add-field ;

:: <paste-list-action> ( -- action )
    [let | form [ <paste-list-form> ] |
        <action>
            [
                blank-values

                pastes "pastes" set-value

                form view-form
            ] >>display
    ] ;

:: <annotate-action> ( form ctor next -- action )
    <action>
        { { "id" [ v-number ] } } >>get-params

        [
            "id" get f ctor call

            from-tuple form set-defaults
        ] >>init

        [ form edit-form ] >>display

        [
            f f ctor call from-tuple

            form validate-form

            values-tuple insert-tuple

            "id" value next <id-redirect>
        ] >>submit ;

: pastebin-feed-entries ( -- entries )
    pastes <reversed> 20 short head [
        [ summary>> ]
        [ "$pastebin/view-paste" swap id>> "id" associate link>string ]
        [ date>> ] tri
        f swap <entry>
    ] map ;

: pastebin-feed ( -- feed )
    feed new
        "Factor Pastebin" >>title
        "http://paste.factorcode.org" >>link
        pastebin-feed-entries >>entries ;

: <feed-action> ( -- action )
    <action>
        [
            "text/xml" <content>
            [ pastebin-feed feed>xml write-xml ] >>body
        ] >>display ;

:: <view-paste-action> ( form ctor -- action )
    <action>
        { { "id" [ v-number ] } } >>get-params

        [ "id" get ctor call select-tuple fetch-annotations from-tuple ] >>init

        [ form view-form ] >>display ;

:: <delete-paste-action> ( ctor next -- action )
    <action>
        { { "id" [ v-number ] } } >>post-params

        [
            "id" get ctor call delete-tuples

            "id" get f <annotation> delete-tuples

            next f <permanent-redirect>
        ] >>submit ;

:: <delete-annotation-action> ( ctor next -- action )
    <action>
        { { "id" [ v-number ] } { "aid" [ v-number ] } } >>post-params

        [
            "id" get "aid" get ctor call delete-tuples

            "id" get next <id-redirect>
        ] >>submit ;

:: <new-paste-action> ( form ctor next -- action )
    <action>
        [
            f ctor call from-tuple

            form set-defaults
        ] >>init

        [ form edit-form ] >>display

        [
            f ctor call from-tuple

            form validate-form

            values-tuple insert-tuple

            "id" value next <id-redirect>
        ] >>submit ;

TUPLE: pastebin < dispatcher ;

SYMBOL: can-delete-pastes?

can-delete-pastes? define-capability

: <pastebin> ( -- responder )
    pastebin new-dispatcher
        <paste-list-action> "list" add-main-responder
        <feed-action> "feed.xml" add-responder
        <paste-form> [ <paste> ] <view-paste-action> "view-paste" add-responder
        [ <paste> ] "$pastebin/list" <delete-paste-action> { can-delete-pastes? } <protected> "delete-paste" add-responder
        [ <annotation> ] "$pastebin/view-paste" { can-delete-pastes? } <delete-annotation-action> <protected> "delete-annotation" add-responder
        <paste-form> [ <paste> ]    <view-paste-action>     "$pastebin/view-paste"   add-responder
        <new-paste-form> [ <paste> now >>date ] "$pastebin/view-paste" <new-paste-action>     "new-paste"    add-responder
        <new-annotation-form> [ <annotation> now >>date ] "$pastebin/view-paste" <annotate-action> "annotate" add-responder
    <boilerplate>
        "pastebin" pastebin-template >>template ;

: init-pastes-table paste ensure-table ;

: init-annotations-table annotation ensure-table ;
