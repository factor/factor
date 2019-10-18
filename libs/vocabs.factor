REQUIRES: libs/vars ;

USING: kernel parser words io errors namespaces sequences assocs
       arrays test vars ;

IN: vocabs

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! TODO
! 
! foo vocab directory:
! 
! foo/source.factor
! foo/help.factor
! foo/tests.factor

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: vocabulary-roots

{ "core"
  "vocabs"
  "vocabs/collections"
  "libs"
  "libs/collections"
  "apps"
  "unmaintained"
  "demos"
} vocabulary-roots set-global

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! vocabulary to file mapping scheme:

! x => x/x.factor

! y => y/y.factor

! x.foo => x/foo/foo.factor

! x.foo.bar => x/foo/bar/bar.factor

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: vocabulary-file ( vocab -- file )
"." split dup peek ".factor" append add "/" join ;

: vocabulary-facts ( vocab -- file )
"." split dup peek ".facts" append add "/" join ;

: vocabulary-tests ( vocab -- file )
"." split "tests.factor" add "/" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: find-vocabulary ( vocab -- file-or-f )
vocabulary-file vocabulary-roots> [ "/" rot 3append resource-path ] map-with
[ exists? ] find nip ;

: find-facts ( vocab -- file-or-f )
vocabulary-facts vocabulary-roots> [ "/" rot 3append resource-path ] map-with
[ exists? ] find nip ;

: find-tests ( vocab -- file )
vocabulary-tests vocabulary-roots> [ "/" rot 3append resource-path ] map-with
[ exists? ] find nip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: import-vocabulary ( vocab -- )
dup find-vocabulary run-file
dup find-facts dup [ run-file ] [ drop ] if
    vocab ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: check-vocab* ( name -- vocab )
{ { [ dup vocab ] [ vocab ] }
  { [ dup find-vocabulary ] [ import-vocabulary ] }
  { [ t ] [ <check-vocab> { { "Continue" f } } throw-restarts ] }
} cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: test-vocab ( name -- ) find-tests 1array run-tests ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: vocabulary-articles

: init-vocabulary-articles ( -- ) H{ } clone vocabulary-articles set-global ;

: set-vocabulary-article ( vocab article -- )
swap vocabulary-articles> set-at ;

! handbook.facts has this line in it to include the module articles:
! 
! { $outliner [ modules-help ] }
! 
! It should be replaced with something like this:
! 
! { $outliner [ vocabulary-articles> hash-values ] }

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: vocabulary-mains

: init-vocabulary-mains ( -- ) H{ } clone vocabulary-mains set-global ;

: set-vocabulary-main ( vocab quot -- ) swap vocabulary-mains> set-at ;

: run-vocab ( vocab -- ) vocabulary-mains> at call ;

! It would be nice for the ui to show a list of "runnable vocabularies".
! This list is easy to get:
! 
!	vocabulary-mains> keys

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: parser

: check-vocab check-vocab* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: syntax

: WINDOWS-USE: scan windows? [ use+ ] [ drop ] if ; parsing

: UNIX-USE: scan unix? [ use+ ] [ drop ] if ; parsing

PROVIDE: libs/vocabs ;
