! Copyright (C) 2008 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences sorting math.order math.parser
urls validators db db.types db.tuples calendar present namespaces
html.forms
html.components
http.server.dispatchers
furnace
furnace.actions
furnace.redirection
furnace.auth
furnace.auth.login
furnace.boilerplate
furnace.syndication ;
IN: webapps.blogs

TUPLE: blogs < dispatcher ;

SYMBOL: can-administer-blogs?

can-administer-blogs? define-capability

: view-post-url ( id -- url )
    present "$blogs/post/" prepend >url ;

: view-comment-url ( parent id -- url )
    [ view-post-url ] dip >>anchor ;

: list-posts-url ( -- url )
    "$blogs/" >url ;

: posts-by-url ( author -- url )
    "$blogs/by/" prepend >url ;

TUPLE: entity id author date content ;

GENERIC: entity-url ( entity -- url )

M: entity feed-entry-url entity-url ;

entity f {
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "author" "AUTHOR" { VARCHAR 256 } +not-null+ } ! uid
    { "date" "DATE" TIMESTAMP +not-null+ }
    { "content" "CONTENT" TEXT +not-null+ }
} define-persistent

M: entity feed-entry-date date>> ;

TUPLE: post-state < entity title comments ;

M: post-state feed-entry-title
    [ author>> ] [ title>> ] bi ": " glue ;

M: post-state entity-url
    id>> view-post-url ;

\ post-state "BLOG_POSTS" {
    { "title" "TITLE" { VARCHAR 256 } +not-null+ }
} define-persistent

: <post-state> ( id -- post ) \ post-state new swap >>id ;

TUPLE: comment < entity parent ;

comment "COMMENTS" {
    { "parent" "PARENT" INTEGER +not-null+ } ! post id
} define-persistent

M: comment feed-entry-title
    author>> "Comment by " prepend ;

M: comment entity-url
    [ parent>> ] [ id>> ] bi view-comment-url ;

: <comment> ( parent id -- post )
    comment new
        swap >>id
        swap >>parent ;

: post ( id -- post )
    [ <post-state> select-tuple ] [ f <comment> select-tuples ] bi
    >>comments ;

: reverse-chronological-order ( seq -- sorted )
    [ date>> ] inv-sort-by ;

: validate-author ( -- )
    { { "author" [ v-username ] } } validate-params ;

: list-posts ( -- posts )
    f <post-state> "author" value >>author
    select-tuples [ dup id>> f <comment> count-tuples >>comments ] map
    reverse-chronological-order ;

: <list-posts-action> ( -- action )
    <page-action>
        [ list-posts "posts" set-value ] >>init
        { blogs "list-posts" } >>template ;

: <list-posts-feed-action> ( -- action )
    <feed-action>
        [ "Recent Posts" ] >>title
        [ list-posts ] >>entries
        [ list-posts-url ] >>url ;

: <posts-by-action> ( -- action )
    <page-action>

        "author" >>rest

        [
            validate-author
            list-posts "posts" set-value
        ] >>init

        { blogs "posts-by" } >>template ;

: <posts-by-feed-action> ( -- action )
    <feed-action>
        "author" >>rest
        [ validate-author ] >>init
        [ "Recent Posts by " "author" value append ] >>title
        [ list-posts ] >>entries
        [ "author" value posts-by-url ] >>url ;

: <post-feed-action> ( -- action )
    <feed-action>
        "id" >>rest
        [ validate-integer-id "id" value post "post" set-value ] >>init
        [ "post" value feed-entry-title ] >>title
        [ "post" value entity-url ] >>url
        [ "post" value comments>> ] >>entries ;

: <view-post-action> ( -- action )
    <page-action>

        "id" >>rest

        [
            validate-integer-id
            "id" value post from-object

            "id" value
            "new-comment" [
                "parent" set-value
            ] nest-form
        ] >>init

        { blogs "view-post" } >>template ;

: validate-post ( -- )
    {
        { "title" [ v-one-line ] }
        { "content" [ v-required ] }
    } validate-params ;

: <new-post-action> ( -- action )
    <page-action>

        [
            validate-post
            username "author" set-value
        ] >>validate

        [
            f <post-state>
                dup { "title" "content" } to-object
                username >>author
                now >>date
            [ insert-tuple ] [ entity-url <redirect> ] bi
        ] >>submit

        { blogs "new-post" } >>template

    <protected>
        "make a new blog post" >>description ;

: authorize-author ( author -- )
    username =
    { can-administer-blogs? } have-capabilities? or
    [ "edit a blog post" f login-required ] unless ;

: do-post-action ( -- )
    validate-integer-id
    "id" value <post-state> select-tuple from-object ;

: <edit-post-action> ( -- action )
    <page-action>

        "id" >>rest

        [ do-post-action ] >>init

        [ do-post-action validate-post ] >>validate

        [ "author" value authorize-author ] >>authorize

        [
            "id" value <post-state>
            dup { "title" "author" "date" "content" } to-object
            [ update-tuple ] [ entity-url <redirect> ] bi
        ] >>submit

        { blogs "edit-post" } >>template

    <protected>
        "edit a blog post" >>description ;

: delete-post ( id -- )
    [ <post-state> delete-tuples ] [ f <comment> delete-tuples ] bi ;

: <delete-post-action> ( -- action )
    <action>

        [ do-post-action ] >>validate

        [ "author" value authorize-author ] >>authorize

        [
            [ "id" value delete-post ] with-transaction
            "author" value posts-by-url <redirect>
        ] >>submit

    <protected>
        "delete a blog post" >>description ;

: <delete-author-action> ( -- action )
    <action>

        [ validate-author ] >>validate

        [ "author" value authorize-author ] >>authorize

        [
            [
                f <post-state> "author" value >>author select-tuples [ id>> delete-post ] each
                f f <comment> "author" value >>author delete-tuples
            ] with-transaction
            "author" value posts-by-url <redirect>
        ] >>submit

    <protected>
        "delete a blog post" >>description ;

: validate-comment ( -- )
    {
        { "parent" [ v-integer ] }
        { "content" [ v-required ] }
    } validate-params ;

: <new-comment-action> ( -- action )
    <action>

        [
            validate-comment
            username "author" set-value
        ] >>validate

        [
            "parent" value f <comment>
                "content" value >>content
                username >>author
                now >>date
            [ insert-tuple ] [ entity-url <redirect> ] bi
        ] >>submit

    <protected>
        "make a comment" >>description ;

: <delete-comment-action> ( -- action )
    <action>

        [
            validate-integer-id
            { { "parent" [ v-integer ] } } validate-params
        ] >>validate

        [
            "parent" value <post-state> select-tuple
            author>> authorize-author
        ] >>authorize

        [
            f "id" value <comment> delete-tuples
            "parent" value view-post-url <redirect>
        ] >>submit

        <protected>
            "delete a comment" >>description ;

: <blogs> ( -- dispatcher )
    blogs new-dispatcher
        <list-posts-action> "" add-responder
        <list-posts-feed-action> "posts.atom" add-responder
        <posts-by-action> "by" add-responder
        <posts-by-feed-action> "by.atom" add-responder
        <view-post-action> "post" add-responder
        <post-feed-action> "post.atom" add-responder
        <new-post-action> "new-post" add-responder
        <edit-post-action> "edit-post" add-responder
        <delete-post-action> "delete-post" add-responder
        <new-comment-action> "new-comment" add-responder
        <delete-comment-action> "delete-comment" add-responder
    <boilerplate>
        { blogs "blogs-common" } >>template ;
