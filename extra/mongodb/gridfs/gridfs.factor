USING: accessors arrays assocs base64 bson.constants
byte-arrays byte-vectors calendar combinators
combinators.short-circuit destructors formatting fry hashtables
io kernel linked-assocs locals math math.parser mongodb.cmd
mongodb.connection mongodb.driver mongodb.msg namespaces
sequences splitting strings ;
FROM: mongodb.driver => update ;
IN: mongodb.gridfs

CONSTANT: default-chunk-size 262144

TUPLE: gridfs 
    { bucket string } 
    { files string }
    { chunks string } ;


<PRIVATE

: gridfs> ( -- gridfs )
    gridfs get ; inline

: files-collection ( -- str ) gridfs> files>> ; inline
: chunks-collection ( -- str ) gridfs> chunks>> ; inline


: init-gridfs ( gridfs -- )
    chunks>> "ChunkIdx" H{ { "files_id" 1 } { "n" 1 } } 
    <index-spec> ensure-index ; inline

PRIVATE>

: <gridfs> ( bucket -- gridfs )
    [  ] 
    [ "files" "%s.%s" sprintf  ] 
    [ "chunks" "%s.%s" sprintf ] tri
    gridfs boa [ init-gridfs ] keep ;

: with-gridfs ( gridfs quot -- * )
    [ gridfs ] dip with-variable ; inline

TUPLE: entry 
    { id oid }
    { filename string }
    { content-type string }
    { length integer }
    { chunk-size integer }
    { created timestamp }
    { aliases array }
    { metadata hashtable }
    { md5 string } ;

<PRIVATE

: id>base64 ( id -- str )
    [ a>> >hex ] [ b>> >hex ] bi 
    2array "#" join >base64 >string ; inline

: base64>id ( str -- objid )
    base64> >string "#" split 
    [ first ] [ second ] bi 
    [ hex> ] bi@ oid boa ; inline
    
PRIVATE>

: <entry> ( name content-type -- entry )
    entry new 
    swap >>content-type swap >>filename 
    <oid> >>id 0 >>length default-chunk-size >>chunk-size 
    now >>created ; inline

<PRIVATE 

TUPLE: chunk 
    { id oid }
    { fileid oid }
    { n integer }
    { data byte-array } ;

: at> ( assoc key -- value/f )
    swap at ; inline

:: >set-at ( assoc value key -- )
    value key assoc set-at ; inline

: (update-file) ( entry assoc -- entry )
    { 
        [ "_id" at> >>id ]
        [ "filename" at> >>filename ]
        [ "contentType" at> >>content-type ]
        [ "length" at> >>length ]
        [ "chunkSize" at> >>chunk-size ]
        [ "uploadDate" at> >>created ]
        [ "aliases" at> >>aliases ]
        [ "metadata" at> >>metadata ]
        [ "md5" at> >>md5 ]
    } cleave ; inline

: assoc>chunk ( assoc -- chunk )
    [ chunk new ] dip
    {  
        [ "_id" at> >>id ]
        [ "files_id" at> >>fileid ]
        [ "n" at> >>n ]
        [ "data" at> >>data ]
    } cleave ;

: assoc>entry ( assoc -- entry )
    [ entry new ] dip (update-file) ;
    
: entry>assoc ( entry -- assoc )
    [ H{  } clone ] dip
    {
        [ id>> "_id" >set-at ]
        [ filename>> "filename" >set-at ]
        [ content-type>> "contentType" >set-at ]
        [ length>> "length" >set-at ]
        [ chunk-size>> "chunkSize" >set-at ]
        [ created>> "uploadDate" >set-at ]
        [ aliases>> "aliases" >set-at ]
        [ metadata>> "metadata" >set-at ]
        [ md5>> "md5" >set-at ]
        [ drop ]
    } 2cleave ; inline

: create-entry ( entry -- entry )
    [ [ files-collection ] dip entry>assoc save ] [ ] bi ;

TUPLE: state bytes count ;

: <state> ( -- state )
    0 0 state boa ; inline

: get-state ( -- n )
    state get ; inline

: with-state ( quot -- state )
    [ <state> state ] dip 
    [ get-state ] compose 
    with-variable ; inline

: update-state ( bytes -- )
    [ get-state ] dip
    '[ _ + ] change-bytes 
    [ 1 + ] change-count drop ; inline

:: store-chunk ( chunk entry n -- ) 
    entry id>> :> id
    H{ { "files_id" id }
       { "n" n } { "data" chunk } }
    [ chunks-collection ] dip save ; inline

:: write-chunks ( stream entry -- length )
    entry chunk-size>> :> chunk-size
    [
        [ 
            chunk-size stream stream-read dup [
                [ entry get-state count>> store-chunk ]
                [ length update-state ] bi 
            ] when*
        ] loop
    ] with-state bytes>> ;

: (entry-selector) ( entry -- selector )
    id>> "_id" associate ; inline

:: file-md5 ( id -- md5-str )
    filemd5-cmd make-cmd
    id "filemd5" set-cmd-opt
    gridfs> bucket>> "root" set-cmd-opt
    send-cmd "md5" at> ; inline

: update-entry ( bytes entry -- entry )
    [ swap >>length dup id>> file-md5 >>md5  ]
    [ nip [ (entry-selector) ] [  ] bi
        [ length>> "length" associate "$set" associate 
          [ files-collection ] 2dip <update> update ]
        [ md5>> "md5" associate "$set" associate 
          [ files-collection ] 2dip <update> update ] 2bi 
    ] 2bi ;

TUPLE: gridfs-input-stream entry chunk n offset cpos ;

: <gridfs-input-stream> ( entry -- stream )
    [ gridfs-input-stream new ] dip
    >>entry 0 >>offset 0 >>cpos -1 >>n ;

PRIVATE>

: write-entry ( input-stream entry -- entry )
    create-entry [ write-chunks ] keep update-entry  ;

: get-entry ( id -- entry )
    [ files-collection ] dip
    "_id" associate <query> find-one assoc>entry ;

: open-entry ( entry -- input-stream )
    <gridfs-input-stream> ;

: entry-contents ( entry -- bytearray )
    <gridfs-input-stream> stream-contents ;

<PRIVATE

: load-chunk ( stream -- chunk/f )
    [ entry>> id>> "files_id" associate ]
    [ n>> "n" associate ] bi assoc-union
    [ chunks-collection ] dip 
    <query> find-one dup [ assoc>chunk ] when ;

: exhausted? ( stream -- boolean )
    [ offset>> ] [ entry>> length>> ] bi = ; inline

: fresh? ( stream -- boolean )
    [ offset>> 0 = ] [ chunk>> f = ] bi and ; inline

: data-available ( stream -- int/f )
    [ cpos>> ] [ chunk>> data>> length ] bi 
    2dup < [ swap - ] [ 2drop f ] if ; inline

: next-chunk ( stream -- available chunk/f )
    0 >>cpos [ 1 + ] change-n
    [  ] [ load-chunk ] bi >>chunk
    [ data-available ] [ chunk>> ] bi ; inline

: ?chunk ( stream -- available chunk/f )
    dup fresh? [ next-chunk ] [ 
        dup exhausted? [ drop 0 f ] [  
            dup data-available [ swap chunk>> ] [ next-chunk ] if*
        ] if
    ] if ; inline

: set-stream ( n stream -- )
    swap { 
        [ >>offset drop ]
        [ over entry>> chunk-size>> /mod [ >>n ] [ >>cpos ] bi* drop ]
        [ drop dup load-chunk >>chunk drop ]
    } 2cleave ; inline

:: advance-stream ( n stream -- )
    stream [ n + ] change-cpos [ n + ] change-offset drop ; inline

: read-part ( n stream chunk -- seq/f )
    [ [ cpos>> swap [ drop ] [ + ] 2bi ] [ data>> ] bi* <slice> ]
    [ drop advance-stream ] 3bi ; inline

:: (stream-read-partial) ( n stream -- seq/f )
    stream ?chunk :> chunk :> available
    chunk [
        n available < 
        [ n ] [ available ] if 
        stream chunk read-part 
    ] [ f ] if ; inline

:: (stream-read) ( n stream acc -- )
    n stream (stream-read-partial)
    {
        { [ dup not ] [ drop ] }
        { [ dup length n = ] [ acc push-all ] }
        { [ dup length n < ] [
            [ acc push-all ] [ length ] bi
            n swap - stream acc (stream-read) ]
        }
    } cond ; inline recursive 

PRIVATE>

M: gridfs-input-stream stream-element-type drop +byte+ ;

M: gridfs-input-stream stream-read ( n stream -- seq/f )
    over <byte-vector> [ (stream-read) ] [ ] bi
    dup empty? [ drop f ] [ >byte-array ] if ;

M: gridfs-input-stream stream-read-partial ( n stream -- seq/f )
    (stream-read-partial) ;

M: gridfs-input-stream stream-tell ( stream -- n ) 
    offset>> ;

M: gridfs-input-stream stream-seek ( n seek-type stream -- )
    swap seek-absolute = 
    [ set-stream ] 
    [ "seek-type not supported" throw ] if ;

M: gridfs-input-stream dispose drop ;
