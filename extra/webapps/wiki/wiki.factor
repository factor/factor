! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel hashtables calendar
namespaces splitting sequences sorting math.order
html.components
http.server
http.server.dispatchers
furnace
furnace.actions
furnace.auth
furnace.auth.login
furnace.boilerplate
validators
db.types db.tuples lcs farkup urls ;
IN: webapps.wiki

TUPLE: wiki < dispatcher ;

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

: validate-title ( -- )
    { { "title" [ v-one-line ] } } validate-params ;

: <main-article-action> ( -- action )
    <action>
        [
            <url>
                "$wiki/view" >>path
                "Front Page" "title" set-query-param
            <redirect>
        ] >>display ;

: <view-article-action> ( -- action )
    <action>
        "title" >>rest-param

        [
            validate-title
            "view?title=" relative-link-prefix set
        ] >>init

        [
            "title" value dup <article> select-tuple [
                revision>> <revision> select-tuple from-object
                { wiki "view" } <chloe-content>
            ] [
                <url>
                    "$wiki/edit" >>path
                    swap "title" set-query-param
                <redirect>
            ] ?if
        ] >>display ;

: <view-revision-action> ( -- action )
    <page-action>
        [
            { { "id" [ v-integer ] } } validate-params
            "id" value <revision>
            select-tuple from-object
        ] >>init

        { wiki "view" } >>template ;

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
                revision>> <revision> select-tuple from-object
            ] when*
        ] >>init

        { wiki "edit" } >>template
        
        [
            validate-title
            { { "content" [ v-required ] } } validate-params

            f <revision>
                "title" value >>title
                now >>date
                logged-in-user get username>> >>author
                "content" value >>content
            [ add-revision ]
            [
                <url>
                    "$wiki/view" >>path
                    swap title>> "title" set-query-param
                <redirect>
            ] bi
        ] >>submit ;

: <list-revisions-action> ( -- action )
    <page-action>
        [
            validate-title
            f <revision> "title" value >>title select-tuples
            [ [ date>> ] compare invert-comparison ] sort
            "revisions" set-value
        ] >>init

        { wiki "revisions" } >>template ;

: <rollback-action> ( -- action )
    <action>
        [
            { { "id" [ v-integer ] } } validate-params
        ] >>validate
        
        [
            "id" value <revision> select-tuple clone f >>id
            [ add-revision ]
            [
                <url>
                    "$wiki/view" >>path
                    swap title>> "title" set-query-param
                <redirect>
            ] bi
        ] >>submit ;

: <list-changes-action> ( -- action )
    <page-action>
        [
            f <revision> select-tuples
            [ [ date>> ] compare invert-comparison ] sort
            "changes" set-value
        ] >>init

        { wiki "changes" } >>template ;

: <delete-action> ( -- action )
    <action>
        [ validate-title ] >>validate

        [
            "title" value <article> delete-tuples
            f <revision> "title" value >>title delete-tuples
            URL" $wiki" <redirect>
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
            [
                [ [ title>> "title" set-value ] [ "old" set-value ] bi ]
                [ "new" set-value ] bi*
            ]
            [ [ content>> string-lines ] bi@ diff "diff" set-value ]
            2bi
        ] >>init

        { wiki "diff" } >>template ;

: <list-articles-action> ( -- action )
    <page-action>
        [
            f <article> select-tuples
            [ [ title>> ] compare ] sort
            "articles" set-value
        ] >>init

        { wiki "articles" } >>template ;

: <user-edits-action> ( -- action )
    <page-action>
        [
            { { "author" [ v-username ] } } validate-params
            f <revision> "author" value >>author
            select-tuples "user-edits" set-value
        ] >>init

        { wiki "user-edits" } >>template ;

: <wiki> ( -- dispatcher )
    wiki new-dispatcher
        <main-article-action> "" add-responder
        <view-article-action> "view" add-responder
        <view-revision-action> "revision" add-responder
        <list-revisions-action> "revisions" add-responder
        <rollback-action> "rollback" add-responder
        <user-edits-action> "user-edits" add-responder
        <diff-action> "diff" add-responder
        <list-articles-action> "articles" add-responder
        <list-changes-action> "changes" add-responder
        <edit-article-action> { } <protected> "edit" add-responder
        <delete-action> { } <protected> "delete" add-responder
    <boilerplate>
        { wiki "wiki-common" } >>template ;
