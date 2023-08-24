" Location:     plugin/factor.vim

nmap <silent> <Leader>fi :FactorVocabImpl<CR>
nmap <silent> <Leader>fd :FactorVocabDocs<CR>
nmap <silent> <Leader>ft :FactorVocabTests<CR>
nmap <Leader>fv :FactorVocab<SPACE>
nmap <Leader>fn :NewFactorVocab<SPACE>

if !exists('g:FactorResourcePath')
    let g:FactorResourcePath = '~/factor/'
endif

if !exists('g:FactorDefaultVocabRoots')
    let g:FactorDefaultVocabRoots = ['resource:core', 'resource:basis', 'resource:extra', 'resource:work']
endif
" let g:FactorAdditionalVocabRoots = ... " see autoload/factor.vim
unlet! g:FactorVocabRoots

if !exists('*FactorNewVocabRoot') | function! FactorNewVocabRoot() abort
    return 'resource:work'
endfunction | endif

command! -bar -bang -range=1 -nargs=1 -complete=customlist,factor#complete_vocab_glob FactorVocab
            \ execute factor#go_to_vocab_command(<count>,"edit<bang>",<q-args>)
command! -bar -bang -range=1 -nargs=1 -complete=customlist,factor#complete_vocab_glob NewFactorVocab
            \ execute factor#make_vocab_command(<count>,"edit<bang>",<q-args>)
command! -bar FactorVocabImpl :call GoToFactorVocabImpl()
command! -bar FactorVocabDocs :call GoToFactorVocabDocs()
command! -bar FactorVocabTests :call GoToFactorVocabTests()

function! FactorFileBase()
    let filename = expand('%:r')
    let filename = substitute(filename, '-docs', '', '')
    let filename = substitute(filename, '-tests', '', '')
    return filename
endfunction

function! GoToFactorVocabImpl()
    exe 'edit ' fnameescape(FactorFileBase() . '.factor')
endfunction

function! GoToFactorVocabDocs()
    exe 'edit ' fnameescape(FactorFileBase() . '-docs.factor')
endfunction

function! GoToFactorVocabTests()
    exe 'edit ' fnameescape(FactorFileBase() . '-tests.factor')
endfunction

" vim:sw=4:et:
