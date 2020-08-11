! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: multiline tools.test html5 ;
IN: html5.tests

![===[
{ } [ "&" parse-html5 ] unit-test


[[ <!DOCTYPE html>
<html>
<head>
<title>Title</title>
</head>

<body>
The content
</body>

</html>]] parse-html5


]===]