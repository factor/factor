! Copyright (C) 2006 Matthew Willis. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!

USING: httpd threads kernel namespaces furnace sequences 
html strings math assocs crypto io file-responder calendar 
prettyprint parser errors sha2 basic-authentication arrays
serialize ;

IN: furnace:onigiri

TUPLE: entry title stub body created ;

TUPLE: user name password ;

TUPLE: meta key value ;

: title>stub ( title -- stub )
    ! creates a url friendly name based on the title
    " " split [ [ alpha? ] subset ] map "" swap remove "-" join ;

C: entry ( title body stub -- entry )
    tuck set-entry-stub 
    tuck set-entry-body 
    dup entry-stub [ over title>stub over set-entry-stub ] unless
    now over set-entry-created tuck set-entry-title ;

C: user ( name password -- user )
    swap string>sha-256-string over set-user-password
    tuck set-user-name ;

: base-url ( -- url )
    "http://" "Host" "header" get at append ;

: action>url ( action -- url )
    "responder-url" get swap append ;

: stub>url ( stub -- url )
    "entry-show?stub=" swap append action>url ;

: stub>entry ( stub -- entry )
    entry get-global [ entry-stub = ] subset-with 
    dup empty? [ drop f ] [ first ] if ;

: atom ( -- )
    "text/xml" serving-content
    [ f "atom" render-template ] with-html-stream ;

: sitemap ( -- )
    "text/xml" serving-content
    [ f "sitemap" render-template ] with-html-stream ;

: css-path ( -- path )
    ! "text/css" serving-content
    "css" meta crud-lookup* meta-value
    [ "onigirihouse.css" ] unless* ;

DEFER: key>meta*
: entry-list ( -- )
	"title" key>meta* meta-value
	serving-html [
	    <furnace-model> "header" render-template
    	entry get-global
		[ [ entry-created ] 2apply swap compare-timestamps ] sort
		[ "entry-show" render-template ] each
    	f "footer" render-template
	] with-html-stream ;

DEFER: key>meta
: entry-show ( stub -- )
    stub>entry
    [ 
        "title" key>meta* meta-value
        " - " pick entry-title 3append
        serving-html [
            <furnace-model> "header" render-template
            "entry-show" render-template
            f "footer" render-template
        ] with-html-stream
    ] [ 
        "title" key>meta* meta-value " - Entry not found" append
        serving-html [ 
            [ 
                <p> "The entry you are searching for could not be found" write </p>
                <p> [ entry-list ] "Back to " "title" key>meta
                [ meta-value ] [ "the main page" ] if* append render-link
                </p>
            ] html-document
        ] with-html-stream
    ] if* ;

: entry-edit ( stub wiky -- )
    swap stub>entry dup [ entry-title ] [ f ] if*
    "title" key>meta* meta-value " - editing " rot 3append
    serving-html [
        <furnace-model> "header" render-template
        swap "entry-edit" "entry-edit-plain" ? render-template
        f "footer" render-template
    ] with-html-stream ;

: entry-update ( title body stub -- )
    "onigiri-realm" [
        dup stub>entry [
            nip tuck set-entry-body tuck set-entry-title
        ] [
            <entry> dup entry get-global swap add entry set-global 
    	] if* entry-stub entry-show
    ] with-basic-authentication ;

: entry-delete ( stub -- )
    "onigiri-realm" [ 
        stub>entry entry get-global remove entry set-global entry-list
    ] with-basic-authentication ;

DEFER: name>user
: onigiri-realm ( name password -- bool )
    swap name>user [ user-password = ] [ drop f ] if*
    user get-global empty? or ;
    
: register-actions ( -- )
    \ entry-list { } define-action
    \ entry-show { { "stub" } } define-action
    \ entry-edit { { "stub" } { "wiky" f v-default } } define-action
    \ entry-update { { "title" } { "body" } { "stub" } } define-action
    \ entry-delete { { "stub" } } define-action
    \ atom { } define-action
    \ sitemap { } define-action
    "onigiri" "entry-list" "apps/furnace-onigiri/templates/" web-app 
    "onigiri-resources" [ 
        [
            "apps/furnace-onigiri/resources/" resource-path "doc-root" set
            file-responder
        ] with-scope
    ] add-simple-responder 
    [ onigiri-realm ] "onigiri-realm" add-realm
    ! and finally, use scaffolding for metadata and user data 
    [ 
        "furnace:onigiri" set-in
        meta "key" "onigiri-realm" scaffold
        user "name" "onigiri-realm" scaffold 
    ] with-scope ;

: onigiri ( -- )
    register-actions
    "default-responder" key>meta* meta-value
    [ "onigiri" set-default-responder ] when
    "port" key>meta* meta-value string>number [ 8888 ] unless*
    [ httpd ] in-thread drop ;

: onigiri-dump ( path -- )
    <file-writer> [
        [
            entry get-global serialize
            meta get-global serialize
            user get-global serialize
        ] with-serialized
    ] with-stream ;

: onigiri-boot ( path -- )
    <file-reader> [
        [
            deserialize entry set-global
            deserialize meta set-global
            deserialize user set-global
        ] with-serialized
    ] with-stream ;
