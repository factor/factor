! Copyright (C) 2014 John Benediktsson, Doug Coleman.
! Copyright (C) 2017 Alexander Ilin, 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings classes.struct
destructors file-picker io.backend io.encodings.string io.encodings.utf16
io.files.windows io.pathnames kernel libc
literals locals math math.order sequences system windows.comdlg32 ;
IN: file-picker.windows

<PRIVATE

ERROR: file-dialog-error code ;

:: <file-dialog> ( path flags -- dialog )
    path empty? [ path ] [ path normalize-path remove-unicode-prefix ] if
    :> initial-path
    initial-path empty? [ initial-path ] [ initial-path file-name ] if
    native-string>alien :> initial
    ! Windows capacities count UTF-16 code units, including the terminator.
    initial length 2 /i 32768 max :> capacity
    capacity 2 calloc &free :> buffer
    buffer initial initial length memcpy
    OPENFILENAME malloc-struct &free
        OPENFILENAME heap-size >>lStructSize
        buffer >>lpstrFile capacity >>nMaxFile
        "All files\0*.*\0\0" utf16n encode malloc-byte-array &free >>lpstrFilter
        flags flags{ OFN_EXPLORER OFN_NOCHANGEDIR OFN_PATHMUSTEXIST } bitor >>Flags :> dialog
    initial-path empty? [
        dialog initial-path parent-directory native-string>alien
        malloc-byte-array &free >>lpstrInitialDir drop
    ] unless
    dialog ;

: file-dialog-result ( dialog succeeded? -- path/f )
    [
        ! Copy while the native filename buffer is still alive.
        lpstrFile>>
    ] [
        drop CommDlgExtendedError dup zero?
        [ drop f ] [ file-dialog-error ] if
    ] if ;

PRIVATE>

M: windows open-file-dialog
    [
        "" OFN_FILEMUSTEXIST <file-dialog>
        dup GetOpenFileName zero? not file-dialog-result
    ] with-destructors ;

M: windows save-file-dialog
    [
        OFN_OVERWRITEPROMPT <file-dialog>
        dup GetSaveFileName zero? not file-dialog-result
    ] with-destructors ;
