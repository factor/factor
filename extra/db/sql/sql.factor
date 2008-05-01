USING: kernel parser quotations classes.tuple words math.order
namespaces.lib namespaces sequences arrays combinators
prettyprint strings math.parser sequences.lib math symbols ;
IN: db.sql

SYMBOLS: insert update delete select distinct columns from as
where group-by having order-by limit offset is-null desc all
any count avg table values ;

: input-spec, 1, ;
: output-spec, 2, ;
: input, 3, ;
: output, 4, ;

DEFER: sql%

: (sql-interleave) ( seq sep -- )
    [ sql% ] curry [ sql% ] interleave ;

: sql-interleave ( seq str sep -- )
    swap sql% (sql-interleave) ;

: sql-function, ( seq function -- )
    sql% "(" sql% unclip sql% ")" sql% [ sql% ] each ;

: sql-array% ( array -- )
    unclip
    {
        { \ columns [ "," (sql-interleave) ] }
        { \ from [ "from" "," sql-interleave ] }
        { \ where [ "where" "and" sql-interleave ] }
        { \ group-by [ "group by" "," sql-interleave ] }
        { \ having [ "having" "," sql-interleave ] }
        { \ order-by [ "order by" "," sql-interleave ] }
        { \ offset [ "offset" sql% sql% ] }
        { \ limit [ "limit" sql% sql% ] }
        { \ select [ "(select" sql% sql% ")" sql% ] }
        { \ table [ sql% ] }
        { \ set [ "set" "," sql-interleave ] }
        { \ values [ "values(" sql% "," (sql-interleave) ")" sql% ] }
        { \ count [ "count" sql-function, ] }
        { \ sum [ "sum" sql-function, ] }
        { \ avg [ "avg" sql-function, ] }
        { \ min [ "min" sql-function, ] }
        { \ max [ "max" sql-function, ] }
        [ sql% [ sql% ] each ]
    } case ;

ERROR: no-sql-match ;
: sql% ( obj -- )
    {
        { [ dup string? ] [ " " 0% 0% ] }
        { [ dup array? ] [ sql-array% ] }
        { [ dup number? ] [ number>string sql% ] }
        { [ dup symbol? ] [ unparse sql% ] }
        { [ dup word? ] [ unparse sql% ] }
        { [ dup quotation? ] [ call ] }
        [ no-sql-match ]
    } cond ;

: parse-sql ( obj -- sql in-spec out-spec in out )
    [
        unclip {
            { \ create [ "create table" sql% ] }
            { \ drop [ "drop table" sql% ] }
            { \ insert [ "insert into" sql% ] }
            { \ update [ "update" sql% ] }
            { \ delete [ "delete" sql% ] }
            { \ select [ "select" sql% ] }
        } case [ sql% ] each
    ] { "" { } { } { } { } } nmake ;
