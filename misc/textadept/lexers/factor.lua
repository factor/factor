--[[
Lexer for the Factor programming language (http://factorcode.org)
Copyright 2013 Michael T. Richter <ttmrichter@gmail.com>

This program is free software and comes without any warranty, express nor
implied.  It is, in short, warranted to do absolutely nothing but (possibly)
occupy storage space.  You can redistribute it and/or modify it under the terms
of the Do What The Fuck You Want To Public License, Version 2, as published by
Sam Hocevar.  Consult http://www.wtfpl.net/txt/copying for full legal details.

BUGS
====
At this time the lexer is usable, but not perfect.  Problems include:
 * identifiers like (foo) get treated and coloured like stack declarations
 * other as-yet unknown display bugs  :-)

These make a few source files less than lovely and will be fixed as possible.
(Making syntax highlighting for a language as syntactically flexible as Factor
turns out to be a non-trivial task!)
]]

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = lpeg.P, lpeg.R, lpeg.S

local M = {_NAME = 'factor'}

-- General buliding blocks.
local pre = R'AZ'^1
local post = pre
local opt_pre = pre^-1
local opt_post = opt_pre

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local comment = token(l.COMMENT, P'#'^-1 * P'!' * l.nonnewline^0)

-- Strings.
local dq1_str = opt_pre * l.delimited_range('"', '\\')
local dq3_str = l.delimited_range('"""', '\\')
local string = token(l.STRING, dq1_str + dq3_str)

-- Numbers.
-- Note that complex literals like C{ 1/3 27.3 } are not covered by this lexer.
-- The C{ ... } notation is treated as an operator--to be specific a
-- "constructor" (for want of a better term).
local hex_digits       = R('09', 'af', 'AF')^1
local binary           = P'-'^-1 * P'0b' * S'01'^1
local octal            = P'-'^-1 * P'0o' * R'07'^1
local decimal          = P'-'^-1 * R'09'^1
local hexadecimal      = P'-'^-1 * P'0x' * hex_digits^1
local integer          = binary + octal + hexadecimal + decimal
local ratio            = decimal * P'/' * decimal
local dfloat_component = decimal * P'.' * decimal^-1
local hfloat_component = hexadecimal * (P'.' * hex_digits^-1)^-1
local float            = (dfloat_component * (S'eE' * decimal)^-1) +
                         (hfloat_component * S'pP' * decimal)      +
                         (ratio * P'.')                            +
                         (P'-'^-1 * P'1/0.')                       +
                         (P'0/0')

local number = token(l.NUMBER, (float + ratio + integer) * #ws)

-- Keywords.
-- Things like NAN:, USE:, USING:, POSTPONE:, etc. are considered keywords,
-- as are similar words that end in #.  Patterns like <<WORD ... WORD>> are
-- similarly considered to be "keywords" (for want of a better term).
local colon_words = pre * S':#' + S':;'^1
local angle_words = (P'<'^1 * post) +
                    (pre * P'>'^1)
local keyword = token(l.KEYWORD, (colon_words + angle_words) * #ws)

-- Operators.
-- The usual suspects like braces, brackets, angle brackets, parens, etc. are
-- considered to be operators.  They may, however, have prefixes like C{ ... }.
local constructor_words = opt_pre * P'{' + P'}' +
                          opt_pre * P'[' + P']' +
                          opt_pre * P'<' + P'>' +
                          pre     * P'(' + P')'
local stack_declaration = l.delimited_range('()')
local other_operators = S'+-*/<>'
local operator = token(l.OPERATOR, (stack_declaration +
                                   constructor_words +
                                   other_operators) * #ws)

-- Identifiers.
-- Identifiers can be practically anything but whitespace.
local symbols = S'`~!@#$%^&*()_-+={[<>]}:;X,?/'
local identifier = token(l.IDENTIFIER, (l.alnum + symbols)^1 * #ws)

M._rules = {
  {'keyword', keyword},
  {'whitespace', ws},
  {'string', string},
  {'comment', comment},
  {'number', number},
  {'operator', operator},
  {'identifier', identifier},
  {'any_char', l.any_char},
}

return M
