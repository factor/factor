" Vim indent file
" Language:	Factor
" Maintainer:	Giftpflanze <gifti@tools.wmflabs.org>
" Last Change:	2022 August 23

if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal indentexpr=GetFactorIndent(v:lnum)

let b:undo_indent = 'setlocal indentexpr<'

if exists("*GetFactorIndent")
	finish
endif

function! GetFactorIndent(lnum)
	let cline = getline(a:lnum)
	let pline = getline(a:lnum-1)
	let pind = indent(a:lnum-1)
	if pline =~ '^:'
		let pind += shiftwidth()
	endif
	if pline =~ ';$'
		let pind -= shiftwidth()
	endif
	if pline =~ '[{[]$'
		let pind += shiftwidth()
	endif
	if cline =~ '^\s*[\]}]'
		let pind -= shiftwidth()
	endif
	return pind
endfunction
