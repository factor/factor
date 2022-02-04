USING: kernel listener system vocabs vocabs.platforms ;
IN: fuel.listener

HOOK: fuel-pty-setup os ( -- )

M: object fuel-pty-setup ;

USE-LINUX: fuel.listener.linux

: fuel-listener ( -- )
    fuel-pty-setup listener-main ;

MAIN: fuel-listener
