USING: editors editors.vim io.pathnames io.standard-paths kernel
namespaces ;
IN: editors.macvim

SINGLETON: macvim

INSTANCE: macvim vim-base

: find-macvim-bundle-path ( -- path/f )
    "org.vim.MacVim" find-native-bundle [
        "Contents/MacOS/Vim" append-path
    ] [
        f
    ] if* ;

M: macvim find-vim-path find-macvim-bundle-path ;

M: macvim vim-ui? t ;

M: macvim editor-detached? t ;
