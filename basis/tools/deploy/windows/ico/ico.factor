USING: accessors alien alien.data alien.c-types classes.struct
combinators io.backend kernel locals
math sequences specialized-arrays splitting
windows.kernel32 windows.types ;
IN: tools.deploy.windows.ico

<PRIVATE

STRUCT: ico-header
    { Reserved WORD }
    { Type WORD }
    { ImageCount WORD } ;

STRUCT: ico-directory-entry
    { Width        BYTE  }
    { Height       BYTE  }
    { Colors       BYTE  }
    { Reserved     BYTE  }
    { Planes       WORD  }
    { BitsPerPixel WORD  }
    { ImageSize    DWORD }
    { ImageOffset  DWORD } ;
SPECIALIZED-ARRAY: ico-directory-entry

STRUCT: group-directory-entry
    { Width        BYTE  }
    { Height       BYTE  }
    { Colors       BYTE  }
    { Reserved     BYTE  }
    { Planes       WORD  }
    { BitsPerPixel WORD  }
    { ImageSize    DWORD }
    { ImageResourceID WORD } ;

: ico>group-directory-entry ( ico i -- group )
    [ {
        [ Width>> ] [ Height>> ] [ Colors>> ] [ Reserved>> ]
        [ Planes>> ] [ BitsPerPixel>> ] [ ImageSize>> ]
    } cleave ] [ 1 + ] bi* group-directory-entry boa >c-ptr ; inline

: ico-icon ( directory-entry bytes -- subbytes )
    [ [ ImageOffset>> dup ] [ ImageSize>> + ] bi ] dip subseq ; inline

:: ico-group-and-icons ( bytes -- group-bytes icon-bytes )
    bytes ico-header memory>struct :> header

    ico-header heap-size bytes <displaced-alien>
    header ImageCount>> ico-directory-entry <c-direct-array> :> directory

    directory dup length <iota> [ ico>group-directory-entry ] { } 2map-as
        :> group-directory
    directory [ bytes ico-icon ] { } map-as :> icon-bytes

    header clone >c-ptr group-directory concat append
    icon-bytes ; inline

ERROR: unsupported-ico-format bytes format ;

: check-ico-type ( bytes -- bytes )
    dup "PNG" head? [
        "PNG" unsupported-ico-format
    ] when
    dup B{ 0 0 } head? [
        "UNKNOWN" unsupported-ico-format
    ] unless ;

PRIVATE>

:: embed-icon-resource ( exe ico-bytes id -- )
    exe normalize-path 1 BeginUpdateResource :> hUpdate
    hUpdate [
        ico-bytes check-ico-type ico-group-and-icons :> ( group icons )
        hUpdate RT_GROUP_ICON id 0 group dup byte-length
        UpdateResource drop

        icons [| icon i |
            hUpdate RT_ICON i 1 + MAKEINTRESOURCE 0 icon dup byte-length
            UpdateResource drop
        ] each-index

        hUpdate 0 EndUpdateResource drop
    ] when ;
