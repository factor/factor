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
! Start an httpd server and some words to re-load the continuation
! server files.
USE: httpd-responder
USE: httpd
USE: threads
USE: stack
USE: prettyprint
USE: combinators
USE: errors
USE: stdio
default-responders

USE: parser

: l1 
  "cont-html.factor" run-file  
  "cont-responder.factor" run-file 
  "cont-utils.factor" run-file ;
: l2 
  "cont-examples.factor" run-file ;
: l3 "todo.factor" run-file ;
: l4 "todo-example.factor" run-file ;
: l5 "live-updater.factor" run-file ;
: l6 "eval-responder.factor" run-file ;
: l7 "live-updater-responder.factor" run-file ;
: l8 "browser.factor" run-file ;
: la ;
: la [ 8888 httpd ] [ dup . flush [ la ] when* ] catch ;
! : lb [ la "httpd thread exited.\n" write flush ] in-thread  ;
