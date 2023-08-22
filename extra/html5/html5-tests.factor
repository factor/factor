! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: html5 kernel multiline tools.test ;
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



{ } [
[[ <!DOCTYPE html>
<html>
<head>
</head>

<body>
The content
</body>

</html>]] parse-html5 drop
] unit-test

