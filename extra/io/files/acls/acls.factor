! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: ;
IN: acls

! File and directory permissions
SYMBOLS: +delete+ +readattr+ +writeattr+ +readextattr+ +writeextattr+
+read-security+ +write-security+ +chown+ ;

! Directory permissions
SYMBOLS: +list+ +search+ +add-directory+ +delete-child+ ;

! Non-directory permissions
SYMBOLS: +read+ +write+ +append+ +execute+ ;

! Directory inheritance
SYMBOLS: +file-inherit+ +directory-inherit+ +limit-inherit+ only-inherit+ ;


