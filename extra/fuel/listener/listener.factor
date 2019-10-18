USING: kernel listener system vocabs ;
IN: fuel.listener

HOOK: fuel-pty-setup os ( -- )

M: object fuel-pty-setup ;

os linux? [ "fuel.listener.linux" require ] when

: fuel-listener ( -- )
    fuel-pty-setup listener-main ;

MAIN: fuel-listener
