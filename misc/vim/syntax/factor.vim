" Vim syntax file
" Language: Factor
" Maintainer: Alex Chapman <chapman.alex@gmail.com>
" Last Change: 2020 Jun 05
" Minimum Version: 600

" Factor |syntax| file guide & conventions:
"
" Inside |:comment|s, words in |bars| contain |:help| keywords.
"   |K| looks these up.
"
" Alignment columns should normally occur on multiples of 4.
" Align Vim syntax alternatives naturally. E.g.:
"   "syn match   ..."
"   "syn cluster ..."
"   "syn region  ..."
" Align |:syn-start|, |:syn-skip|, and |:syn-end| on their patterns.
" ":echo (col('.') - 1) % 4" is handy here.
"
" All syntax patterns (|:syn-pattern|) are "very magic" (|/\v|).
" Escape all literal [^0-9a-zA-Z_-!:;] characters in these patterns.
" (Not escaping [-!:;] characters risks forward-incompatibility,
"   but fixes if an incompatibile Vim arises would be trivial,
"   and Factor likes these characters.)
"
" Syntax groups ending in "Error" match errors via |:syn-priority|,
"   and should normally |:hi-link| to "Error".
"
" Syntax groups named "{group-name}Trans" are |:syn-transparent|.
"
" |:syn-cluster|s named "{group-name}" mean to allow |:syn-contains| use of
"   |:syn-priority|-based error-detection.
" This still applies to clusters named "{group-name}Trans".
"
" Syntax groups "{group-name}Skip" have the form:
" "syn match {group-name}Skip /\v%(\_\s+%(!>.*)?)*/ nextgroup={group-name} transparent contained"
" Specifying "nextgroup={group-name}Skip" works like a Factor-aware
"   "nextgroup={group-name} skipwhite skipempty"
"   with required initial space (not optional).
" "{cluster-name}Skip" works similarly, but with "nextgroup=@{cluster-name}".
"
" Vim's syntax highlighting freaks at paired "/\v\(" and "/\v\)". ☹
" Switching into very nomagic (with "/\V(\v/" or "/\V)\v") averts that,
"   as non-escaped parentheses don't extend pattern regions.

if exists('b:current_syntax')
  finish
endif

" Factor is case sensitive.
syn case match

" Make all of these characters part of a word (useful for skipping over words with w, e, and b)
let s:iskeyword = '!,@,33-35,%,$,38-64,A-Z,91-96,a-z,123-126,128-255'
let s:set_iskeyword = has('patch-7.4.1142') ? 'syn iskeyword ' :
      \ 'setlocal iskeyword='
execute s:set_iskeyword . s:iskeyword

syn match   factorWord   /\v<\S+>/  contains=@factorWord transparent display
syn cluster factorClusterNoComment  contains=factorWord,@factorMultilineComment,@factorClusterValue,factorBoolean,factorBreakpoint,factorDeclaration,factorCallQuotation,factorExecute,factorCallNextMethod,@factorWordOps,factorAlien,factorSlot,factorTuple,factorErrorSyn,factorStruct
syn cluster factorCluster           contains=@factorComment,@factorClusterNoComment

" A crash course on Factor's lexer:
"
" The "lexer" vocabulary parses lines (arrays of strings) into tokens.
" Tokens are non-space strings, effectively words.
" "[ f skip ] call( i seq -- n )" finds the next space, erroring on tabs.
"   "t skip" finds the next non-space.
" The "lexer" class holds lex state.
" Lexer method "skip-word" advances to the next space (via "f skip"),
"     while also counting leading double quotation marks as their own words.
"   I.e., this advances to the end of the current token
"     (if currently at a token, otherwise nothing changes).
" Method "skip-blank" advances to the next non-space (via "t skip"),
"     while also skipping shebangs at the beginning of the first line.
"   I.e., this advances to the start of the next token
"     (if one is present, otherwise it advances to the line's end).
" "(parse-raw)" advances a lexer through an immediate token via "skip-word",
"   and returns the (sub)token advanced through.
"   Note that this will not advance a lexer at space,
"     and an empty string will be returned.
" "next-line" advances a lexer to the start of the next line,
"   adding an effectively empty line to the end (as an EOF state).
" "parse-raw" advances a lexer through the next token,
"   first via alternating "skip-blank" & "next-line" if the line ended,
"     then via "(parse-raw)",
"   and returns it if found, otherwise (i.e. upon EOF) returning "f".
"     Note that the lexer will be advanced to EOF if "f" is returned.
" Comments are (unprocessed) remainders of lines, after a "!" word.
" "parse-token" advances a lexer though the next token via "parse-raw",
"   then returns it if found, otherwise returning "f".
"   while also advancing through comments
"     via mutual recursion with "skip-comment".
"   "[ skip-comment ] call( lexer str -- str' )" tests if a token is "!",
"     returning that token if so,
"     otherwise first advancing a lexer to the next line via "next-line"
"         (i.e. discarding the rest of the current line)
"       and then advancing it via "parse-token" & returning that token,
"     ensuring the return of "parse-token"'s desired non-comment token.
" The "lexer" dynamic variable holds the ambient lexer.
" "?scan-token" advances the ambient lexer through the next token
"     via "parse-token",
"   and returns it if found, otherwise returning "f".
" "scan-token" advances the ambient lexer through the next token
"     via "?scan-token",
"   and returns it if found, otherwise throwing an exception.
" All other words in the "lexer" vocabulary read via "scan-token", if at all.
" So! To know when double quotes & exclamation marks aren't special,
"   grep for "parse-raw". (Mostly. To be certain, grep for "lexer".)

syn cluster factorComment           contains=factorComment
syn cluster factorCommentContents   contains=factorTodo,@Spell
syn match   factorTodo              /\v(TODO|FIXME|XXX):=/ contained

syn cluster factorDefnContents      contains=@factorCluster

syn region  factorDefn            start=/\v<%(SYNTAX|%(MACRO|MEMO|TYPED)?:?):>/    skip=/\v<!>/ matchgroup=factorDefnDelims     end=/\v<;>/ contains=factorDefnDelims,@factorDefnContents
syn region  factorMethod          start=/\v<M::?>/                                 skip=/\v<!>/ matchgroup=factorDefnDelims     end=/\v<;>/ contains=factorMethodDelims,@factorDefnContents
syn region  factorGeneric         start=/\v<%(GENERIC|MATH|PRIMITIVE):>/           skip=/\v<!>/ end=/\v<\S+>/ contains=@factorComment nextgroup=factorStackEffectSkip
syn region  factorGenericN        start=/\v<GENERIC\#:>/                           skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\d+>/ contains=@factorComment nextgroup=factorStackEffectSkip

syn region  factorPDefn           start=/\v<%(SYNTAX|%(MACRO|MEMO|TYPED)?:?):>/    skip=/\v<!>/ matchgroup=factorPDefnDelims    end=/\v<;>/ contains=factorPDefnDelims,@factorDefnContents contained
syn region  factorPMethod         start=/\v<M::?>/                                 skip=/\v<!>/ matchgroup=factorPDefnDelims    end=/\v<;>/ contains=factorPMethodDelims,@factorDefnContents contained
syn region  factorPGeneric        start=/\v<%(GENERIC|MATH|PRIMITIVE):>/           skip=/\v<!>/ end=/\v<\S+>/ contains=@factorComment nextgroup=factorStackEffectSkip contained
syn region  factorPGenericN       start=/\v<GENERIC\#:>/                           skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\d+>/ contains=@factorComment nextgroup=factorStackEffectSkip contained

syn region  factorDefnDelims      start=/\v<%(SYNTAX|%(MACRO|MEMO|TYPED)?:?):>/    skip=/\v<!>/ end=/\v<\S+>/ contains=@factorComment nextgroup=factorStackEffectSkip contained
syn region  factorMethodDelims    start=/\v<M::?>/                                 skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment nextgroup=factorStackEffectSkip contained
syn region  factorPDefnDelims     start=/\v<%(SYNTAX|%(MACRO|MEMO|TYPED)?:?):>/    skip=/\v<!>/ end=/\v<\S+>/ contains=@factorComment nextgroup=factorStackEffectSkip contained
syn region  factorPMethodDelims   start=/\v<M::?>/                                 skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment nextgroup=factorStackEffectSkip contained

syn region  None matchgroup=factorPrivate start=/\v<\<PRIVATE>/ end=/\v<PRIVATE\>>/ contains=@factorDefnContents,factorPrivateDefn,factorPrivateMethod,factorPGeneric,factorPGenericN

syn cluster factorClusterValue      contains=factorBreakpoint,factorBoolean,factorFrySpecifier,factorChar,@factorString,@factorNumber,factorBackslash,factorMBackslash,factorLiteral,factorLiteralBlock,@factorStackEffect,@factorQuotation,@factorArray
syn match   factorClusterValueSkip  /\v%(\_\s+%(!>.*)?)*/ nextgroup=@factorClusterValue transparent contained

syn keyword factorBoolean           f t
syn keyword factorBreakpoint        B
syn keyword factorFrySpecifier      @ _ contained
syn keyword factorDeclaration       delimiter deprecated final flushable foldable inline recursive
syn match   factorCallQuotation     /\vcall\V(\v/me=e-1    nextgroup=@factorStackEffect
syn match   factorExecute           /\vexecute\V(\v/me=e-1 nextgroup=@factorStackEffect
syn keyword factorCallNextMethod    call-next-method

syn region  factorChar        start=/\v<CHAR:>/ end=/\v\S+/

syn cluster factorString            contains=factorString,factorTriString,factorPrefixedString
syn match   factorEscape            /\v\\([\\astnrbvf0e\"]|u\x{6}|u\{\S+}|x\x{2})/  contained display
syn region  factorString            matchgroup=factorStringDelims         start=/\v<"/                 skip=/\v\\"/ end=/\v"/   contains=factorEscape
syn region  factorTriString         matchgroup=factorTriStringDelims      start=/\v<"""/               skip=/\v\\"/ end=/\v"""/ contains=factorEscape
syn region  factorPrefixedString    matchgroup=factorPrefixedStringDelims start=/\v<[^[:blank:]"]+">/  skip=/\v\\"/ end=/\v"/   contains=factorEscape

" Vocabulary: multiline
" This vocabulary reads the ambient lexer without "parse-raw".
syn cluster factorString            add=factorMultilineString,factorHereDocString,factorPrefixedMultilineString
syn region  factorMultilineString   matchgroup=factorMultilineStringDelims    start=/\v<\[\z(\={0,6})\[>/   end=/\v\]\z1\]/
syn region  factorHereDoc           matchgroup=factorMultilineStringDelims    start=/\v<STRING:\s+\S+>/     end=/\v^;$/
syn region  factorHereDocString     matchgroup=factorMultilineStringDelims    start=/\v<HEREDOC:\s+\z(.*)>/ end=/\v^\z1$/
syn region  factorPrefixedMultilineString matchgroup=factorPrefixedMultilineStringDelims  start=/\v<[^[\][:blank:]]+\[\z(\={0,6})\[>/   end=/\v\]\z1\]/
" These comments are normal syntax words, so no lexer privilege for them.
" (Hence, no "syn cluster factorComment" membership.)
syn cluster factorMultilineComment  contains=factorMultilineComment,factorMultilineCComment
syn region  factorMultilineComment  matchgroup=factorMultilineCommentDelims   start=/\v<!\[\z(\={0,6})\[>/  end=/\v\]\z1\]/ contains=@factorCommentContents keepend
syn region  factorMultilineCComment matchgroup=factorMultilineCCommentDelims  start=/\v<\/\*>/              end=/\v\*\//    contains=@factorCommentContents keepend

syn cluster factorReal                  contains=factorInt,factorFloat,factorPosRatio,factorNegRatio,@factorBin,@factorHex,@factorOct,factorNan
syn cluster factorNumber                contains=@factorReal,factorComplex
syn match   factorInt                   /\v<[+-]=[0-9]%([0-9,]*[0-9])?%([eE]%([+-])?[0-9]+)?>/
syn match   factorFloat                 /\v<[+-]=%([0-9,]*[0-9])?%(\.%(%([0-9,]*[0-9]+)?%([eE]%([+-])?[0-9]+)?)?)?>/
syn match   factorPosRatio              /\v<\+=[0-9]%([0-9,]*[0-9])?%(\+[0-9]%([0-9,]*[0-9]+)?)?\/-=[0-9]%([0-9,]*[0-9]+)?\.?>/
syn match   factorNegRatio              /\v<\-[0-9]%([0-9,]*[0-9])?%(\-[0-9]%([0-9,]*[0-9]+)?)?\/-=[0-9]%([0-9,]*[0-9]+)?\.?>/
syn region  factorComplex         start=/\v<C\{>/   end=/\v<\}>/    contains=@factorReal
syn match   factorBin                   /\v<[+-]=0b[01,]\+>/
syn cluster factorBin                   add=factorBin
if !exists('g:factor_syn_no_error')
  syn match   factorBinError            /\v<[+-]=0b[01,]*[^01 ]\S*>/
  syn cluster factorBin                 contains=factorBinError
endif
syn match   factorHexNoRadixTrans       /\v<[0-9a-fA-F]%([0-9a-fA-F,]*[0-9a-fA-F])?%(\.[0-9a-fA-F]%([0-9a-fA-F,]*[0-9a-fA-F])?)?%(p-=[0-9]%([0-9,]*[0-9])?)?>/ contained transparent
syn cluster factorHexNoRadixTrans       add=factorHexNoRadixTrans
syn match   factorHex                   /\v<[+-]=0x[0-9a-fA-F]%([0-9a-fA-F,]*[0-9a-fA-F])?%(\.[0-9a-fA-F]%([0-9a-fA-F,]*[0-9a-fA-F])?)?%(p-=[0-9]%([0-9,]*[0-9])?)?>/
syn cluster factorHex                   add=factorHex
if !exists('g:factor_syn_no_error')
  syn match   factorHexNoRadixError     /\v<%(,\S*|\S*,|[-0-9a-fA-Fp,]*[^-0-9a-fA-Fp, ]\S*)>/ contained
  syn cluster factorHexNoRadixTrans     contains=factorHexNoRadixError
  syn match   factorHexError            /\v<[+-]=0x%(,\S*|\S*,|[-0-9a-fA-Fp,]*[^-0-9a-fA-Fp, ]\S*)>/
  syn cluster factorHex                 contains=factorHexError
endif
syn match   factorOct                   /\v<[+-]=0o[0-7,]+>/
syn cluster factorOct                   add=factorOct
if !exists('g:factor_syn_no_error')
  syn match   factorOctError             /\v<[+-]=0o%(,\S*|\S*,|[0-7,]*[^0-7, ]\S*)>/
  syn cluster factorOct                 contains=factorOctError
endif
syn region  factorNan matchgroup=factorNan start=/\v<NAN:>/ matchgroup=NONE end=/\v<\S+>/ contains=@factorComment,@factorHexNoRadixTrans

syn region  factorBackslash       start=/\v<\\>/   skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorMBackslash      start=/\v<M\\>/  skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment
syn region  factorLiteral         start=/\v<\$>/   skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorLiteralBlock    start=/\v<\$\[>/              end=/\v<\]>/    contains=@factorComment

syn region  factorIn      start=/\v<IN:>/      skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorUse     start=/\v<USE:>/     skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorUnuse   start=/\v<UNUSE:>/   skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment

syn region  factorUsing           start=/\v<USING:>/                        end=/\v<;>/     contains=@factorComment
syn region  factorQualified       start=/\v<QUALIFIED:>/       skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorQualifiedWith   start=/\v<QUALIFIED-WITH:>/  skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment
syn region  factorExclude         start=/\v<EXCLUDE:>/                      end=/\v<;>/     contains=@factorComment
syn region  factorFrom            start=/\v<FROM:>/                         end=/\v<;>/     contains=@factorComment
syn region  factorRename          start=/\v<RENAME:>/          skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\S+%(\_\s+%(!>.*)?)+\=\>%(\_\s+%(!>.*)?)+\S+>/  contains=@factorComment
syn region  factorSingletons      start=/\v<SINGLETONS:>/                   end=/\v<;>/     contains=@factorComment
syn region  factorSymbol          start=/\v<SYMBOL:>/          skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorSymbols         start=/\v<SYMBOLS:>/                      end=/\v<;>/     contains=@factorComment
syn region  factorConstructor2    start=/\v<CONSTRUCTOR:?/                  end=/\v<;>/     contains=@factorComment
syn region  factorIntersection    start=/\v<INTERSECTION:>/                 end=/\v<;>/     contains=@factorComment
syn cluster factorSlotAttr              contains=factorSlotAttrInitial,factorSlotAttrReadOnly
syn cluster factorTupleSlotAttr         contains=@factorSlotAttr
syn match   factorTupleSlotName         /\v<\S+>/ nextgroup=factorTupleSlotClassSkip contained
syn match   factorTupleSlotNameSkip     /\v%(\_\s+%(!>.*)?)*/ nextgroup=factorTupleSlotName transparent contained
syn match   factorTupleSlotClass        /\v<\S+>/ contained
" a class is optional, so let an attribute take priority if present
syn match   factorTupleSlotClassSkip    /\v%(\_\s+%(!>.*)?)*/ nextgroup=factorTupleSlotClass,@factorTupleSlotAttr transparent contained
syn region  factorTupleSlot matchgroup=factorTupleSlotDelims  start=/\v<\{>/                end=/\v<\}>/   contains=@factorComment,factorTupleSlotName,@factorTupleSlotAttr contained
syn region  factorTuple matchgroup=factorTupleDelims          start=/\v<%(TUPLE|BUILTIN):>/ end=/\v<;>/ contains=@factorComment,factorTupleSlotName,factorTupleSlot
" Abnormally named because factor*Error is reserved for syntax errors.
syn region  factorErrorSyn        start=/\v<ERROR:>/            end=/\v<;>/     contains=@factorComment
syn region  factorUnion           start=/\v<UNION:>/            end=/\v<;>/     contains=@factorComment
syn cluster factorStructSlotAttr        contains=@factorSlotAttr,factorStructSlotAttrBits
syn match   factorStructSlotName        /\v<\S+>/ nextgroup=factorStructSlotTypeSkip contained
syn match   factorStructSlotNameSkip    /\v%(\_\s+%(!>.*)?)*/ nextgroup=factorStructSlotName contained transparent
syn match   factorStructSlotType        /\v<\S+>/ contained
syn match   factorStructSlotTypeSkip    /\v%(\_\s+%(!>.*)?)*/ nextgroup=factorStructSlotType contained transparent
syn region  factorStructSlot matchgroup=factorStructSlotDelims    start=/\v<\{>/     end=/\v<\}>/ contains=@factorComment,factorStructSlotName,@factorStructSlotAttr contained
syn region  factorStruct matchgroup=factorStructDelims            start=/\v<%(UNION-STRUCT|STRUCT):>/   end=/\v<;>/ contains=@factorComment,factorStructSlot

syn match   factorSlotAttrReadOnly      /\v<read-only>/ contained
syn match   factorSlotAttrInitial       /\v<initial:>%(\_\s+%(!>.*)?)+/ contains=@factorComment nextgroup=factorWord,@factorClusterValue contained
syn match   factorStructSlotAttrBits    /\v<bits:>%(\_\s+%(!>.*)?)+/    contains=@factorComment nextgroup=factorWord,@factorReal contained

syn region  factorConstant        start=/\v<CONSTANT:>/    skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorAlias           start=/\v<ALIAS:>/       skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment
syn region  factorSingleton       start=/\v<SINGLETON:>/   skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorPostpone        start=/\v<POSTPONE:>/    skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorDefer           start=/\v<DEFER:>/       skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorForget          start=/\v<FORGET:>/      skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorMixin           start=/\v<MIXIN:>/       skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorInstance        start=/\v<INSTANCE:>/    skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment
syn region  factorHook            start=/\v<HOOK:>/        skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment nextgroup=factorStackEffectSkip
syn region  factorMain            start=/\v<MAIN:>/        skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment
syn region  factorConstructor     start=/\v<C:>/           skip=/\v<!>/ end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment
syn region  factorAlien matchgroup=factorAlien start=/\v<ALIEN:>/ matchgroup=NONE  skip=/\v<!>/ end=/\v<\S+>/  contains=@factorComment,@factorHexNoRadixTrans 
syn region  factorSlot            start=/\v<SLOT:>/        skip=/\v<!>/ end=/\v<\S+>/   contains=@factorComment

syn cluster factorWordOps   contains=factorConstant,factorAlias,factorSingleton,factorSingletons,factorSymbol,factorSymbols,factorPostpone,factorDefer,factorForget,factorMixin,factorInstance,factorHook,factorMain,factorConstructor

"TODO:
"misc:
" HELP:
" ARTICLE:
"literals:
" PRIMITIVE:

"C interface:
" C-ENUM:
" FUNCTION:
" TYPEDEF:
" LIBRARY:
"#\ "

if !exists('g:factor_syn_no_error')
  syn match   factorStackEffectRequired /\v<\V(\@!\v\S+>/    contained
endif
syn cluster factorStackEffectContents   contains=@factorComment,factorStackEffectDelims,factorStackEffectVar,factorStackEffectType,factorStackEffectRowVar
syn cluster factorStackEffect           contains=factorStackEffect
" Erroring on stack effects without a "--" separator would be nice.
" Unfortunately, that sort of vacuous detection is above Vim's pay-grade,
"   especially when stack effects can be nested arbitrarily via types.
syn match   factorStackEffectSkip   /\v%(\_\s+%(!>.*)?)*/ nextgroup=factorStackEffectRequired,@factorStackEffect transparent contained
syn region  factorStackEffect       matchgroup=factorStackEffectDelims    start=/\v\V(\v>/  end=/\v<\V)\v>/ contains=@factorStackEffectContents
syn match   factorStackEffectVar        /\v<\S+>/           contained
" Note that ":!" parses to the "!" word and doesn't lex as a comment.
" Also, even though we take any value, the leading ":" breaking the word
"   boundary means a lot of our nicer syntax patterns don't match on
"   "factorStackEffectType".
" syn cluster factorStackEffectType contains=factorWord,@factorStackEffect
syn cluster factorStackEffectType       contains=@factorClusterValue
syn region  factorStackEffectVar    matchgroup=factorStackEffectVar       start=/v<\S+:>/       matchgroup=NONE end=/\v%(\_\s+%(!>.*)?)+/ contains=@factorComment nextgroup=@factorStackEffectType transparent contained
syn match   factorStackEffectType       /\v<:/              contained nextgroup=@factorStackEffectType
syn match   factorStackEffectRowVar     /\v<\.\.\S+>/       contained
syn region  factorStackEffectRowVar matchgroup=factorStackEffectRowVar    start=/v<\.\.\S+:>/   matchgroup=NONE end=/\v%(\_\s+%(!>.*)?)+/ contains=@factorComment nextgroup=@factorStackEffectType transparent contained
syn match   factorStackEffectDelims     /\v<-->/            contained
if !exists('g:factor_syn_no_error')
  syn cluster factorStackEffectContents add=factorStackEffectError
  syn keyword factorStackEffectError    (                   contained
endif

" adapted from lisp.vim
if exists('g:factor_syn_no_rainbow')
  syn cluster factorQuotation   contains=factorQuotation
  syn region  factorQuotation      matchgroup=factorDelimiter start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=ALL
else
  syn cluster factorQuotation   contains=factorQuotation0
  syn region  factorQuotation0            matchgroup=hlLevel0 start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=@factorCluster,factorQuotation1,factorArray1
  syn region  factorQuotation1 contained  matchgroup=hlLevel1 start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=@factorCluster,factorQuotation2,factorArray2
  syn region  factorQuotation2 contained  matchgroup=hlLevel2 start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=@factorCluster,factorQuotation3,factorArray3
  syn region  factorQuotation3 contained  matchgroup=hlLevel3 start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=@factorCluster,factorQuotation4,factorArray4
  syn region  factorQuotation4 contained  matchgroup=hlLevel4 start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=@factorCluster,factorQuotation5,factorArray5
  syn region  factorQuotation5 contained  matchgroup=hlLevel5 start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=@factorCluster,factorQuotation6,factorArray6
  syn region  factorQuotation6 contained  matchgroup=hlLevel6 start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=@factorCluster,factorQuotation7,factorArray7
  syn region  factorQuotation7 contained  matchgroup=hlLevel7 start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=@factorCluster,factorQuotation8,factorArray8
  syn region  factorQuotation8 contained  matchgroup=hlLevel8 start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=@factorCluster,factorQuotation9,factorArray9
  syn region  factorQuotation9 contained  matchgroup=hlLevel9 start=/\v<%(%(%('|\$|)\[)|\[%(let|\|))>/  end=/\v<\]>/    contains=@factorCluster,factorQuotation0,factorArray0
endif

if exists('g:factor_syn_no_rainbow')
  syn cluster factorArray       contains=factorArray
  syn region  factorArray          matchgroup=factorDelimiter start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/        end=/\v<\}>/    contains=ALL
else
  syn cluster factorArray       contains=factorArray0
  syn region  factorArray0               matchgroup=hlLevel0 start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray1,factorQuotation1
  syn region  factorArray1     contained matchgroup=hlLevel1 start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray2,factorQuotation2
  syn region  factorArray2     contained matchgroup=hlLevel2 start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray3,factorQuotation3
  syn region  factorArray3     contained matchgroup=hlLevel3 start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray4,factorQuotation4
  syn region  factorArray4     contained matchgroup=hlLevel4 start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray5,factorQuotation5
  syn region  factorArray5     contained matchgroup=hlLevel5 start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray6,factorQuotation6
  syn region  factorArray6     contained matchgroup=hlLevel6 start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray7,factorQuotation7
  syn region  factorArray7     contained matchgroup=hlLevel7 start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray8,factorQuotation8
  syn region  factorArray8     contained matchgroup=hlLevel8 start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray9,factorQuotation9
  syn region  factorArray9     contained matchgroup=hlLevel9 start=/\v<%(\$|[-a-zA-Z0-9]+)?\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray0,factorQuotation0
endif

if !exists('g:factor_syn_no_error')
  syn match   factorBracketError    /\v<\]>/
  syn match   factorBracketError    /\v<\}>/
endif

function! FactorSynDefineComment() abort
  syn region  factorComment   start=/\v<!>/ end=/\v$/   keepend oneline contains=@factorCommentContents
  syn match   factorShebang         /\v%^\#!.*$/ display
  if !exists('g:factor_syn_no_error')
    syn match   factorShebangError  /\v%^\#!\S+/
  endif
endfunction

if !exists('g:factor_syn_no_comment')
  call FactorSynDefineComment()
endif

" Syntax that bypasses comment lexing.
function! FactorSynDefineAfterComment() abort
endfunction

if !exists('g:factor_syn_no_after_comment')
  call FactorSynDefineAfterComment()
endif

syn sync lines=100

if !exists('g:factor_syn_no_init')
  command -nargs=+ -bar HiLink hi def link <args>

  if !exists('g:factor_syn_no_error')
    HiLink factorShebangError           Error
    HiLink factorBracketError           Error
    HiLink factorBinError               Error
    HiLink factorHexNoRadixError        Error
    HiLink factorHexError               Error
    HiLink factorOctError               Error
    HiLink factorStackEffectRequired    Error
    HiLink factorStackEffectError       Error
  endif

  HiLink   factorComment                Comment
  HiLink   factorMultilineComment       factorComment
  HiLink   factorMultilineCComment      factorComment
  HiLink   factorShebang                PreProc
  HiLink   factorStackEffect            Type
  HiLink   factorStackEffectDelims      Delimiter
  HiLink   factorStackEffectVar         Identifier
  HiLink   factorStackEffectRowVar      factorStackEffectVar
  HiLink   factorStackEffectType        Type
  HiLink   factorTodo                   Todo
  HiLink   factorInclude                Include
  HiLink   factorWord                   Keyword
  HiLink   factorCallQuotation          Keyword
  HiLink   factorExecute                Keyword
  HiLink   factorCallNextMethod         Keyword
  HiLink   factorOperator               Operator
  HiLink   factorFrySpecifier           Operator
  HiLink   factorBoolean                Boolean
  HiLink   factorBreakpoint             Debug
  HiLink   factorDefnDelims             Typedef
  HiLink   factorMethodDelims           Typedef
  HiLink   factorGeneric                Typedef
  HiLink   factorGenericN               Typedef
  HiLink   factorConstructor            Typedef
  HiLink   factorConstructor2           Typedef
  HiLink   factorPrivate                Special
  HiLink   factorPDefnDelims            Special
  HiLink   factorPMethodDelims          Special
  HiLink   factorPGenericDelims         Special
  HiLink   factorPGenericNDelims        Special
  HiLink   factorEscape                 SpecialChar
  HiLink   factorString                 String
  HiLink   factorStringDelims           factorString
  HiLink   factorTriString              factorString
  HiLink   factorTriStringDelims        factorTriString
  HiLink   factorPrefixedString         factorString
  HiLink   factorPrefixedStringDelims   factorPrefixedString
  HiLink   factorMultilineString        factorString
  HiLink   factorMultilineStringDelims  Typedef
  HiLink   factorHereDocString          factorMultilineString
  HiLink   factorHereDocStringDelims    factorMultilineStringDelims
  HiLink   factorPrefixedMultilineString factorString
  HiLink   factorPrefixedMultilineStringDelims factorMultilineStringDelims
  HiLink   factorComplex                Number
  HiLink   factorPosRatio               Number
  HiLink   factorNegRatio               Number
  HiLink   factorBin                    Number
  HiLink   factorHex                    Number
  HiLink   factorNan                    Number
  HiLink   factorOct                    Number
  HiLink   factorFloat                  Float
  HiLink   factorInt                    Number
  HiLink   factorUsing                  Include
  HiLink   factorQualified              Include
  HiLink   factorQualifiedWith          Include
  HiLink   factorExclude                Include
  HiLink   factorFrom                   Include
  HiLink   factorRename                 Include
  HiLink   factorUse                    Include
  HiLink   factorUnuse                  Include
  HiLink   factorIn                     Define
  HiLink   factorChar                   Character
  HiLink   factorDelimiter              Delimiter
  HiLink   factorBackslash              Special
  HiLink   factorMBackslash             Special
  HiLink   factorLiteral                Special
  HiLink   factorLiteralBlock           Special
  HiLink   factorDeclaration            Typedef
  HiLink   factorSymbol                 Define
  HiLink   factorSymbols                Define
  HiLink   factorConstant               Define
  HiLink   factorAlias                  Define
  HiLink   factorSingleton              Define
  HiLink   factorSingletons             Define
  HiLink   factorMixin                  Typedef
  HiLink   factorInstance               Typedef
  HiLink   factorHook                   Typedef
  HiLink   factorMain                   Define
  HiLink   factorPostpone               Define
  HiLink   factorDefer                  Define
  HiLink   factorForget                 Define
  HiLink   factorAlien                  Define
  HiLink   factorSlot                   Define
  HiLink   factorIntersection           Typedef
  HiLink   factorSlot                   Typedef
  HiLink   factorSlotDelims             factorSlot
  HiLink   factorSlotName               Identifier
  HiLink   factorSlotClass              Type
  HiLink   factorSlotType               factorSlotClass
  HiLink   factorSlotAttr               Special
  HiLink   factorSlotAttrInitial        factorSlotAttr
  HiLink   factorSlotAttrReadOnly       factorSlotAttr
  HiLink   factorStructSlotAttr         factorSlotAttr
  HiLink   factorStructSlotAttrBits     factorStructSlotAttr
  HiLink   factorTuple                  Typedef
  HiLink   factorTupleDelims            factorTuple
  HiLink   factorTupleSlot              factorSlot
  HiLink   factorTupleSlotDelims        factorSlotDelims
  HiLink   factorTupleSlotName          factorSlotName
  HiLink   factorTupleSlotClass         factorSlotClass
  HiLink   factorErrorSyn               Typedef
  HiLink   factorUnion                  Typedef
  HiLink   factorStruct                 Typedef
  HiLink   factorStructDelims           factorStruct
  HiLink   factorStructSlot             factorSlot
  HiLink   factorStructSlotDelims       factorSlotDelims
  HiLink   factorStructSlotName         factorSlotName
  HiLink   factorStructSlotType         factorSlotType

  if &bg == 'dark'
    hi   hlLevel0 ctermfg=red           guifg=red1
    hi   hlLevel1 ctermfg=yellow        guifg=orange1
    hi   hlLevel2 ctermfg=green         guifg=yellow1
    hi   hlLevel3 ctermfg=cyan          guifg=greenyellow
    hi   hlLevel4 ctermfg=magenta       guifg=green1
    hi   hlLevel5 ctermfg=red           guifg=springgreen1
    hi   hlLevel6 ctermfg=yellow        guifg=cyan1
    hi   hlLevel7 ctermfg=green         guifg=slateblue1
    hi   hlLevel8 ctermfg=cyan          guifg=magenta1
    hi   hlLevel9 ctermfg=magenta       guifg=purple1
  else
    hi   hlLevel0 ctermfg=red           guifg=red3
    hi   hlLevel1 ctermfg=darkyellow    guifg=orangered3
    hi   hlLevel2 ctermfg=darkgreen     guifg=orange2
    hi   hlLevel3 ctermfg=blue          guifg=yellow3
    hi   hlLevel4 ctermfg=darkmagenta   guifg=olivedrab4
    hi   hlLevel5 ctermfg=red           guifg=green4
    hi   hlLevel6 ctermfg=darkyellow    guifg=paleturquoise3
    hi   hlLevel7 ctermfg=darkgreen     guifg=deepskyblue4
    hi   hlLevel8 ctermfg=blue          guifg=darkslateblue
    hi   hlLevel9 ctermfg=darkmagenta   guifg=darkviolet
  endif
endif
delcommand HiLink

let b:current_syntax = 'factor'

" vim: set ft=vim et sw=2 isk+=/,\\ :
