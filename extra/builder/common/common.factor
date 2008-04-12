
USING: kernel namespaces io.files sequences vars ;

IN: builder.common

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: builds-dir

: builds ( -- path )
  builds-dir get
  home "/builds" append
  or ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: stamp

SYMBOL: upload-to-factorcode