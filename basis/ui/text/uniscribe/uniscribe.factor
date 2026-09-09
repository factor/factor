! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cache kernel math math.vectors namespaces
opengl sequences ui.text ui.text.private windows.uniscribe ;
IN: ui.text.uniscribe

SINGLETON: uniscribe-renderer

M: uniscribe-renderer draws-selection-background? t ;

M: uniscribe-renderer string-dim
    cached-script-string size>> scale-dim ;

M: uniscribe-renderer flush-layout-cache
    cached-script-strings get-global purge-cache ;

M: uniscribe-renderer string>image
    cached-script-string
    [ script-string>image ] [ origin>> { 0 0 } or scale-dim vneg ] bi ;

M: uniscribe-renderer x>offset
    [ gl-scale ] 2dip cached-script-string x>line-offset + ;

M: uniscribe-renderer offset>x
    cached-script-string line-offset>x gl-unscale ;

M: uniscribe-renderer font-metrics
    " " cached-script-string metrics>> clone scale-metrics f >>width ;

M: uniscribe-renderer line-metrics
    cached-script-string metrics>> clone scale-metrics ;

uniscribe-renderer font-renderer set-global
