! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays file-picker io io.encodings.binary io.files
kernel ui.commands ui.operations ;
IN: file-picker.operations

: save-as ( seq -- )
    "" save-file-dialog [ binary set-file-contents ] [ drop ] if* ;

! Right-click a byte-array presentation to open the Save As window.
[ byte-array? ] \ save-as H{
    { +description+ "Save the binary data to a file" }
} define-operation
