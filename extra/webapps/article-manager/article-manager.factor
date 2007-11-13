! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel furnace sqlite.tuple-db webapps.article-manager.database 
       sequences namespaces math arrays assocs quotations io.files
       http.server http.basic-authentication http.server.responders 
       webapps.file ;
IN: webapps.article-manager

: current-site ( -- site )
  host get-site* ;

TUPLE: template-args arg1 ;
  
C: <template-args> template-args

: setup-site ( -- )
  "article-manager-site" [
    current-site "setup-site" "edit-head" "Setup Site" render-titled-page* 
  ] with-basic-authentication ;

\ setup-site { } define-action

: site-index ( -- )
  host get-site [
    current-site "index" "head" pick site-title render-titled-page* 
  ] [  
    "404" "Unknown Site" httpd-error 
  ] if ;

! An action called 'site-index' 
\ site-index { } define-action

: requested-article-path ( action -- url )
  length "responder-url" get length 1 + + "request" get swap tail ;

: requested-article-url ( action -- url )
  requested-article-path CHAR: / over index dup [
    head
  ] [
    drop
  ] if ;

: requested-article-filename ( action -- url )
  requested-article-path CHAR: / over last-index 1+ tail ;

: tag ( -- )
  current-site
  "tag" requested-article-url host swap get-tag dup >r
  2array <template-args> "tag" "head" r> tag-title render-titled-page* ;

! An action for tags
\ tag { } define-action 

: article ( -- )
  current-site 
  "article" requested-article-url host swap article-by-url dup >r
  2array <template-args>
  "article" "head" r> article-title render-titled-page* ;

! An action for articles
\ article { } define-action 


: edit-article ( -- )
  "article-manager-article" [
    "edit-article" requested-article-url host swap article-by-url* 
    "edit-article" "edit-head" "Edit" render-titled-page* 
  ] with-basic-authentication ;

! An action for articles
\ edit-article { } define-action 

: update-article ( pubdate title status tags body url -- )
  "article-manager-article" [
    host swap article-by-url* 
    [ set-article-body ] keep
    [ set-article-tags ] keep
    [ set-article-status ] keep
    [ set-article-title ] keep
    [ set-article-pubdate ] keep
    [ save-article ] keep
    article-url "responder-url" get "article/" rot 3append "/" append permanent-redirect
  ] with-basic-authentication ;
  

\ update-article { { "pubdate" } { "title" } { "status" } { "tags" } { "body" } { "url" } } define-action 

: update-article-link ( -- link )
  "responder-url" get "update-article" append ;

: remove-article ( url -- )
  "article-manager-article" [
    host swap article-by-url [ remove-article ] when*
    "responder-url" get permanent-redirect
  ] with-basic-authentication ;

\ remove-article { { "url" } } define-action 

: update-site ( ad3 ad2 ad1 html title intro footer hostname -- )
  "article-manager-site" [
    dup get-site* 
    [ set-site-hostname ] keep
    [ set-site-footer ] keep
    [ set-site-intro ] keep
    [ set-site-title ] keep
    [ set-site-html ] keep
    [ set-site-ad1 ] keep
    [ set-site-ad2 ] keep
    [ set-site-ad3 ] keep
    get-db swap save-tuple 
    "responder-url" get permanent-redirect 
  ] with-basic-authentication ;


\ update-site { { "ad3" } { "ad2" } { "ad1" } { "html" } { "title" } { "intro" } { "footer" } { "hostname" } } define-action 

: update-site-link ( -- link )
  "responder-url" get "update-site" append ;


SYMBOL: redirections

: redirector ( url quot -- )
  over redirections get H{ } or at dup [ 
    2nip permanent-redirect
  ] [
    drop call
  ] if ;

: install-redirector ( hash responder host -- )
  vhost [ responder ] bind [
    "post" get [ redirector ] curry "post" set
    "get" get [ redirector ] curry "get" set
    redirections set
  ] bind ;

: get-redirections ( responder host -- hash )
  vhost [ responder ] bind [ redirections get ] bind ;

: article-manager-web-app ( -- )
  ! Create the web app, providing access 
  ! under '/responder/article-manager' which calls the
  ! 'site-index' action.
  "article-manager" "site-index" "extra/webapps/article-manager/furnace/" web-app

  ! An URL to the javascript and css resource files
  "article-manager-resources" [
    [
      "extra/webapps/article-manager/resources/" resource-path "doc-root" set
      file-responder
    ] with-scope
  ] add-simple-responder ;

MAIN: article-manager-web-app

! Just for testing. Password is 'password'
! H{ { "admin" "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" } } "article-manager-site" add-realm 
! H{ { "admin" "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" } } "article-manager-article" add-realm 

