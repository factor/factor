USING: kernel parser quotations classes.tuple words math.order
nmake namespaces sequences arrays combinators
prettyprint strings math.parser math symbols db ;
IN: db.sql

SYMBOLS: insert update delete select distinct columns from as
where group-by having order-by limit offset is-null desc all
any count avg table values ;

: input-spec, ( obj -- ) 1, ;
: output-spec, ( obj -- ) 2, ;
: input, ( obj -- ) 3, ;
: output, ( obj -- ) 4, ;

DEFER: sql%

: (sql-interleave) ( seq sep -- )
    [ sql% ] curry [ sql% ] interleave ;

: sql-interleave ( seq str sep -- )
    swap sql% (sql-interleave) ;

: sql-function, ( seq function -- )
    sql% "(" sql% unclip sql% ")" sql% [ sql% ] each ;

: sql-where, ( seq -- )
    [
        [ second 0, ]
        [ first 0, ]
        [ third 1, \ ? 0, ] tri
    ] each ;

USE: multiline
HOOK: sql-create db ( object -- )
M: db sql-create ( object -- )
    drop
    "create table" sql% ;

HOOK: sql-drop db ( object -- )
M: db sql-drop ( object -- )
    drop
    "drop table" sql% ;

HOOK: sql-insert db ( object -- )
M: db sql-insert ( object -- )
    drop
    "insert into" sql% ;

HOOK: sql-update db ( object -- )
M: db sql-update ( object -- )
    drop
    "update" sql% ;

HOOK: sql-delete db ( object -- )
M: db sql-delete ( object -- )
    drop
    "delete" sql% ;

HOOK: sql-select db ( object -- )
M: db sql-select ( object -- )
    "select" sql% "," (sql-interleave) ;

HOOK: sql-columns db ( object -- )
M: db sql-columns ( object -- )
    "," (sql-interleave) ;

HOOK: sql-from db ( object -- )
M: db sql-from ( object -- )
    "from" "," sql-interleave ;

HOOK: sql-where db ( object -- )
M: db sql-where ( object -- )
    "where" 0, sql-where, ;

HOOK: sql-group-by db ( object -- )
M: db sql-group-by ( object -- )
    "group by" "," sql-interleave ;

HOOK: sql-having db ( object -- )
M: db sql-having ( object -- )
    "having" "," sql-interleave ;

HOOK: sql-order-by db ( object -- )
M: db sql-order-by ( object -- )
    "order by" "," sql-interleave ;

HOOK: sql-offset db ( object -- )
M: db sql-offset ( object -- )
    "offset" sql% sql% ;

HOOK: sql-limit db ( object -- )
M: db sql-limit ( object -- )
    "limit" sql% sql% ;

! GENERIC: sql-subselect db ( object -- )
! M: db sql-subselectselect ( object -- )
    ! "(select" sql% sql% ")" sql% ;

GENERIC: sql-table db ( object -- )
M: db sql-table ( object -- )
    sql% ;

GENERIC: sql-set db ( object -- )
M: db sql-set ( object -- )
    "set" "," sql-interleave ;

GENERIC: sql-values db ( object -- )
M: db sql-values ( object -- )
    "values(" sql% "," (sql-interleave) ")" sql% ;

GENERIC: sql-count db ( object -- )
M: db sql-count ( object -- )
    "count" sql-function, ;

GENERIC: sql-sum db ( object -- )
M: db sql-sum ( object -- )
    "sum" sql-function, ;

GENERIC: sql-avg db ( object -- )
M: db sql-avg ( object -- )
    "avg" sql-function, ;

GENERIC: sql-min db ( object -- )
M: db sql-min ( object -- )
    "min" sql-function, ;

GENERIC: sql-max db ( object -- )
M: db sql-max ( object -- )
    "max" sql-function, ;

/*
: sql-array% ( array -- )
    unclip
    {
        { \ create [ sql-create ] }
        { \ drop [ sql-drop ] }
        { \ insert [ sql-insert ] }
        { \ update [ sql-update ] }
        { \ delete [ sql-delete ] }
        { \ select [ sql-select ] }
        { \ columns [ sql-columns ] }
        { \ from [ sql-from ] }
        { \ where [ sql-where ] }
        { \ group-by [ sql-group-by ] }
        { \ having [ sql-having ] }
        { \ order-by [ sql-order-by ] }
        { \ offset [ sql-offset ] }
        { \ limit [ sql-limit ] }
        { \ table [ sql-table ] }
        { \ set [ sql-set ] }
        { \ values [ sql-values ] }
        { \ count [ sql-count ] }
        { \ sum [ sql-sum ] }
        { \ avg [ sql-avg ] }
        { \ min [ sql-min ] }
        { \ max [ sql-max ] }
        [ sql% [ sql% ] each ]
    } case ;
*/

: sql-array% ( array -- ) drop ;
ERROR: no-sql-match ;
: sql% ( obj -- )
    {
        { [ dup string? ] [ 0, ] }
        { [ dup array? ] [ sql-array% ] }
        { [ dup number? ] [ number>string sql% ] }
        { [ dup symbol? ] [ unparse sql% ] }
        { [ dup word? ] [ unparse sql% ] }
        { [ dup quotation? ] [ call ] }
        [ no-sql-match ]
    } cond ;

: parse-sql ( obj -- sql in-spec out-spec in out )
    [ [ sql% ] each ] { { } { } { } } nmake
    [ " " join ] 2dip ;
