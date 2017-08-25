! Copyright (C) 2009 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: ascii assocs io.pathnames kernel namespaces
vocabs ;
IN: audio.loader

ERROR: unknown-audio-extension extension ;

SYMBOL: audio-types
audio-types [ H{ } clone ] initialize

: register-audio-extension ( extension quot -- )
    swap audio-types get set-at ;

: read-audio ( path -- audio )
    dup file-extension >lower audio-types get ?at
    [ call( path -- audio ) ]
    [ unknown-audio-extension ] if ;

"audio.wav" require
"audio.aiff" require
