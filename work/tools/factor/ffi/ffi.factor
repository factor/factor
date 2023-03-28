! File: ffi.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2016 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: io kernel locals pcre regexp regexp.combinators sequences
splitting ;

IN: tools.factor.ffi

: ulonglongs ( str -- str )
    R/ my_ulonglong/ "ulonglong"  re-replace ;

: bools ( str -- str )
    R/ my_bool/ "bool" re-replace ;

: comments-in-line ( str -- str )
    R( \/\*.*\*\/) "" re-replace ;

: typedef-struct ( str -- str )
    R/ typedef\s+struct/ "STRUCT: " re-replace
    R/ \{\n/ "\n\n" re-replace ;

: const-struct ( str -- str )
    R/ const\s+struct/ "" re-replace ;
        
: unsigned-int ( str -- str )
    R/ unsigned\s+int/ "uint" re-replace ; 

: long-unsigned ( str -- str )
    R/ unsigned\s+long/ "ulong" re-replace ;

FROM: splitting => split ; 
: commas ( str -- str )
    ! does str contain a comma?
    dup R/ ,/ re-contains?
    [ ! yes, split by words, first item is type
        " " split 1 cut
      [ ! for each word, look for the comma
        "," split
        dup length 2 =
        [ ! found one if 2 items 
          1 cut drop ! get rid of the empty one
          ";\n" { } 1sequence  append ! tack on a `;' 
          over prepend ! add in the type
          " " join ! convert back to string
        ] [ ! no comma
            over prepend ! add in type
            " " join ! convert to string
        ] if
      ] map
      nip ! drop the type
      "\n" join ! convert to string
    ] when
    ;

: change-pointers ( seq -- seq ) 
    ! can only work with two
    dup  length 2 = 
    [
        ! look for pointer symbol `*' in second value
        [ second "*" split length  2 = ] keep
        swap  
        [ ! found one now move it to the first
          [ first "*" append ] keep
          ! remove it from second
          second "*" split  second
          ! reassemble
          " " append  { } 1sequence [ { } 1sequence ] dip  append
        ] when
    ] when ;

: string-trim-head ( str -- str )
    R/ ^\s+/ "" re-replace ;

: string-trim-tail ( str -- str )
    reverse  string-trim-head  reverse ;

: string-squeeze-spaces ( str -- str )
    ! squezze inside spaces to one
    R/ \s+/ " " re-replace
    ;

: string-trim ( str -- str )
    string-trim-head  string-trim-tail  string-squeeze-spaces ; 

! Lost the P/ word, in pcre, need to add to extensions
: convert-; ( str -- str )
    R/ \s+(\w+)\s+(\*)*(\w+);/ findall 
    [
        [ second ] keep
        [ third ] keep
        fourth
        second
        [ second ] dip
        [ second ] 2dip
        [ append ] dip
        swap { } 2sequence
        " " join  "{ "  " }\n" surround
    ] map
    "" swap [ append ] each
    ;

:: reorder-struct ( str -- str1 )
    ! split into lines
    V{ } :> newseq
    ! find the struct and save it
    str R/ STRUCT:\s+(\w+)/ findall
    ?first ?second ?second :> first_string
    ! find the end and save it
    str R/ }\s+(\w+);/ findall
    ?first ?second ?second :> last_string
    ! go thru lines and convert commas
    str string-lines
    [ string-trim 
      commas 
      "\n" append
      newseq push
      ] each
      ! convert seq to string
    "" newseq [ append ] each
    convert-;
    "STRUCT: " first_string append "\n" append
    prepend
    ";\nTYPEDEF: " first_string append  " " append  last_string append
    append
;

: demo ( -- str )
    "typedef struct st_mysql_res {
    my_ulonglong  row_count;
    MYSQL_FIELD	*fields;
    MYSQL_DATA	*data;
    MYSQL_ROWS	*data_cursor;
    unsigned long *lengths;		/* column lengths of current row */
    MYSQL		*handle;		/* for unbuffered reads */
    const struct st_mysql_methods *methods;
    MYSQL_ROW	row;			/* If unbuffered read */
    MYSQL_ROW	current_row;		/* buffer to current row */
    MEM_ROOT	field_alloc;
    unsigned int	field_count, current_field;
    my_bool	eof;			/* Used by mysql_fetch_row */
    /* mysql_stmt_close() had to cancel this result */
    my_bool       unbuffered_fetch_cancelled;  
    void *extension;
    } MYSQL_RES;"
;

: demo1 ( -- str )
    "typedef struct st_mysql_res {
    unsigned int	field_count, current_field;
"
;

: convert ( str -- str )
    typedef-struct
    comments-in-line
    ulonglongs
    const-struct
    unsigned-int
    long-unsigned
    bools
    reorder-struct
    ;

: convert-clipboard ( x x -- )
    clipboard-contents
    convert
    set-clipboard-contents
    ;

: convert-test ( -- )   demo convert print ;
