
USING: kernel generic sequences ;

IN: generic.lib

: chain ( seq -- object ) unclip swap [ tuck set-delegate ] each ;