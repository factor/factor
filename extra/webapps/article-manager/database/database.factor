! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel sqlite sqlite.tuple-db io.files sequences splitting
       hashtables ;
IN: webapps.article-manager.database

TUPLE: site hostname title intro footer html ad1 ad2 ad3 ;

C: <site> site

TUPLE: article hostname url pubdate title status body tags ;

C: <article> article

TUPLE: tag hostname name title description ;

C: <tag> tag

site default-mapping set-mapping
article default-mapping set-mapping
tag default-mapping set-mapping 

: db ( -- object )
  { f } ;	    

: set-db ( value -- )
  0 db set-nth ;


: get-db ( -- value )
  0 db nth ;

: db-filename ( -- name )
  "extra/webapps/article-manager/article-manager.db" resource-path ;

: open-db ( -- )
  get-db [ sqlite-close ] when*
  db-filename exists? [
    db-filename sqlite-open set-db 
  ] [
    db-filename sqlite-open dup set-db
    dup article create-tuple-table
    dup site create-tuple-table
    tag create-tuple-table
  ] if ;

: close-db ( -- )
  get-db [ sqlite-close ] when*
  f set-db ;

: all-sites ( -- sites )
  get-db f f f f f f f f <site> find-tuples ;

: get-site ( hostname -- site )
  f f f f f f f <site> get-db swap find-tuples dup empty? [ 
    drop f
  ] [ 
    first 
  ] if ;

: get-site* ( hostname -- site )
  f f f f f f f <site> dup get-db swap find-tuples dup empty? [ 
    drop site-hostname dup "" "" "" "" "" "" <site> 
  ] [ 
    nip first 
  ] if ;

: get-tag ( hostname name -- tag )
  f f <tag> dup get-db swap find-tuples dup empty? [ 
    drop 
    [ dup tag-name swap set-tag-title ] keep
    [ "" swap set-tag-description ] keep
  ] [ 
    nip first 
  ] if ;

: add-article ( article -- )
  get-db swap insert-tuple ;

: remove-article ( article -- )
  get-db swap delete-tuple ;

: save-article ( article -- )
  get-db swap save-tuple ;

: all-articles ( hostname -- seq )
  f f f "published" f f <article> get-db swap find-tuples ;

: article-by-url ( hostname url -- article )
  f f f f f <article> get-db swap find-tuples dup empty? [
    drop f
  ] [ 
    first
  ] if ;

: article-by-url* ( hostname url -- article )
  f f f f f <article> dup get-db swap find-tuples dup empty? [
    drop 
    [ "" swap set-article-pubdate ] keep
    [ "" swap set-article-title ] keep
    [ "draft" swap set-article-status ] keep
    [ "" swap set-article-body ] keep
    [ "" swap set-article-tags ] keep
  ] [ 
    nip first
  ] if ;

: tags-for-article ( article -- seq )
  article-tags " " split [ empty? not ] subset ;

: all-tags ( hostname -- seq )
  all-articles [ tags-for-article ] map concat prune ;

: articles-for-tag ( tag -- seq )
  [ tag-name ] keep tag-hostname all-articles [
    tags-for-article member?
  ] curry* subset ;
