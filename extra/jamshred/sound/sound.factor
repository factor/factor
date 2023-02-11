! Copyright (C) 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io.pathnames kernel openal openal.alut sequences ;
IN: jamshred.sound

TUPLE: sounds bang ;

: assign-sound ( source wav-path -- )
    resource-path create-buffer-from-wav AL_BUFFER swap set-source-param ;

: <sounds> ( -- sounds )
    init-openal 1 gen-sources first sounds boa
    dup bang>> "extra/jamshred/sound/bang.wav" assign-sound ;

: bang ( sounds -- ) bang>> source-play check-error ;
