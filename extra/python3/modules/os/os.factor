USING: python.syntax ;
IN: python.modules.os

PY-FROM: os =>
    getpid ( -- y )
    system ( x -- y ) ;
