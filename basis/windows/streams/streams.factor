USING: accessors alien.c-types alien.data classes.struct
combinators continuations io kernel libc literals locals
sequences specialized-arrays windows.com memoize
windows.com.wrapper windows.kernel32 windows.ole32
windows.types ;
IN: windows.streams

SPECIALIZED-ARRAY: uchar

<PRIVATE

: with-hresult ( quot: ( -- result ) -- result )
    [ drop E_FAIL ] recover ; inline

:: IStream-read ( stream pv cb out-read -- hresult )
    [
        cb stream stream-read :> buf
        buf length :> bytes
        pv buf bytes memcpy
        out-read [ bytes out-read 0 ULONG set-alien-value ] when

        cb bytes = [ S_OK ] [ S_FALSE ] if
    ] with-hresult ; inline

:: IStream-write ( stream pv cb out-written -- hresult )
    [
        pv cb uchar <c-direct-array> stream stream-write
        out-written [ cb out-written 0 ULONG set-alien-value ] when
        S_OK
    ] with-hresult ; inline

: origin>seek-type ( origin -- seek-type )
    {
        { $ STREAM_SEEK_SET [ seek-absolute ] }
        { $ STREAM_SEEK_CUR [ seek-relative ] }
        { $ STREAM_SEEK_END [ seek-end ] }
    } case ;

:: IStream-seek ( stream move origin new-position -- hresult )
    [
        move origin origin>seek-type stream stream-seek
        new-position [
            stream stream-tell new-position 0 ULARGE_INTEGER set-alien-value
        ] when
        S_OK
    ] with-hresult ; inline

:: IStream-set-size ( stream new-size -- hresult )
    STG_E_INVALIDFUNCTION ;

:: IStream-copy-to ( stream other-stream cb out-read out-written -- hresult )
    [
        cb stream stream-read :> buf
        buf length :> bytes
        out-read [ bytes out-read 0 ULONG set-alien-value ] when

        other-stream buf bytes out-written IStream::Write
    ] with-hresult ; inline

:: IStream-commit ( stream flags -- hresult )
    stream stream-flush S_OK ;

:: IStream-revert ( stream -- hresult )
    STG_E_INVALIDFUNCTION ;

:: IStream-lock-region ( stream offset cb lock-type -- hresult )
    STG_E_INVALIDFUNCTION ;

:: IStream-unlock-region ( stream offset cb lock-type -- hresult )
    STG_E_INVALIDFUNCTION ;

:: stream-size ( stream -- size )
    stream stream-tell :> old-pos
    0 seek-end stream stream-seek
    stream stream-tell :> size
    old-pos seek-absolute stream stream-seek
    size ;

:: IStream-stat ( stream out-stat stat-flag -- hresult )
    [
        out-stat
            f >>pwcsName
            STGTY_STREAM >>type
            stream stream-size >>cbSize
            FILETIME new >>mtime
            FILETIME new >>ctime
            FILETIME new >>atime
            STGM_READWRITE >>grfMode
            0 >>grfLocksSupported
            GUID_NULL >>clsid
            0 >>grfStateBits
            0 >>reserved
            drop
        S_OK
    ] with-hresult ;

:: IStream-clone ( stream out-clone-stream -- hresult )
    f out-clone-stream 0 void* set-alien-value
    STG_E_INVALIDFUNCTION ;

CONSTANT: stream-wrapper
    $[
        {
            { IStream {
                [ IStream-read ]
                [ IStream-write ]
                [ IStream-seek ]
                [ IStream-set-size ]
                [ IStream-copy-to ]
                [ IStream-commit ]
                [ IStream-revert ]
                [ IStream-lock-region ]
                [ IStream-unlock-region ]
                [ IStream-stat ]
                [ IStream-clone ]
            } }
        } <com-wrapper>
    ]

PRIVATE>

: stream>IStream ( stream -- IStream )
    stream-wrapper com-wrap ;
