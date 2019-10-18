! Copyright (C) 2006 Matthew Willis. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: httpd threads kernel namespaces furnace sqlite tuple-db
sequences html strings math hashtables crypto io file-responder calendar 
prettyprint parser errors sha2 basic-authentication ;

IN: furnace:onigiri

! start should be removed after doublec's responder-url hits the main repos
SYMBOL: responder-url
"/" responder-url set
! end

TUPLE: entry title stub body created updated ;
entry default-mapping set-mapping

: any-entry ( -- entry )
    ! useful for tuple-db searching
    f f f f f <entry> ;

TUPLE: onigiri-meta value key ;
onigiri-meta default-mapping set-mapping

TUPLE: user name password level ;
user default-mapping set-mapping

DEFER: onigiri
: setup-entries ( db-name -- )
    ! create the entries table
	sqlite-open dup entry create-tuple-table sqlite-close ;

: setup-meta ( port db-name -- )
    ! create the onigiri metadata table
    ! the port data is necessary, all other data must be entered manually
    ! until we get the CRUD interface
    sqlite-open [ onigiri-meta create-tuple-table ] keep
    swap dupd number>string "port" <onigiri-meta> save-tuple sqlite-close ;

: setup-users ( db-name -- )
    ! create the users table, adding a default admin user with password admin
    sqlite-open dup user create-tuple-table dup
    "admin" dup string>sha-256-string over <user> save-tuple sqlite-close ;

: load-onigiri-meta ( -- )
    "db" \ onigiri get hash
    f f <onigiri-meta> find-tuples
    [ 
        dup onigiri-meta-value swap onigiri-meta-key 
        \ onigiri get set-hash 
    ] each ;

: remove-onigiri-meta ( -- )
    ! probably shouldn't use this directly
    "db" \ onigiri get hash dup f f <onigiri-meta> find-tuples
    [ delete-tuple ] each-with ;

: save-onigiri-meta ( -- )
    remove-onigiri-meta
    "db" \ onigiri get [ hash ] keep hash-keys
    [ 
        dup \ onigiri get hash dup string?
        [ swap <onigiri-meta> save-tuple ]
        [ 3drop ] if
    ] each-with ;

: title>stub ( title -- stub )
    ! creates a url friendly name based on the title
    " " split [ [ alpha? ] subset ] map "" swap remove "-" join ;

: action>url ( action -- url )
    responder-url get swap append ;

: stub>url ( stub -- url )
    "entry-show?entry=" swap append action>url ;

: stub>entry ( stub -- entry )
    [ 
        "db" \ onigiri get hash swap any-entry [ set-entry-stub ] keep
        find-tuples dup empty? [ drop f ] [ first ] if 
    ] [ f ] if* ;

: name>user ( name -- user )
    [
        "db" \ onigiri get hash swap f f <user> find-tuples
        dup empty? [ drop f ] [ first ] if
    ] [ f ] if* ;

: key>meta ( key -- onigiri-meta )
    [
        "db" \ onigiri get hash f rot <onigiri-meta> find-tuples
        dup empty? [ drop f ] [ first ] if
    ] [ f ] if* ;

: compose-entry ( title body-lines -- )
	"\n" join over title>stub swap
	millis number>string dup <entry>
	"db" \ onigiri get hash swap insert-tuple ;

: millis>timestamp ( millis -- timestamp )
    1000 /f seconds unix-1970 swap +dt ;

: atom ( -- )
    "text/xml" serving-content
    f "atom" render-template ;

: css-path ( -- path )
    ! "text/css" serving-content
    "css" \ onigiri get hash [ "onigirihouse" ] unless*
    "apps/furnace-onigiri/resources/" swap ".css" 3append resource-path ;

: css ( -- )
    "text/css" serving-content css-path [
        [
            file-vocabs
            dup file set ! so that reload works properly
            dup <file-reader> contents write
        ] with-scope
    ] assert-depth drop ;

TUPLE: onigiri-layout title quot ;
: onigiri-document ( title quot -- )
    <onigiri-layout> "front" render-template ;

: entry-list ( -- )
	"title" \ onigiri get hash 
	serving-html [
    	[
			"db" \ onigiri get hash any-entry find-tuples
			[ [ entry-created string>number ] 2apply <=> neg ] sort
			[ "entry" render-template ] each
    	] onigiri-document
	] with-html-stream ;

: entry-show ( stub -- )
    stub>entry 
    [ 
        dup "title" \ onigiri get hash 
        " - " rot entry-title 3append swap
        serving-html [
            [
                "entry" render-template
            ] curry onigiri-document
        ] with-html-stream
    ] [ 
        "title" \ onigiri get hash " - Entry not found" append
        serving-html [ 
            [ f "no-entry" render-template ] onigiri-document
        ] with-html-stream
    ] if* ;

: entry-edit ( stub -- )
    [ 
        any-entry [ set-entry-stub ] keep "db" \ onigiri get hash 
        swap find-tuples dup length zero? 
        [ drop any-entry "new entry"] [ first dup entry-title ] if
    ] [ any-entry "new entry" ] if*
    "title" \ onigiri get hash " - editing " append swap append
    serving-html swap [
        [
            "edit" render-template
        ] curry onigiri-document
    ] with-html-stream ;

: entry-update ( body title stub -- )
    "onigiri-users" [
        [ 
            stub>entry [ any-entry ] unless*
        ] [ any-entry over title>stub swap [ set-entry-stub ] keep ] if*
        [ set-entry-title ] keep
        [ CHAR: \r rot remove swap set-entry-body ] keep
    	millis number>string swap [ set-entry-updated ] 2keep
    	dup entry-created [ nip ] [ [ set-entry-created ] keep ] if
    	"db" \ onigiri get hash swap [ save-tuple ] keep 
    	entry-stub "entry-show?entry=" swap append permanent-redirect
    ] with-basic-authentication ;

: entry-delete ( stub -- )
    "onigiri-users" [ 
        stub>entry [
            "db" \ onigiri get hash swap delete-tuple
        ] when*
        "entry-list" permanent-redirect
    ] with-basic-authentication ;

: user-list ( -- )
    "onigiri-users" [
        serving-html [
            f "admin-header" render-template
            f "user-list" render-template
            f "admin-footer" render-template
        ] with-html-stream
    ] with-basic-authentication ;

: user-edit ( name -- )
    "onigiri-users" [
        serving-html [
            f "admin-header" render-template
            dup [ name>user nip ] when* "user-edit" render-template
            f "admin-footer" render-template
        ] with-html-stream
    ] with-basic-authentication ;

: user-update ( name password level -- )
    "onigiri-admin" [
        pick name>user
        [ 
            tuck set-user-level swap string>sha-256-string over 
            set-user-password nip 
        ]
        [ swap string>sha-256-string swap <user> ] if*
        "db" \ onigiri get hash swap save-tuple
        "user-list" permanent-redirect
    ] with-basic-authentication ;

: user-delete ( name -- )
    "onigiri-admin" [
        name>user [ "db" \ onigiri get hash swap delete-tuple ] when*
        "user-list" permanent-redirect
    ] with-basic-authentication ;

: meta-list ( -- )
    "onigiri-users" [
        serving-html [
            f "admin-header" render-template
            f "meta-list" render-template
            f "admin-footer" render-template
        ] with-html-stream
    ] with-basic-authentication ;

: meta-update ( value key -- )
    "onigiri-admin" [
        \ onigiri get set-hash "meta-list" permanent-redirect
    ] with-basic-authentication ;

: register-actions ( -- )
    \ entry-list { } define-action
    \ entry-show { { "entry" } } define-action
    \ entry-edit { { "entry" } } define-action
    \ entry-update { { "body" } { "title" } { "stub" } } define-action
    \ entry-delete { { "entry" } } define-action
    \ user-list { } define-action
    \ user-edit { { "name" } } define-action
    \ user-update { { "name" } { "password" } { "level" } } define-action
    \ user-delete { { "name" } } define-action
    \ meta-list { } define-action
    \ meta-update { { "value" } { "key" } } define-action
    \ atom { } define-action
    \ css  { } define-action
    "onigiri" "entry-list" "apps/furnace-onigiri/templates/" web-app ;

: setup-onigiri ( port db-name -- )
    tuck setup-meta dup setup-entries setup-users ;

: stop-onigiri ( -- )
    ! save metadata, close the db, remove the onigirihouse responder,
    ! and if it was the default responder, make "file" the default responder
    save-onigiri-meta
    "db" \ onigiri get hash sqlite-close
    "onigiri" responders get remove-hash
    "responder" "default" responders get hash hash
    "onigiri" = [ "file" set-default-responder ] when ;

: onigiri ( db-name -- )
    ! open the db, load metadata from the db, start httpd [optionally,
    ! with onigiri as the default responder]
    H{ } clone \ onigiri set
    sqlite-open "db" \ onigiri get set-hash 
    load-onigiri-meta register-actions
    "onigiri-as-default-responder" \ onigiri get hash "true" =
    [ "onigiri" set-default-responder ] when
    "port" \ onigiri get hash string>number [ httpd ] in-thread drop 
    ! add the onigiri users realm
    [ f <user> "db" \ onigiri get hash swap find-tuples empty? not ] 
    "onigiri-users" add-realm
    ! add the onigiri admins realm
    [ "admin" <user> "db" \ onigiri get hash swap find-tuples empty? not ]
    "onigiri-admin" add-realm ;