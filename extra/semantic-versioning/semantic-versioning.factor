! Copyright (C) 2010 Maximilian Lupke.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ascii kernel math.parser sequences splitting ;
IN: semantic-versioning

: split-version ( string -- array )
    "." split first3 dup [ digit? not ] find
    [ cut [ [ string>number ] tri@ ] dip 4array ]
    [ drop [ string>number ] tri@ 3array ]
    if ;
