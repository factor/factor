! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel furnace xml xml-writer io httpd sequences 
       namespaces file-responder parser-combinators lazy-lists
       fjsc http-client errors ;
IN: furnace:fjsc

: compile ( code -- )
  #! Compile the factor code as a string, outputting the http
  #! response containing the javascript.
  serving-text
  'expression' parse car parse-result-parsed fjsc-compile 
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

! Create the web app, providing access 
! under '/responder/fjsc' which calls the
! 'repl' action.
"fjsc" "repl" "apps/furnace-fjsc" web-app

! An URL to the javascript resource files used by
! the 'fjsc' responder.
"fjsc-resources" [
 [
   "libs/fjsc/resources/" resource-path "doc-root" set
   file-responder
 ] with-scope
] add-simple-responder

! An URL to the resource files used by
! 'termlib'.
"fjsc-repl-resources" [
 [
   "apps/furnace-fjsc/resources/" resource-path "doc-root" set
   file-responder
 ] with-scope
] add-simple-responder
