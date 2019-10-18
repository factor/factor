REQUIRES: libs/vars ;

USING: kernel parser words io errors namespaces sequences vars ;

IN: vocabs

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: import-vocabulary ( vocab -- )
dup find-vocabulary run-file
dup find-facts dup [ run-file ] [ drop ] if
    vocab ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: check-vocab* ( name -- vocab )
{ { [ dup vocab ] [ vocab ] }
  { [ dup find-vocabulary ] [ import-vocabulary ] }
  { [ t ] [ <check-vocab> { { "Continue" f } } condition ] }
} cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: parser

: check-vocab check-vocab* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: syntax

: WINDOWS-USE: scan windows? [ use+ ] [ drop ] if ; parsing

: UNIX-USE: scan unix? [ use+ ] [ drop ] if ; parsing

PROVIDE: libs/vocabs ;