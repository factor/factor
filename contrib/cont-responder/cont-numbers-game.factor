! cont-number-guess
!
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
! This example modifies the console based 'numbers-game' example
! in a very minimal way to demonstrate conversion of a console
! program to a web based application.
!
! All that was required was changing the input and output functions
! to use HTML. The remaining code was untouched. 
!
! The result is not that pretty but it shows the basic idea.
IN: numbers-game
USE: combinators
USE: kernel
USE: math
USE: random
USE: parser
USE: html
USE: cont-responder
USE: cont-utils
USE: stack
USE: stdio
USE: namespaces

: web-print ( str -- )
  #! Display the string in a web page.
  [
    swap dup
    <html>
      <head> <title> write </title> </head>
      <body>
        <p> write </p>
        <p> <a href= a> "Press to continue" write </a> </p>
      </body>
    </html>
  ] show 2drop ;

: read-number ( -- )
  [
    <html>
      <head> <title> "Enter a number" write </title> </head>
      <body>
        <form action= method= "post" form>
          <p> 
            "Enter a number:" write
            <input type= "text" name= "num" size= "20" input/>
            <input type= "submit" value= "Press to continue" input/>
          </p>
        </form>
      </body>
    </html>
  ] show [ "num" get ] bind parse-number ;

: guess-banner
  "I'm thinking of a number between 0 and 100." web-print ;
: guess-prompt "Enter your guess: " web-print ;
: too-high "Too high" web-print ;
: too-low "Too low" web-print ;
: correct "Correct - you win!" web-print ;
: inexact-guess ( actual guess -- )
     < [ too-high ] [ too-low ] ifte ;

: judge-guess ( actual guess -- ? )
    2dup = [
        2drop correct f
    ] [
        inexact-guess t
    ] ifte ;

: number-to-guess ( -- n ) 0 100 random-int ;

: numbers-game-loop ( actual -- )
    dup guess-prompt read-number judge-guess [
        numbers-game-loop
    ] [
        drop
    ] ifte ;

: numbers-game number-to-guess numbers-game-loop ;

"numbers-game" [ numbers-game ] install-cont-responder