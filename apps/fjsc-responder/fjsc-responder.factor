! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
IN: fjsc-responder
USING: kernel lazy-lists parser-combinators fjsc cont-responder html io namespaces file-responder httpd hashtables ;

USE: prettyprint

: fjsc-eval-page ( -- )
  [ "response" get . ] string-out log-message
  "code" "response" get hash dup log-message
  serving-text
  'expression' parse car 
  parse-result-parsed compile write flush ;

: fjsc-page ( -- )
  [
    <html>
      <head> 
        <script "text/javascript" =type "/responder/fjsc-resources/yahoo/yahoo.js" =src script> </script>
        <script "text/javascript" =type "/responder/fjsc-resources/yahoo/event.js" =src script> </script>
        <script "text/javascript" =type "/responder/fjsc-resources/yahoo/connection.js" =src script> </script>
        <script "text/javascript" =type "/responder/fjsc-resources/bootstrap.js" =src script> </script>
      </head>
      <body>	
	<form "toeval" =id "fjsc_eval(document.getElementById(\"toeval\"));return false;" =onsubmit "post" =method form>
	  <textarea "code" =name "code" =id textarea>
	  </textarea>
	  <input "submit" =type input/>
	</form>
	<div "compiled" =id div>
	</div>
	<div "stack" =id div>
	</div>
      </body>     
    </html>
  ] show ;
  

"fjsc" [ fjsc-page ] install-cont-responder
"fjsceval" [ fjsc-eval-page ] add-simple-responder
"fjsc-resources" [
  [
    "apps/fjsc-responder/resources/" resource-path "doc-root" set
    file-responder
  ] with-scope
] add-simple-responder


