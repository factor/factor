USING: accessors alien.c-types arrays calendar classes.struct
destructors file-picker.windows file-picker.windows.private kernel
io io.encodings.utf8 io.launcher math sequences system tools.test
windows.comdlg32 ;
IN: file-picker.windows.tests

! A selected Unicode filename must remain a Factor string after native
! buffers are freed. The suggestion is also encoded in the dialog buffer.
{ "日本😀.txt" "C:\\tmp\\" } [
    [
        "C:\\tmp\\日本😀.txt" OFN_OVERWRITEPROMPT <file-dialog>
        [ t file-dialog-result ] [ lpstrInitialDir>> ] bi
    ] with-destructors
] unit-test

! OPENFILENAME includes the modern reserved fields on both architectures.
{ t t t } [
    [
        "" OFN_FILEMUSTEXIST <file-dialog>
        [ lStructSize>> cpu x86.32? 88 152 ? = ]
        [ nMaxFile>> 32768 = ]
        [ lpstrFile>> "" = ] tri
    ] with-destructors
] unit-test

! Real native failures must propagate instead of masquerading as Cancel.
! Invalid structure sizes fail before Windows opens a dialog.
[
    [
        "" OFN_OVERWRITEPROMPT <file-dialog> 0 >>lStructSize
        dup GetSaveFileName zero? not file-dialog-result
    ] with-destructors
] [ dup file-dialog-error? [ code>> 1 = ] [ drop f ] if ] must-fail-with

! Isolate modal dialogs and their callbacks; a failure must time out rather
! than strand the test runner. The child verifies Unicode Open/Save and Cancel.
{ t } [
    <process>
        vm-path "-no-user-init"
        "resource:extra/file-picker/windows/fixtures/dialog.factor" 3array >>command
        t >>hidden 30 seconds >>timeout
        +closed+ >>stdin +stdout+ >>stderr
    utf8 [ read-contents ] with-process-reader*
    0 = [ drop "FILE-PICKER-PASS" subseq-of? ] [ output-process-error ] if
] unit-test

[
    [
        "" OFN_FILEMUSTEXIST <file-dialog> 0 >>lStructSize
        dup GetOpenFileName zero? not file-dialog-result
    ] with-destructors
] [ dup file-dialog-error? [ code>> 1 = ] [ drop f ] if ] must-fail-with
