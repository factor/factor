USING: accessors calendar calendar.format io io.encodings.utf8
io.files kernel multiline sequences sorting splitting vocabs ;
IN: editors.vim.generate-syntax

<PRIVATE

CONSTANT: highlighted-vocabs {
    "alien"
    "arrays"
    "assocs"
    "byte-arrays"
    "classes"
    "classes.maybe"
    "combinators"
    "continuations"
    "definitions"
    "destructors"
    "generic"
    "growable"
    "io"
    "io.encodings"
    "io.encodings.binary"
    "io.encodings.utf8"
    "io.files"
    "kernel"
    "layouts"
    "make"
    "math"
    "math.order"
    "memory"
    "namespaces"
    "sequences"
    "sets"
    "sorting"
    "splitting"
    "strings"
    "strings.parser"
    "syntax"
    "vectors"
}

: (vocab-name>syntax-group-name) ( str -- str )
    "_" "___" "-" "__" "." "_" [ replace ] 2tri@ ;

: vocab-name>syntax-group-name ( str -- str )
    (vocab-name>syntax-group-name) "factorWord_" prepend ;

: write-syn-keyword ( str seq seq -- )
    "syn keyword " write [ write ] 2dip
    [ bl [ bl ] [ write ] interleave ] unless-empty
    [ bl [ bl ] [ "|" "\\|" replace write ] interleave ]
    unless-empty ;

: write-keywords ( vocab -- )
    lookup-vocab
    [ name>> ] [ vocab-words [ name>> ] map ] bi sort [
        [ vocab-name>syntax-group-name
            [ "SynKeywordFactorWord " write write " | " write ] keep
        ] dip
        { "contained" } write-syn-keyword nl
    ] [ drop ] if* ;

: (generate-vim-syntax) ( -- )
    [=[ " Vim syntax file
" Language: Factor
" Maintainer: Alex Chapman <chapman.alex@gmail.com>
" Last Change: ]=] write
    now-gmt { YYYY " " MONTH " " DD } formatted [=[
" Minimum Version: 600
" To regenerate: USE: editors.vim.generate-syntax generate-vim-syntax

if exists('b:factorsyn_no_generated')
  finish
endif

command -nargs=+ -bar HiLink hi def link <args>
function s:syn_keyword_factor_word(group, ...)
  execute 'HiLink' a:group 'factorWord'
  execute 'syn' 'cluster' 'factorWord' 'add=' . a:group
endfunction
command -nargs=+ -bar SynKeywordFactorWord
      \ call s:syn_keyword_factor_word(<f-args>)
]=] print

    highlighted-vocabs [ write-keywords ] each nl

    [=[ delcommand HiLink
delcommand SynKeywordFactorWord

let b:factor_syn_no_generated = 1

" vim:set ft=vim sw=2:]=] print ;

PRIVATE>

: generate-vim-syntax ( -- )
    "resource:misc/vim/syntax/factor/generated.vim"
    utf8 [ (generate-vim-syntax) ] with-file-writer ;

MAIN: generate-vim-syntax
