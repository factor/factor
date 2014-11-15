USING: python.syntax ;
IN: python.modules.sys

PY-FROM: sys =>
    path ( -- seq )
    argv ( -- seq )
    getrefcount ( obj -- n )
    platform ( -- x ) ;
