USING: accessors alien alien.c-types arrays classes.struct combinators
io.backend kernel locals math sequences specialized-arrays
tools.deploy.windows windows.kernel32 windows.types ;
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
    } cleave ] [ 1 + ] bi* group-directory-entry <struct-boa> >c-ptr ; inline

: ico-icon ( directory-entry bytes -- subbytes )
    [ [ ImageOffset>> dup ] [ ImageSize>> + ] bi ] dip subseq ; inline

:: ico-group-and-icons ( bytes -- group-bytes icon-bytes )
    bytes ico-header memory>struct :> header

    ico-header heap-size bytes <displaced-alien> 
    header ImageCount>> <direct-ico-directory-entry-array> :> directory

    directory dup length iota [ ico>group-directory-entry ] { } 2map-as
        :> group-directory
    directory [ bytes ico-icon ] { } map-as :> icon-bytes

    header clone >c-ptr group-directory concat append
    icon-bytes ; inline

PRIVATE>

:: embed-icon-resource ( exe ico-bytes id -- )
    exe normalize-path 1 BeginUpdateResource :> hUpdate
    hUpdate [
        ico-bytes ico-group-and-icons :> ( group icons )
        hUpdate RT_GROUP_ICON id 0 group dup byte-length
        UpdateResource drop

        icons [| icon i |
            hUpdate RT_ICON i 1 + MAKEINTRESOURCE 0 icon dup byte-length
            UpdateResource drop
        ] each-index

        hUpdate 0 EndUpdateResource drop
    ] when ;

