! Copyright (C) 2005 Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
IN: embedded
USING: sequences kernel parser math namespaces io html test errors ;

! if example.fhtml contains:
! <html>
!     <head><title>Simple Embedded Factor Example</title></head>
!     <body>
! 	<% 5 [ %><p>I like repetition</p>
!       <% drop ] each %>
!     </body>
! </html>
!
! then "example.fhtml" run-embedded-file prints to stdout:
! <html>
!     <head><title>Simple Embedded Factor Example</title></head>
!     <body>
!         <p>I like repetition</p>
!         <p>I like repetition</p>
!         <p>I like repetition</p>
!         <p>I like repetition</p>
!         <p>I like repetition</p>
! 
!     </body>
! </html>

: get-text ( string -- remainder chunk )
    "<%" over start dup -1 = [
	    drop "" swap
    ] [
	    2dup head >r tail r>
    ] if ;

: get-embedded ( string -- string code-string )
    ! regexps where art thou?
    "%>" over 2 start* 2dup swap 2 -rot subseq >r 2 + tail r> ;

: get-first-chunk ( string -- string )
    dup "<%" head? [
	    get-embedded parse %
    ] [
	    get-text , \ write-html ,
    ] if ;

: embedded>factor ( string -- )
    dup length 0 > [
	    get-first-chunk embedded>factor
    ] [ drop ] if ;

: parse-embedded ( string -- quot )
    #! simple example: "numbers: <% 3 [ 1 + pprint ] each %>"
    #! => "\"numbers: \" write 3 [ 1 + pprint ] each"
    [ embedded>factor ] [ ] make ;

: eval-embedded ( string -- ) parse-embedded call ;

: run-embedded-file ( filename -- )
    [
        [
            file-vocabs
            dup file set ! so that reload works properly
            dup <file-reader> contents eval-embedded
        ] with-scope
    ] assert-depth drop ;

: embedded-convert ( infile outfile -- )
    <file-writer> [ run-embedded-file ] with-stream ;
