! Copyright (C) 2004 Chris Double.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
! An httpd responder that demonstrates using XMLHttpRequest to send
! asynchronous requests back to the server.
!
IN: live-updater-responder
USE: live-updater
USE: namespaces
USE: html
USE: words
USE: stdio
USE: kernel
USE: cont-responder
USE: prettyprint

: live-search-apropos-word ( string -- )
  #! Given a string that is a factor word, show the
  #! aporpos of that word.
  <namespace> [
    "responder" "browser" put
    <pre> 
        stdio get <html-stream> [   
          apropos.
        ] with-stream              
    </pre>
  ] bind ;
      
: live-updater-responder ( -- )
  [
    drop
    <html> 
      <head>  
        <title> "Live Updater Example" write </title>
        include-live-updater-js
      </head>
      <body> 
       [
         [ 
           "millis" [ millis prettyprint ] "Display Server millis" live-anchor
           <div id= "millis" div>  
             "The millisecond time from the server will appear here" write 
           </div>         
         ]
         [        
           "Enter a word to apropos:" paragraph
           "apropos" [ live-search-apropos-word ] live-search
         ]
         [
           <div id= "apropos" div> 
             "" write
           </div>
         ] 
       ] vertical-layout
     </body>
    </html>
  ] show ;

"live-updater" [ live-updater-responder ] install-cont-responder
