! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel hashtables calendar
namespaces splitting sequences sorting math.order
html.components
html.templates.chloe
http.server
http.server.actions
http.server.auth
http.server.auth.login
http.server.boilerplate
validators
db.types db.tuples lcs farkup ;
IN: webapps.wiki

TUPLE: article title revision ;

article "ARTICLES" {
    { "title" "TITLE" { VARCHAR 256 } +not-null+ +user-assigned-id+ }
    ! { "AUTHOR" INTEGER +not-null+ } ! uid
    ! { "PROTECTED" BOOLEAN +not-null+ }
    { "revision" "REVISION" INTEGER +not-null+ } ! revision id
} define-persistent

: <article> ( title -- article ) article new swap >>title ;

: init-articles-table article ensure-table ;

TUPLE: revision id title author date content ;

revision "REVISIONS" {
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "title" "TITLE" { VARCHAR 256 } +not-null+ } ! article id
    { "author" "AUTHOR" { VARCHAR 256 } +not-null+ } ! uid
    { "date" "DATE" TIMESTAMP +not-null+ }
    { "content" "CONTENT" TEXT +not-null+ }
} define-persistent

: <revision> ( id -- revision )
    revision new swap >>id ;

: init-revisions-table revision ensure-table ;

: wiki-template ( name -- template )
    "resource:extra/webapps/wiki/" swap ".xml" 3append <chloe> ;

: <title-redirect> ( title next -- response )
    swap "title" associate <standard-redirect> ;

: validate-title ( -- )
    { { "title" [ v-one-line ] } } validate-params ;

: <main-article-action> ( -- action )
    <action>
        [ "Front Page" "$wiki/view" <title-redirect> ] >>display ;

: <view-article-action> ( -- action )
    <action>
        "title" >>rest-param

        [
            validate-title
            "view?title=" relative-link-prefix set
        ] >>init

        [
            "title" value dup <article> select-tuple [
                revision>> <revision> select-tuple from-tuple
                "view" wiki-template <html-content>
            ] [
                "$wiki/edit" <title-redirect>
            ] ?if
        ] >>display ;

: <view-revision-action> ( -- action )
    <page-action>
        [
            { { "id" [ v-integer ] } } validate-params
            "id" value <revision>
            select-tuple from-tuple
        ] >>init

        "view" wiki-template >>template ;

: add-revision ( revision -- )
    [ insert-tuple ]
    [
        dup title>> <article> select-tuple [
            swap id>> >>revision update-tuple
        ] [
            [ title>> ] [ id>> ] bi article boa insert-tuple
        ] if*
    ] bi ;

: <edit-article-action> ( -- action )
    <page-action>
        [
            validate-title
            "title" value <article> select-tuple [
                revision>> <revision> select-tuple from-tuple
            ] when*
        ] >>init

        "edit" wiki-template >>template
        
        [
            validate-title
            { { "content" [ v-required ] } } validate-params

            f <revision>
                "title" value >>title
                now >>date
                logged-in-user get username>> >>author
                "content" value >>content
            [ add-revision ]
            [ title>> "$wiki/view" <title-redirect> ] bi
        ] >>submit ;

: <list-revisions-action> ( -- action )
    <page-action>
        [
            validate-title
            f <revision> "title" value >>title select-tuples
            [ [ date>> ] compare invert-comparison ] sort
            "revisions" set-value
        ] >>init

        "revisions" wiki-template >>template ;

: <delete-action> ( -- action )
    <action>
        [ validate-title ] >>validate

        [
            "title" value <article> delete-tuples
            f <revision> "title" value >>title delete-tuples
            "" f <standard-redirect>
        ] >>submit ;

: <diff-action> ( -- action )
    <page-action>
        [
            {
                { "old-id" [ v-integer ] }
                { "new-id" [ v-integer ] }
            } validate-params

            "old-id" "new-id"
            [ value <revision> select-tuple ] bi@
            [ [ "old" set-value ] [ "new" set-value ] bi* ]
            [ [ content>> string-lines ] bi@ diff "diff" set-value ]
            2bi
        ] >>init

        "diff" wiki-template >>template ;

: <list-articles-action> ( -- action )
    <page-action>
        [ f <article> select-tuples "articles" set-value ] >>init
        "articles" wiki-template >>template ;

TUPLE: wiki < dispatcher ;

: <wiki> ( -- dispatcher )
    wiki new-dispatcher
        <main-article-action> "" add-responder
        <view-article-action> "view" add-responder
        <view-revision-action> "revision" add-responder
        <edit-article-action> { } <protected> "edit" add-responder
        <list-revisions-action> "revisions" add-responder
        <delete-action> "delete" add-responder
        <diff-action> "diff" add-responder
        <list-articles-action> "articles" add-responder
    <boilerplate>
        "wiki-common" wiki-template >>template ;
