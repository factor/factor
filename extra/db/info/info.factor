USING: accessors sequences generalizations io.encodings.utf8 db.postgresql parser combinators vocabs.parser db.sqlite
io.files ;
IN: db.info
! having sensative (and likely to change) information directly in source code seems a bad idea
: get-info ( -- lines ) current-vocab name>> "vocab:" "/dbinfo.txt" surround utf8 file-lines ;
SYNTAX: get-psql-info <postgresql-db> get-info 5 firstn
    {
        [ >>host ]
        [ >>port ]
        [ >>username ]
        [ [ f ] [ ] if-empty >>password ]
        [ >>database ]
    } spread suffix! ;

SYNTAX: get-sqlite-info get-info first <sqlite-db> suffix! ;
