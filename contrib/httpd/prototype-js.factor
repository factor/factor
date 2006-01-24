! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Wrapper for the Prototype javascript library.
! For information and license details for protoype 
! see http://prototype.conio.net
IN: prototype-js
USING: io httpd cont-responder html kernel lists namespaces strings ;

: include-prototype-js ( -- )
  #! Write out the HTML script tag to include the prototype
  #! javascript library.
  <script "text/javascript" =type "/responder/javascript/prototype.js" =src script>
  </script> ;

: updating-javascript ( id quot -- string )
  #! Return the javascript code to perform the updating
  #! ajax call.
  quot-url swap 
  [ "new Ajax.Updater(\"" % % "\",\"" % % "\", { method: \"get\" });" % ] "" make ;

: updating-anchor ( text id quot -- )
  #! Write the HTML for an anchor that when clicked will
  #! call the given quotation on the server. The output generated
  #! from that quotation will replace the DOM element on the page with
  #! the given id. The 'text' is the anchor text.
  <a "#" =href updating-javascript =onclick a> write </a> ;
