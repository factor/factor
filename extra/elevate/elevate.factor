USING: accessors arrays assocs combinators command-line
environment formatting fry io.launcher kernel locals math
namespaces sequences splitting strings system ui vocabs ;
IN: elevate

<PRIVATE
ERROR: elevated-failed command { strategies array } ;
ERROR: lowered-failed ;

GENERIC#: prepend-command 1 ( command word -- word+command )
M: array prepend-command
    prefix ;

M: string prepend-command
    swap " " glue ;

GENERIC: failed-process? ( process -- ? )
M: f failed-process? not ;
M: fixnum failed-process? -1 = ;
M: process failed-process? status>> zero? not ;

PRIVATE>
HOOK: already-root? os ( -- ? )

HOOK: elevated os ( command replace? win-console? posix-graphical? -- process )
HOOK: lowered  os ( -- )

: elevate ( win-console? posix-graphical? -- ) [ (command-line) t ] 2dip elevated drop ;

os unix? [ "elevate.unix" require ] when

{
    { [ os windows? ] [ "elevate.windows" require ] }
    { [ os linux? ] [ "elevate.linux" require ] }
    { [ os macos? ] [ "elevate.macos" require ] }
} cond
