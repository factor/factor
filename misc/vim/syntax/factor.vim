" Vim syntax file
" Language: Factor
" Maintainer: Alex Chapman <chapman.alex@gmail.com>
" Last Change: 2020 Sep 30
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
" Escape all literal [^[:alnum:]_-!:;] characters in these patterns.
" (Not escaping [-!:;] characters risks forward-incompatibility,
"   but fixes if an incompatible Vim arises would be trivial,
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
" "syn match {group-name}Skip /\v%(\_\s+%(!>.*)?)*/ contains=@factorComment nextgroup={group-name} transparent contained"
" Specifying "nextgroup={group-name}Skip skipempty" works like a Factor-aware
"   "nextgroup={group-name} skipwhite skipempty"
"   with required initial space (not optional).
" "{cluster-name}Skip" works similarly, but with "nextgroup=@{cluster-name}".
"
" Vim's syntax highlighting freaks at paired "/\v\(" and "/\v\)". ☹
" Switching into very nomagic (with "/\V(\v/" or "/\V)\v") averts that,
"   as non-escaped parentheses don't extend pattern regions.
"
" A handy testing command:
" "echo join(map(synstack(line('.'),col('.')),{sn->{i,s->{t->sn(s).(s==t?'':' ('.sn(t).')')}(synIDtrans(s))}}({s->synIDattr(s,'name')})),' -> ')"
"   Outputs in the form "hi<...> trans<...> lo<...>":
"     "hi": syntax group
"     "trans": transparent syntax group (if not applicable, same as "hi")
"     "lo": highlight group

if exists('b:current_syntax')
  finish
endif

" Factor is case sensitive.
syn case match

syn match   factorWord   /\v<\S+>/  contains=@factorWord transparent display
syn cluster factorCluster           contains=factorWord,factorComment,factorMultilineComment,@factorClusterValue,factorDeclaration,factorCall,factorCallNextMethod,@factorWordOps,factorAlien,factorSlot,factorTuple,factorStruct,factorSlotsSyntax
syn cluster factorClusterValue      contains=factorBreakpoint,factorBoolean,factorFrySpecifier,factorLocalsSpecifier,factorChar,factorString,@factorNumber,factorBackslash,factorMBackslash,factorLiteral,@factorEffect,@factorEffectComment,@factorQuotation,@factorArray,factorRegexp

" Almost any byte in Factor can be a part of a word
syn iskeyword 33-126,128-255

" A crash course on Factor's lexer:
"
" The "lexer" vocabulary parses lines (arrays of strings) into tokens.
" Tokens are non-space strings, effectively words.
" The "lexer" class holds lex state.
" Lexer method "skip-word" advances to the next space
"     while also counting leading double quotation marks as their own words.
"   I.e., this advances to the end of the current token
"     (if currently at a token, otherwise nothing changes).
" Method "skip-blank" advances to the next non-space
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

syn match   factorShebang           /\v%^\#!.*$/ display

syn cluster factorComment           contains=factorComment
syn match   factorComment           /\v<!>.*$/ contains=@factorCommentContents
syn cluster factorCommentContents   contains=factorTodo,@Spell
syn match   factorTodo              /\v(TODO|FIXME|XXX):=/ contained

syn match   factorInit              /\v<%(STARTUP-HOOK|SHUTDOWN-HOOK):>/     display

syn cluster factorHelp              contains=factorHelp
syn region  factorHelp              start=/\v<HELP:>/            skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn match   factorHelp              /\v<%(ARTICLE|ABOUT):>/     display

syn region  factorDefn  matchgroup=NONE  start=/\v<%(SYNTAX|CONSTRUCTOR|%(M|MACRO|MEMO|TYPED)?:?):>/  skip=/\v<(!|CHAR:)>.*/  matchgroup=factorDefnDelims  end=/\v<;>/  contains=factorDefnDelims,@factorCluster keepend transparent
syn region  factorDefnDelims        start=/\v<SYNTAX:>/                            skip=/\v<!>.*/  end=/\v<\S+>/  contains=@factorComment skipempty keepend contained
syn region  factorDefnDelims        start=/\v<%(MACRO|MEMO|TYPED)?:?:>/            skip=/\v<!>.*/  end=/\v<\S+>/  contains=@factorComment nextgroup=factorEffectSkip skipempty keepend contained
syn region  factorDefnDelims        start=/\v<M:>/                                 skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment skipempty keepend contained
syn region  factorDefnDelims        start=/\v<M::>/                                skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment nextgroup=factorEffectSkip skipempty keepend contained
syn region  factorDefnDelims        start=/\v<CONSTRUCTOR:>/                       skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment nextgroup=factorEffectSkip skipempty keepend contained
syn region  factorDeclDelims        start=/\v<%(GENERIC|MATH|PRIMITIVE):>/         skip=/\v<!>.*/  end=/\v<\S+>/                       contains=@factorComment nextgroup=factorEffectSkip skipempty keepend
syn region  factorDeclDelims        start=/\v<GENERIC\#:>/                         skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\d+>/   contains=@factorComment nextgroup=factorEffectSkip skipempty keepend
syn region  factorDeclDelims        start=/\v<HOOK:>/                              skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment nextgroup=factorEffectSkip skipempty keepend
syn region  factorDeclDelims        start=/\v<C:>/                                 skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment skipempty keepend

syn region  factorPDefn  matchgroup=NONE  start=/\v<%(SYNTAX|CONSTRUCTOR|%(M|MACRO|MEMO|TYPED)?:?):>/  skip=/\v<!>.*/  matchgroup=factorPDefnDelims  end=/\v<;>/  contains=factorPDefnDelims,@factorCluster keepend contained
syn region  factorPDefnDelims       start=/\v<SYNTAX:>/                            skip=/\v<!>.*/  end=/\v<\S+>/                       contains=@factorComment skipempty keepend contained
syn region  factorPDefnDelims       start=/\v<%(MACRO|MEMO|TYPED)?:?:>/            skip=/\v<!>.*/  end=/\v<\S+>/                       contains=@factorComment nextgroup=factorEffectSkip skipempty keepend contained
syn region  factorPDefnDelims       start=/\v<M:>/                                 skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment skipempty keepend contained
syn region  factorPDefnDelims       start=/\v<M::>/                                skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment nextgroup=factorEffectSkip skipempty keepend contained
syn region  factorPDefnDelims       start=/\v<CONSTRUCTOR:>/                       skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment nextgroup=factorEffectSkip skipempty keepend contained
syn region  factorPDeclDelims       start=/\v<%(GENERIC|MATH|PRIMITIVE):>/         skip=/\v<!>.*/  end=/\v<\S+>/                       contains=@factorComment nextgroup=factorEffectSkip skipempty keepend contained
syn region  factorPDeclDelims       start=/\v<GENERIC\#:>/                         skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\d+>/   contains=@factorComment nextgroup=factorEffectSkip skipempty keepend contained
syn region  factorPDeclDelims       start=/\v<HOOK:>/                              skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment nextgroup=factorEffectSkip skipempty keepend contained
syn region  factorPDeclDelims       start=/\v<C:>/                                 skip=/\v<!>.*/  end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment skipempty keepend contained

syn region  factorPrivate           start=/\v<\<PRIVATE>/ end=/\v<PRIVATE\>>/ contains=@factorCluster,factorPDefn,factorPDeclDelims skipempty keepend

syn keyword factorBoolean           f t
syn keyword factorBreakpoint        B
syn keyword factorFrySpecifier      @ _ contained
syn keyword factorLocalsSpecifier   :> contained
syn keyword factorDeclaration       delimiter deprecated final flushable foldable inline recursive
syn region  factorCall  matchgroup=factorCallDelims  start=/\v<%(call|execute)\V(\v>/  end=/\v<\V)\v>/ contains=@factorEffectContents
syn keyword factorCallNextMethod    call-next-method

syn region  factorChar              start=/\v<CHAR:>/  end=/\v\S+>/
syn region  factorColor             start=/\v<COLOR:>/ end=/\v\S+>/

syn match   factorEscape            /\v\\([\\astnrbvfe\"]|u\x{6}|u\{\S+}|x\x{2}|\o{1,3})/  contained display
syn region  factorString            matchgroup=factorStringDelims   start=/\v<"/                 skip=/\v\\"/ end=/\v"/           contains=factorEscape
syn region  factorString            matchgroup=factorStringDelims   start=/\v<"""/               skip=/\v\\"/ end=/\v"""/         contains=factorEscape
syn region  factorString            matchgroup=factorStringDelims   start=/\v<[^[:blank:]"]+"/   skip=/\v\\"/ end=/\v"/           contains=factorEscape
syn region  factorString            matchgroup=factorStringDelims   start=/\v\[\z(\=*)\[/                     end=/\]\z1\]/       contains=factorEscape
syn region  factorString            matchgroup=factorStringDelims   start=/\v<[^[\][:blank:]]+\[\z(\=*)\[>/   end=/\v\]\z1\]/

syn region  factorNamedString       matchgroup=factorNamedStringDelims   start=/\v<STRING:\s+\S+$>/   end=/\v^<;>$/  contains=factorEscape

syn region  factorMultilineComment  start=/\v<\/\*>/              end=/\v\*\//       contains=@factorCommentContents keepend
syn region  factorMultilineComment  start=/\v<!\[\z(\=*)\[/       end=/\v\]\z1\]/    contains=@factorCommentContents keepend

syn region  factorRegexp            start=/\v<%(R\/\s)/  skip=/\v%(\\\/)/  end=/\v%(\/\S*)>/

syn cluster factorReal              contains=@factorInteger,@factorFloat,@factorRatio,@factorBin,@factorOct,@factorHex,factorNan
syn cluster factorNumber            contains=@factorReal,factorComplex

syn cluster factorInteger           contains=factorInteger
if !exists('g:factor_syn_no_error') " more general
  syn cluster factorInteger         add=factorIntegerError
  syn match   factorIntegerError    /\v<[+-]=%(\d|,|_){-}\d%(\d|,|_)*>/
endif
syn match   factorInteger           /\v<[+-]=\d%(\d|,|_)*,@1<!>/

syn cluster factorFloat             contains=factorFloat
if !exists('g:factor_syn_no_error') " more general
  syn cluster factorFloat           add=factorFloatError
  syn match   factorFloatError      /\v<[+-]=%(\S{-}\d&%(\d|,|_)*%([eE][+-]=%(\d|,|_)*|\.%(\d|,|_)*%([eE][+-]=%(\d|,|_)*)?)|\.%(\d|,|_)+%([eE][+-]=%(\d|,|_)*)?)>/
endif
syn match   factorFloat             /\v<[+-]=%(\d%(\d|,|_)*,@1<!%([eE][+-]=\d%(\d|,|_)*,@1<!|\.%(\d%(\d|,|_)*,@1<!)?%([eE][+-]=\d%(\d|,|_)*,@1<!)?)|\.\d%(\d|,|_)*,@1<!%([eE][+-]=\d%(\d|,|_)*,@1<!)?)>/

syn cluster factorRatio             contains=factorRatio
if !exists('g:factor_syn_no_error') " more general
  syn cluster factorRatio           add=factorRatioError
  syn match   factorRatioError      /\v<[+-]=%(\S{-}\d.{-}\/&%(\d|,|_)*\.?%(\d|,|_)*%([+-]%(\d|,|_)*)?)\/[+-]=%(\S{-}\d&%(\d|,|_)*\.?%(\d|,|_)*%([eE][+-]=%(\d|,|_)*)?)>/
endif
syn match   factorRatio             /\v<([+-]=)\d%(\d|,|_)*,@1<!%(\1@=[+-](\d%(\d|,|_)*,@1<!)\/\2@!\d%(\d|,|_)*,@1<!|\/%(\d%(\d|,|_)*,@1<!%(\.%(\d%(\d|,|_)*,@1<!)?)?|\.\d%(\d|,|_)*,@1<!)%([eE][+-]=\d%(\d|,|_)*,@1<!)?)%(\/0)@2<!>/

syn region  factorComplex           start=/\v<C\{>/   skip=/\v<!>.*/ end=/\v<\}>/    contains=@factorComment,@factorReal

syn cluster factorBin               contains=factorBin
if !exists('g:factor_syn_no_error')
  syn cluster factorBin             add=factorBinError
  syn match   factorBinError        /\v<[+-]=0[bB]%(\S{-}\w&%(\w|,|_)*\.?%(\w|,|_)*%([pP][+-]=%(\w|,|_)*)?)>/
endif
syn match   factorBin               /\v<[+-]=0[bB]%([01][01,_]*,@1<!%(\.%([01][01,_]*,@1<!)?)?|\.[01][01,_]*,@1<!)%([pP][+-]=\d%(\d|,|_)*,@1<!)?>/

syn cluster factorOct               contains=factorOct
if !exists('g:factor_syn_no_error')
  syn cluster factorOct             add=factorOctError
  syn match   factorOctError        /\v<[+-]=0[oO]%(\S{-}\o&%(\w|,|_)*\.?(\w|,|_)*%([pP][+-]=%(\w|,|_)*)?)>/
endif
syn match   factorOct               /\v<[+-]=0[oO]%(\o%(\o|,|_)*,@1<!%(\.%(\o%(\o|,|_)*,@1<!)?)?|\.\o%(\o|,|_)*,@1<!)%([pP][+-]=\d%(\d|,|_)*,@1<!)?>/

syn cluster factorHex               contains=factorHex
syn cluster factorHexNoRadix        contains=factorHexNoRadix
if !exists('g:factor_syn_no_error')
  syn cluster factorHex             add=factorHexError
  syn match   factorHexError        /\v<[+-]=0[xX]%(\S{-}\x&%(\x|,|_)*\.?(\x|,|_)*%([pP][+-]=%(\w|,|_)*)?)>/
  syn cluster factorHexNoRadix      add=factorHexNoRadixError
  syn match   factorHexNoRadixError /\v<[+-]=%(\S{-}\x&%(\w|,|_)*\.?(\w|,|_)*%([pP][+-]=%(\w|,|_)*)?)>/   contained
endif
syn match   factorHex               /\v<[+-]=0[xX]%(\x%(\x|,|_)*,@1<!%(\.%(\x%(\x|,|_)*,@1<!)?)?|\.\x%(\x|,|_)*,@1<!)%([pP][+-]=\d%(\d|,|_)*,@1<!)?>/
syn match   factorHexNoRadix        /\v<[+-]=%(\x%(\x|,|_)*,@1<!%(\.%(\x%(\x|,|_)*,@1<!)?)?|\.\x%(\x|,|_)*,@1<!)%([pP][+-]=\d%(\d|,|_)*,@1<!)?>/  contained

syn region  factorNan matchgroup=factorNan    start=/\v<NAN:>/ matchgroup=NONE skip=/\v<!>.*/   end=/\v<\S+>/   contains=@factorComment,@factorHexNoRadix keepend

syn region  factorBackslash         start=/\v<\\>/     skip=/\v<!>.*/       end=/\v<\S+>/   contains=@factorComment
syn region  factorMBackslash        start=/\v<M\\>/    skip=/\v<!>.*/       end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment keepend
syn region  factorLiteral           start=/\v<\$>/     skip=/\v<!>.*/       end=/\v<\S+>/   contains=@factorComment

syn match   factorSlotAttrReadOnly      /\v<read-only>/ contained
syn match   factorSlotAttrInitial       /\v<initial:>%(\_\s+%(!>.*)?)+/ contains=@factorComment nextgroup=factorWord,@factorClusterValue contained
syn cluster factorSlotAttr              contains=factorSlotAttrInitial,factorSlotAttrReadOnly,@factorArray

syn cluster factorTupleSlotAttr         contains=@factorSlotAttr
syn match   factorTupleSlotAttrSkip     /\v%(\_\s+%(!>.*)?)*/ contains=@factorComment nextgroup=@factorTupleSlotAttr contained transparent
syn match   factorTupleSlotName         /\v<\S+>/ nextgroup=factorTupleSlotClassSkip skipempty contained
syn match   factorTupleSlotNameSkip     /\v%(\_\s+%(!>.*)?)*/ contains=@factorComment nextgroup=factorTupleSlotName transparent contained
syn match   factorTupleSlotClass        /\v<\S+>/ nextgroup=factorTupleSlotAttrSkip skipempty contained
syn match   factorTupleSlotClassSkip    /\v%(\_\s+%(!>.*)?)*/ contains=@factorComment nextgroup=@factorTupleSlotAttr,factorTupleSlotClass transparent contained
syn region  factorTupleSlot   matchgroup=factorTupleSlotDelims  start=/\v<\{>/                end=/\v<\}>/    contains=@factorComment,factorTupleSlotName,@factorTupleSlotAttr contained
"syn match   factorTupleClass            /\v<\S+>/ nextgroup=factorTupleSuperClass,factorTupleSlot contained
"syn region  factorTupleSuperClass  matchgroup=NONE     start=/\v%(\s+\<\s+)/     matchgroup=Identifier end=/\v<\S+>/   contains=@factorComment contained nextgroup=factorTupleSlot
syn region  factorTuple   matchgroup=factorTupleDelims          start=/\v<%(TUPLE|BUILTIN|ERROR):>/ end=/\v<;>/     contains=@factorComment,factorTupleSlot
syn region  factorPredicate   matchgroup=factorPredicateDelims  start=/\v<%(PREDICATE):>/     end=/\v<;>/     contains=@factorComment,factorTupleSlot

syn match   factorStructSlotAttrBits    /\v<bits:>%(\_\s+%(!>.*)?)+/    contains=@factorComment nextgroup=factorWord,@factorReal contained
syn cluster factorStructSlotAttr        contains=@factorSlotAttr,factorStructSlotAttrBits
syn match   factorStructSlotName        /\v<\S+>/ nextgroup=factorStructSlotTypeSkip skipempty contained
syn match   factorStructSlotNameSkip    /\v%(\_\s+%(!>.*)?)*/ contains=@factorComment nextgroup=factorStructSlotName contained transparent
syn match   factorStructSlotType        /\v<\S+>/ contained
syn match   factorStructSlotTypeSkip    /\v%(\_\s+%(!>.*)?)*/ contains=@factorComment nextgroup=factorStructSlotType contained transparent
syn region  factorStructSlot      matchgroup=factorStructSlotDelims start=/\v<\{>/                   skip=/\v<!>.*/  end=/\v<\}>/ contains=@factorComment,factorStructSlotName,@factorStructSlotAttr contained
syn region  factorStruct          matchgroup=factorStructDelims     start=/\v<%(%(UNION-)?STRUCT):>/ skip=/\v<!>.*/  end=/\v<;>/  contains=@factorComment,factorStructSlot

syn region  factorAlias             start=/\v<ALIAS:>/           skip=/\v<!>.*/     end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment keepend
syn region  factorAlien             start=/\v<ALIEN:>/           skip=/\v<!>.*/     end=/\v>/       contains=@factorComment,@factorHexNoRadix
syn region  factorConstant          start=/\v<CONSTANT:>/        skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorDefer             start=/\v<DEFER:>/           skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorEbnf              start=/\v<EBNF:>/            skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorEditor            start=/\v<EDITOR:>/          skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorExclude           start=/\v<EXCLUDE:>/         skip=/\v<!>.*/     end=/\v<;>/     contains=@factorComment
syn region  factorForget            start=/\v<FORGET:>/          skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorFrom              start=/\v<FROM:>/            skip=/\v<!>.*/     end=/\v<;>/     contains=@factorComment
syn region  factorIn                start=/\v<IN:>/              skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorInstance          start=/\v<INSTANCE:>/        skip=/\v<!>.*/     end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment keepend
syn region  factorIntersection      start=/\v<INTERSECTION:>/    skip=/\v<!>.*/     end=/\v<;>/     contains=@factorComment
syn match   factorMain              /\v<MAIN:>/                  contains=@factorComment nextgroup=factorWord,factorQuotation
syn region  factorMixin             start=/\v<MIXIN:>/           skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorPostpone          start=/\v<POSTPONE:>/        skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorQualified         start=/\v<QUALIFIED:>/       skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorQualifiedWith     start=/\v<QUALIFIED-WITH:>/  skip=/\v<!>.*/     end=/\v<\S+%(\_\s+%(!>.*)?)+\S+>/   contains=@factorComment keepend
syn region  factorRename            start=/\v<RENAME:>/          skip=/\v<!>.*/     end=/\v<\S+%(\_\s+%(!>.*)?)+\S+%(\_\s+%(!>.*)?)+\=\>%(\_\s+%(!>.*)?)+\S+>/  contains=@factorComment keepend
syn region  factorSingleton         start=/\v<SINGLETON:>/       skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorSingletons        start=/\v<SINGLETONS:>/      skip=/\v<!>.*/     end=/\v<;>/     contains=@factorComment
syn region  factorSlot              start=/\v<SLOT:>/            skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorSymbol            start=/\v<SYMBOL:>/          skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorSymbols           start=/\v<SYMBOLS:>/         skip=/\v<!>.*/     end=/\v<;>/     contains=@factorComment
syn region  factorUnion             start=/\v<UNION:>/           skip=/\v<!>.*/     end=/\v<;>/     contains=@factorComment
syn region  factorUnuse             start=/\v<UNUSE:>/           skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorUse               start=/\v<USE:>/             skip=/\v<!>.*/     end=/\v<\S+>/   contains=@factorComment
syn region  factorUsing             start=/\v<USING:>/           skip=/\v<!>.*/     end=/\v<;>/     contains=@factorComment

syn cluster factorWordOps   contains=factorConstant,factorAlias,factorSingleton,factorSingletons,factorSymbol,factorSymbols,factorPostpone,factorDefer,factorForget,factorMixin,factorInstance,factorHook,factorMain

" C-ENUM:
" FUNCTION:
" TYPEDEF:
" LIBRARY:

if !exists('g:factor_syn_no_error')
  syn match   factorEffectRequired /\v<\V(\@!\v\S+>/    contained
endif
syn cluster factorEffectContents   contains=@factorComment,factorEffectDelims,factorEffectVar,factorEffectType,factorEffectRowVar
syn cluster factorEffect           contains=factorEffect
syn cluster factorEffectComment    contains=factorEffectComment
" Erroring on stack effects without a "--" separator would be nice.
" Unfortunately, that sort of vacuous detection is above Vim's pay-grade,
"   especially when stack effects can be nested arbitrarily via types.
syn match   factorEffectSkip       /\v%(\_\s+%(!>.*)?)*/ contains=@factorComment nextgroup=factorEffectRequired,@factorEffect transparent contained
syn region  factorEffect       matchgroup=factorEffectDelims    start=/\v\V(\v>/  end=/\v<\V)\v>/ contains=@factorEffectContents
syn region  factorEffectComment matchgroup=factorEffectCommentDelims   start=/\v\V((\v>/ end=/\v<\V))\v>/ contains=@factorEffectContents
syn match   factorEffectVar        /\v<\S+>/           contained
" Note that ":!" parses to the "!" word and doesn't lex as a comment.
" Also, even though we take any value, the leading ":" breaking the word
"   boundary means a lot of our nicer syntax patterns don't match on
"   "factorEffectType".
" syn cluster factorEffectType contains=factorWord,@factorEffect
syn cluster factorEffectType       contains=factorWord,@factorClusterValue
syn match   factorEffectTypeSkip   /\v%(\_\s+%(!>.*)?)*/ contains=@factorComment nextgroup=@factorEffectType transparent contained
syn match   factorEffectVar        /\v<\S+:>/          nextgroup=factorEffectTypeSkip skipempty contained
syn match   factorEffectType       /\v<:/              nextgroup=@factorEffectType contained
syn match   factorEffectRowVar     /\v<\.\.\S+>/       contained
syn match   factorEffectRowVar     /\v<\.\.\S+:>/      nextgroup=factorEffectTypeSkip skipempty contained
syn match   factorEffectDelims     /\v<-->/            contained
if !exists('g:factor_syn_no_error')
  syn cluster factorEffectContents add=factorEffectError
  syn keyword factorEffectError    (                   contained
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
  syn region  factorArray         matchgroup=factorDelimiter start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=ALL
else
  syn cluster factorArray       contains=factorArray0
  syn region  factorArray0               matchgroup=hlLevel0 start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray1,factorQuotation1
  syn region  factorArray1     contained matchgroup=hlLevel1 start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray2,factorQuotation2
  syn region  factorArray2     contained matchgroup=hlLevel2 start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray3,factorQuotation3
  syn region  factorArray3     contained matchgroup=hlLevel3 start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray4,factorQuotation4
  syn region  factorArray4     contained matchgroup=hlLevel4 start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray5,factorQuotation5
  syn region  factorArray5     contained matchgroup=hlLevel5 start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray6,factorQuotation6
  syn region  factorArray6     contained matchgroup=hlLevel6 start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray7,factorQuotation7
  syn region  factorArray7     contained matchgroup=hlLevel7 start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray8,factorQuotation8
  syn region  factorArray8     contained matchgroup=hlLevel8 start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray9,factorQuotation9
  syn region  factorArray9     contained matchgroup=hlLevel9 start=/\v<[^ \"\[]*\{>/         end=/\v<\}>/    contains=@factorCluster,factorArray0,factorQuotation0
endif

syn region  factorSlotsSyntax   matchgroup=factorSlotsSyntaxDelims  start=/\v<%(get|set|set-slots|slots)\[>/    end=/\v<\]>/

if !exists('g:factor_syn_no_error')
  syn match   factorBracketError    /\v<\]>/
  syn match   factorBracketError    /\v<\}>/
endif

syn sync lines=100

if !exists('g:factor_syn_no_init')
  command -nargs=+ -bar HiLink hi def link <args>

  if !exists('g:factor_syn_no_error')
    HiLink factorBracketError           Error
    HiLink factorIntegerError           Error
    HiLink factorFloatError             Error
    HiLink factorRatioError             Error
    HiLink factorBinError               Error
    HiLink factorHexNoRadixError        Error
    HiLink factorHexError               Error
    HiLink factorOctError               Error
    HiLink factorEffectRequired         Error
    HiLink factorEffectError            Error
  endif

  HiLink   factorError                  Error
  HiLink   factorShebang                PreProc
  HiLink   factorComment                Comment
  HiLink   factorMultilineComment       Comment
  HiLink   factorTodo                   Todo
  HiLink   factorEffect                 Type
  HiLink   factorEffectComment          Type
  HiLink   factorEffectCommentDelims    Comment
  HiLink   factorEffectDelims           Delimiter
  HiLink   factorEffectVar              Identifier
  HiLink   factorEffectRowVar           factorEffectVar
  HiLink   factorEffectType             Type
  HiLink   factorInclude                Include
  HiLink   factorWord                   Keyword
  HiLink   factorCallDelims             Keyword
  HiLink   factorCallNextMethod         Keyword
  HiLink   factorOperator               Operator
  HiLink   factorFrySpecifier           Operator
  HiLink   factorLocalsSpecifier        Operator
  HiLink   factorBoolean                Boolean
  HiLink   factorBreakpoint             Debug
  HiLink   factorInit                   Typedef
  HiLink   factorDefnDelims             Typedef
  HiLink   factorDeclDelims             Typedef
  HiLink   factorPrivate                Special
  HiLink   factorPDefnDelims            Special
  HiLink   factorPDeclDelims            Special
  HiLink   factorEscape                 SpecialChar
  HiLink   factorString                 String
  HiLink   factorStringDelims           factorString
  HiLink   factorNamedString            String
  HiLink   factorNamedStringDelims      Typedef
  HiLink   factorComplex                Number
  HiLink   factorRatio                  Number
  HiLink   factorBin                    Number
  HiLink   factorHexNoRadix             Number
  HiLink   factorHex                    Number
  HiLink   factorNan                    Number
  HiLink   factorOct                    Number
  HiLink   factorFloat                  Float
  HiLink   factorInteger                Number
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
  HiLink   factorColor                  Constant
  HiLink   factorDelimiter              Delimiter
  HiLink   factorBackslash              Special
  HiLink   factorMBackslash             Special
  HiLink   factorLiteral                Special
  HiLink   factorDeclaration            Typedef
  HiLink   factorSymbol                 Define
  HiLink   factorSymbols                Define
  HiLink   factorConstant               Define
  HiLink   factorAlias                  Define
  HiLink   factorSingleton              Typedef
  HiLink   factorSingletons             Typedef
  HiLink   factorMixin                  Typedef
  HiLink   factorInstance               Typedef
  HiLink   factorHook                   Typedef
  HiLink   factorMain                   Define
  HiLink   factorPostpone               Define
  HiLink   factorHelp                   Define
  HiLink   factorDefer                  Define
  HiLink   factorEbnf                   Typedef
  HiLink   factorEditor                 Typedef
  HiLink   factorForget                 Define
  HiLink   factorAlien                  Define
  HiLink   factorSlot                   Define
  HiLink   factorIntersection           Typedef
  HiLink   factorRegexp                 Constant
  HiLink   factorSlot                   Typedef
  HiLink   factorSlotDelims             factorSlot
  HiLink   factorSlotName               Identifier
  HiLink   factorSlotClass              Type
  HiLink   factorSlotType               factorSlotClass
  HiLink   factorSlotAttr               Special
  HiLink   factorSlotAttrInitial        factorSlotAttr
  HiLink   factorSlotAttrReadOnly       factorSlotAttr
  HiLink   factorSlotsSyntaxDelims      Keyword
  HiLink   factorStructSlotAttr         factorSlotAttr
  HiLink   factorStructSlotAttrBits     factorStructSlotAttr
  HiLink   factorPredicate              Typedef
  HiLink   factorPredicateDelims        factorTuple
  HiLink   factorTuple                  Typedef
  HiLink   factorTupleDelims            factorTuple
  HiLink   factorTupleSlot              factorSlot
  HiLink   factorTupleClass             Identifier
  HiLink   factorTupleSlotDelims        factorSlotDelims
  HiLink   factorTupleSlotName          factorSlotName
  HiLink   factorTupleSlotClass         factorSlotClass
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

" vim: set ts=4 ft=vim et sw=2 isk+=/,\\ :
