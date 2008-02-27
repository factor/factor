
USING: system combinators vocabs.loader ;

IN: unix.stat

{
  { [ linux? ] [ "unix.stat.linux" require ] }
  { [ t      ] [                           ] }
}
cond

