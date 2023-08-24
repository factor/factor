! Copyright (C) 2020 Fred Alger
! See https://factorcode.org/license.txt for BSD license.
USING: arrays editors environment io.files.info io.pathnames
kernel make math.parser namespaces sequences ;
IN: editors.acme

SINGLETON: acme

: plan9-path ( -- path )
  \ plan9-path get [
    "PLAN9" os-env [
      "/usr/local/plan9"
    ] unless*
  ] unless* ;

: plan9-tool-path ( tool -- path )
  [ plan9-path "/bin" append ] dip append-path ;

<PRIVATE

: (plumb-path) ( -- path )
  "plumb" plan9-tool-path ;

: (massage-pathname) ( file line -- str )
  over file-info regular-file?
  [ number>string 2array ":" join ]
  [ drop ] if ;

PRIVATE>

M: acme editor-command ( file line -- command )
  [ (plumb-path) , "-d" , "edit" , (massage-pathname) , ] { } make ;
