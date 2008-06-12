! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences sorting math.order math.parser
urls validators html.components db.types db.tuples calendar
http.server.dispatchers
furnace furnace.actions furnace.auth.login furnace.boilerplate
furnace.sessions furnace.syndication ;
IN: webapps.blogs

TUPLE: blogs < dispatcher ;

: view-post-url ( id -- url )
    number>string "$blogs/post/" prepend >url ;

: view-comment-url ( parent id -- url )
    [ view-post-url ] dip >>anchor ;

: list-posts-url ( -- url )
    URL" $blogs/" ;

: user-posts-url ( author -- url )
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

TUPLE: post < entity title comments ;

M: post feed-entry-title
    [ author>> ] [ drop ": " ] [ title>> ] tri 3append ;

M: post entity-url
    id>> view-post-url ;

\ post "BLOG_POSTS" {
    { "title" "TITLE" { VARCHAR 256 } +not-null+ }
} define-persistent

: <post> ( id -- post ) \ post new swap >>id ;

: init-posts-table ( -- ) \ post ensure-table ;

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

: init-comments-table ( -- ) comment ensure-table ;

: post ( id -- post )
    [ <post> select-tuple ] [ f <comment> select-tuples ] bi
    >>comments ;

: reverse-chronological-order ( seq -- sorted )
    [ [ date>> ] compare invert-comparison ] sort ;

: validate-author ( -- )
    { { "author" [ [ v-username ] v-optional ] } } validate-params ;

: list-posts ( -- posts )
    f <post> "author" value >>author
    select-tuples [ dup id>> f <comment> count-tuples >>comments ] map
    reverse-chronological-order ;

: <list-posts-action> ( -- action )
    <page-action>
        [
            list-posts "posts" set-value
        ] >>init

        { blogs "list-posts" } >>template ;

: <list-posts-feed-action> ( -- action )
    <feed-action>
        [ "Recent Posts" ] >>title
        [ list-posts ] >>entries
        [ list-posts-url ] >>url ;

: <user-posts-action> ( -- action )
    <page-action>
        "author" >>rest
        [
            validate-author
            list-posts "posts" set-value
        ] >>init
        { blogs "user-posts" } >>template ;

: <user-posts-feed-action> ( -- action )
    <feed-action>
        [ validate-author ] >>init
        [ "Recent Posts by " "author" value append ] >>title
        [ list-posts ] >>entries
        [ "author" value user-posts-url ] >>url ;

: <post-feed-action> ( -- action )
    <feed-action>
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
            ] nest-values
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
            uid "author" set-value
        ] >>validate

        [
            f <post>
                dup { "title" "content" } deposit-slots
                uid >>author
                now >>date
            [ insert-tuple ] [ entity-url <redirect> ] bi
        ] >>submit

        { blogs "new-post" } >>template ;

: <edit-post-action> ( -- action )
    <page-action>
        "id" >>rest

        [
            validate-integer-id
            "id" value <post> select-tuple from-object
        ] >>init

        [
            validate-integer-id
            validate-post
        ] >>validate

        [
            "id" value <post> select-tuple
                dup { "title" "content" } deposit-slots
            [ update-tuple ] [ entity-url <redirect> ] bi
        ] >>submit

        { blogs "edit-post" } >>template ;
    
: <delete-post-action> ( -- action )
    <action>
        [
            validate-integer-id
            { { "author" [ v-username ] } } validate-params
        ] >>validate
        [
            "id" value <post> delete-tuples
            "author" value user-posts-url <redirect>
        ] >>submit ;

: validate-comment ( -- )
    {
        { "parent" [ v-integer ] }
        { "content" [ v-required ] }
    } validate-params ;

: <new-comment-action> ( -- action )
    <action>

        [
            validate-comment
            uid "author" set-value
        ] >>validate

        [
            "parent" value f <comment>
                "content" value >>content
                uid >>author
                now >>date
            [ insert-tuple ] [ entity-url <redirect> ] bi
        ] >>submit ;
    
: <delete-comment-action> ( -- action )
    <action>
        [
            validate-integer-id
            { { "parent" [ v-integer ] } } validate-params
        ] >>validate
        [
            f "id" value <comment> delete-tuples
            "parent" value view-post-url <redirect>
        ] >>submit ;
    
: <blogs> ( -- dispatcher )
    blogs new-dispatcher
        <list-posts-action> "" add-responder
        <list-posts-feed-action> "posts.atom" add-responder
        <user-posts-action> "by" add-responder
        <user-posts-feed-action> "by.atom" add-responder
        <view-post-action> "post" add-responder
        <post-feed-action> "post.atom" add-responder
        <new-post-action> <protected>
            "make a new blog post" >>description
            "new-post" add-responder
        <edit-post-action> <protected>
            "edit a blog post" >>description
            "edit-post" add-responder
        <delete-post-action> <protected>
            "delete a blog post" >>description
            "delete-post" add-responder
        <new-comment-action> <protected>
            "make a comment" >>description
            "new-comment" add-responder
        <delete-comment-action> <protected>
            "delete a comment" >>description
            "delete-comment" add-responder
    <boilerplate>
        { blogs "blogs-common" } >>template ;
