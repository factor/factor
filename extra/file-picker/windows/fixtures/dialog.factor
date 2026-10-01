USING: parser ;
<<
"resource:extra/windows/comdlg32/comdlg32.factor" run-file
"resource:extra/file-picker/windows/windows.factor" run-file
>>
USING: accessors alien.c-types alien.syntax destructors file-picker.windows
file-picker.windows.private io io.backend io.directories io.files io.files.temp io.files.windows
io.pathnames kernel locals math namespaces tools.test windows.comdlg32
windows.messages windows.types windows.user32 ;
IN: file-picker.windows.fixture

LIBRARY: user32
FUNCTION: BOOL PostMessageW ( HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam )
FUNCTION: UINT_PTR SetTimer ( HWND hwnd, UINT_PTR id, UINT interval, void* callback )
CALLBACK: ULONG_PTR file-dialog-hook ( HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam )

SYMBOL: dialog-button

:: automate-dialog ( hwnd msg wParam lParam -- result )
    msg WM_INITDIALOG = [
        ! Keep the test window offscreen. Retry the click while the shell
        ! initializes the folder; destroying the dialog also removes its timer.
        hwnd GetParent f -32000 -32000 0 0
        SWP_NOSIZE SWP_NOZORDER bitor SWP_NOACTIVATE bitor SetWindowPos drop
        hwnd 1 500 f SetTimer drop
    ] when
    msg WM_TIMER = [
        hwnd GetParent dialog-button get-global GetDlgItem
        0xF5 0 0 PostMessageW drop ! BM_CLICK
    ] when
    0 ;

:: automated-file-dialog ( path flags button quot: ( dialog -- result ) -- path/f )
    button dialog-button set-global
    [
        path flags <file-dialog> [ 0x20 bitor ] change-Flags ! OFN_ENABLEHOOK
        [ automate-dialog ] file-dialog-hook >>lpfnHook
        dup quot call zero? not file-dialog-result
    ] with-destructors ; inline

: check-file-dialogs ( -- )
    [ [let
        "selected-日本😀.txt" normalize-path remove-unicode-prefix :> path
        path OFN_OVERWRITEPROMPT 1 [ GetSaveFileName ] automated-file-dialog
        path assert=
        path touch-file
        path OFN_FILEMUSTEXIST 1 [ GetOpenFileName ] automated-file-dialog
        path assert=
        path OFN_OVERWRITEPROMPT 2 [ GetSaveFileName ] automated-file-dialog
        f assert=
        path OFN_FILEMUSTEXIST 2 [ GetOpenFileName ] automated-file-dialog
        f assert=
        "FILE-PICKER-PASS" print
    ] ] with-test-directory ;

check-file-dialogs
