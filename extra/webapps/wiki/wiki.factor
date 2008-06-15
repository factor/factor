! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel hashtables calendar
namespaces splitting sequences sorting math.order present
syndication
html.components html.forms
http.server
http.server.dispatchers
furnace
furnace.actions
furnace.auth
furnace.auth.login
furnace.boilerplate
furnace.syndication
validators
db.types db.tuples lcs farkup urls ;
IN: webapps.wiki

: wiki-url ( rest path -- url )
    [ "$wiki/" % % "/" % % ] "" make
    <url> swap >>path ;

: view-url ( title -- url ) "view" wiki-url ;

: edit-url ( title -- url ) "edit" wiki-url ;

: revisions-url ( title -- url ) "revisions" wiki-url ;

: revision-url ( id -- url ) "revision" wiki-url ;

: user-edits-url ( author -- url ) "user-edits" wiki-url ;

TUPLE: wiki < dispatcher ;

SYMBOL: can-delete-wiki-articles?

can-delete-wiki-articles? define-capability

TUPLE: article title revision ;

article "ARTICLES" {
    { "title" "TITLE" { VARCHAR 256 } +not-null+ +user-assigned-id+ }
    { "revision" "REVISION" INTEGER +not-null+ } ! revision id
} define-persistent

: <article> ( title -- article ) article new swap >>title ;

TUPLE: revision id title author date content ;

revision "REVISIONS" {
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "title" "TITLE" { VARCHAR 256 } +not-null+ } ! article id
    { "author" "AUTHOR" { VARCHAR 256 } +not-null+ } ! uid
    { "date" "DATE" TIMESTAMP +not-null+ }
    { "content" "CONTENT" TEXT +not-null+ }
} define-persistent

M: revision feed-entry-title
    [ title>> ] [ drop " by " ] [ author>> ] tri 3append ;

M: revision feed-entry-date date>> ;

M: revision feed-entry-url id>> revision-url ;

: reverse-chronological-order ( seq -- sorted )
    [ [ date>> ] compare invert-comparison ] sort ;

: <revision> ( id -- revision )
    revision new swap >>id ;

: validate-title ( -- )
    { { "title" [ v-one-line ] } } validate-params ;

: validate-author ( -- )
    { { "author" [ v-username ] } } validate-params ;

: <main-article-action> ( -- action )
    <action>
        [ "Front Page" view-url <redirect> ] >>display ;

: <view-article-action> ( -- action )
    <action>

        "title" >>rest

        [
            validate-title
        ] >>init

        [
            "title" value dup <article> select-tuple [
                revision>> <revision> select-tuple from-object
                { wiki "view" } <chloe-content>
            ] [
                edit-url <redirect>
            ] ?if
        ] >>display ;

: <view-revision-action> ( -- action )
    <page-action>

        "id" >>rest

        [
            validate-integer-id
            "id" value <revision>
            select-tuple from-object
            URL" $wiki/view/" adjust-url present relative-link-prefix set
        ] >>init

        { wiki "view" } >>template ;

: amend-article ( revision article -- )
    swap id>> >>revision update-tuple ;

: add-article ( revision -- )
    [ title>> ] [ id>> ] bi article boa insert-tuple ;

: add-revision ( revision -- )
    [ insert-tuple ]
    [
        dup title>> <article> select-tuple
        [ amend-article ] [ add-article ] if*
    ] bi ;

: <edit-article-action> ( -- action )
    <page-action>

        "title" >>rest

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
            [ add-revision ] [ title>> view-url <redirect> ] bi
        ] >>submit

    <protected>
        "edit wiki articles" >>description ;

: list-revisions ( -- seq )
    f <revision> "title" value >>title select-tuples
    reverse-chronological-order ;

: <list-revisions-action> ( -- action )
    <page-action>

        "title" >>rest

        [
            validate-title
            list-revisions "revisions" set-value
        ] >>init

        { wiki "revisions" } >>template ;

: <list-revisions-feed-action> ( -- action )
    <feed-action>

        "title" >>rest

        [ validate-title ] >>init

        [ "Revisions of " "title" value append ] >>title

        [ "title" value revisions-url ] >>url

        [ list-revisions ] >>entries ;

: <rollback-action> ( -- action )
    <action>

        [ validate-integer-id ] >>validate

        [
            "id" value <revision> select-tuple clone f >>id
            [ add-revision ] [ title>> view-url <redirect> ] bi
        ] >>submit ;

: list-changes ( -- seq )
    f <revision> select-tuples
    reverse-chronological-order ;

: <list-changes-action> ( -- action )
    <page-action>
        [ list-changes "changes" set-value ] >>init
        { wiki "changes" } >>template ;

: <list-changes-feed-action> ( -- action )
    <feed-action>
        [ URL" $wiki/changes" ] >>url
        [ "All changes" ] >>title
        [ list-changes ] >>entries ;

: <delete-action> ( -- action )
    <action>

        [ validate-title ] >>validate

        [
            "title" value <article> delete-tuples
            f <revision> "title" value >>title delete-tuples
            URL" $wiki" <redirect>
        ] >>submit

     <protected>
        "delete wiki articles" >>description
        { can-delete-wiki-articles? } >>capabilities ;

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

: list-user-edits ( -- seq )
    f <revision> "author" value >>author select-tuples
    reverse-chronological-order ;

: <user-edits-action> ( -- action )
    <page-action>

        "author" >>rest

        [
            validate-author
            list-user-edits "user-edits" set-value
        ] >>init

        { wiki "user-edits" } >>template ;

: <user-edits-feed-action> ( -- action )
    <feed-action>
        "author" >>rest
        [ validate-author ] >>init
        [ "Edits by " "author" value append ] >>title
        [ "author" value user-edits-url ] >>url
        [ list-user-edits ] >>entries ;

: <article-boilerplate> ( responder -- responder' )
    <boilerplate>
        { wiki "page-common" } >>template ;

: <wiki> ( -- dispatcher )
    wiki new-dispatcher
        <main-article-action> <article-boilerplate> "" add-responder
        <view-article-action> <article-boilerplate> "view" add-responder
        <view-revision-action> <article-boilerplate> "revision" add-responder
        <list-revisions-action> <article-boilerplate> "revisions" add-responder
        <list-revisions-feed-action> "revisions.atom" add-responder
        <diff-action> <article-boilerplate> "diff" add-responder
        <edit-article-action> <article-boilerplate> "edit" add-responder
        <rollback-action> "rollback" add-responder
        <user-edits-action> "user-edits" add-responder
        <list-articles-action> "articles" add-responder
        <list-changes-action> "changes" add-responder
        <user-edits-feed-action> "user-edits.atom" add-responder
        <list-changes-feed-action> "changes.atom" add-responder
        <delete-action> "delete" add-responder
    <boilerplate>
        { wiki "wiki-common" } >>template ;
