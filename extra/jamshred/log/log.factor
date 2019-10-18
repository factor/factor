USING: kernel logging ;
IN: jamshred.log

LOG: (jamshred-log) DEBUG

: with-jamshred-log ( quot -- )
    "jamshred" swap with-logging ; inline

: jamshred-log ( message -- )
    [ (jamshred-log) ] with-jamshred-log ; ! ugly...
