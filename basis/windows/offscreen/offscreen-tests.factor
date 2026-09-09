USING: alien.syntax continuations effects images kernel locals math
tools.test windows.gdi32 windows.kernel32 windows.offscreen windows.types ;
IN: windows.offscreen.tests

LIBRARY: gdi32
FUNCTION: HGDIOBJ GetCurrentObject ( HDC dc, UINT type )
LIBRARY: user32
FUNCTION: DWORD GetGuiResources ( HANDLE process, DWORD flags )

{ 1 1 } [ [ [ ] make-bitmap-image ] with-memory-dc ] must-infer-as
{ t } [ [ { 10 10 } swap [ ] make-bitmap-image ] with-memory-dc image? ] unit-test

ERROR: offscreen-draw-failed ;

:: bitmap-ownership ( fail? -- restored? released? )
    [ :> dc
        dc OBJ_BITMAP GetCurrentObject :> previous
        GetCurrentProcess 0 GetGuiResources :> before
        30 [
            [ { 16 16 } dc [ fail? [ offscreen-draw-failed ] when ]
                make-bitmap-image drop ]
            [ dup offscreen-draw-failed? [ drop ] [ rethrow ] if ] recover
        ] times
        previous dc OBJ_BITMAP GetCurrentObject =
        before GetCurrentProcess 0 GetGuiResources =
    ] with-memory-dc ;

! Each image restores the old bitmap and frees its DIB immediately, even
! when several renders share a DC or drawing throws an exception.
{ t t } [ f bitmap-ownership ] unit-test
{ t t } [ t bitmap-ownership ] unit-test

:: failed-selection-releases-bitmap? ( -- ? )
    GetCurrentProcess 0 GetGuiResources :> before
    [ { 16 16 } f [ ] make-bitmap-image drop ] [ drop ] recover
    before GetCurrentProcess 0 GetGuiResources = ;
{ t } [ failed-selection-releases-bitmap? ] unit-test
[ { 16 16 } f [ ] make-bitmap-image drop ] must-fail
