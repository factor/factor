! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel furnace fjsc  parser-combinators namespaces
       lazy-lists io io.files furnace.validator sequences
       http.client http.server http.server.responders
       webapps.file ;
IN: webapps.fjsc

: compile ( code -- )
  #! Compile the factor code as a string, outputting the http
  #! response containing the javascript.
  serving-text
  'expression' parse-1 fjsc-compile
  write flush ;

! The 'compile' action results in an URL that looks like
! 'responder/fjsc/compile'. It takes one query or post
! parameter called 'code'. It calls the 'compile' word
! passing the parameter to it on the stack.
\ compile {
  { "code" v-required }
} define-action

: compile-url ( url -- )
  #! Compile the factor code at the given url, return the javascript.
  dup "http:" head? [ "Unable to access remote sites." throw ] when
  "http://" host rot 3append http-get 2nip compile "();" write flush ;

\ compile-url {
  { "url" v-required }
} define-action

: repl ( -- )
  #! The main 'repl' page.
  f "repl" "head" render-page* ;

! An action called 'repl'
\ repl { } define-action

: fjsc-web-app ( -- )
  ! Create the web app, providing access
  ! under '/responder/fjsc' which calls the
  ! 'repl' action.
  "fjsc" "repl" "extra/webapps/fjsc" web-app

  ! An URL to the javascript resource files used by
  ! the 'fjsc' responder.
  "fjsc-resources" [
   [
     "extra/fjsc/resources/" resource-path "doc-root" set
     file-responder
   ] with-scope
  ] add-simple-responder

  ! An URL to the resource files used by
  ! 'termlib'.
  "fjsc-repl-resources" [
   [
     "extra/webapps/fjsc/resources/" resource-path "doc-root" set
     file-responder
   ] with-scope
  ] add-simple-responder ;

MAIN: fjsc-web-app
