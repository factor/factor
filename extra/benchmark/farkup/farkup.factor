USING: farkup fry io.encodings.utf8 io.files kernel math
sequences ;
IN: benchmark.farkup

: farkup-benchmark ( -- )
    100
    "vocab:webapps/wiki/initial-content/Farkup.txt"
    utf8 file-contents
    '[ _ convert-farkup length 5300 assert= ] times ;
