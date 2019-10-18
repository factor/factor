! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms ; with or without
! modification ; are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice ;
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice ;
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES ;
! INCLUDING ; BUT NOT LIMITED TO ; THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT ; INDIRECT ; INCIDENTAL ;
! SPECIAL ; EXEMPLARY ; OR CONSEQUENTIAL DAMAGES (INCLUDING ; BUT NOT LIMITED TO ;
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE ; DATA ; OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY ;
! WHETHER IN CONTRACT ; STRICT LIABILITY ; OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE ; EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: sdl-keyboard
USE: namespaces

! Here we smash left/right control/shift/alt for convinience.
! Later, something better needs to be done.

SYMBOL: modifiers

[
    [[ "SHIFT" HEX: 0001 ]]
    [[ "SHIFT" HEX: 0002 ]]
    [[ "CTRL"  HEX: 0040 ]]
    [[ "CTRL"  HEX: 0080 ]]
    [[ "ALT"   HEX: 0100 ]]
    [[ "ALT"   HEX: 0200 ]]
    [[ "META"  HEX: 0400 ]]
    [[ "META"  HEX: 0800 ]]
    [[ "NUM"   HEX: 1000 ]]
    [[ "CAPS"  HEX: 2000 ]]
    [[ "MODE"  HEX: 4000 ]]
] modifiers set

SYMBOL: keysyms

{{
    ! The keyboard syms have been cleverly chosen to map to ASCII
    [[ 0  "UNKNOWN"    ]]
!    [[ 0  "FIRST"      ]]
    [[ 8  "BACKSPACE"  ]]
    [[ 9  "TAB"        ]]
    [[ 12 "CLEAR"      ]]
    [[ 13 "RETURN"     ]]
    [[ 19 "PAUSE"      ]]
    [[ 27 "ESCAPE"     ]]
    [[ 32 "SPACE"      ]]
    [[ 33 "EXCLAIM"    ]]
    [[ 34 "QUOTEDBL"   ]]
    [[ 35 "HASH"       ]]
    [[ 36 "DOLLAR"     ]]
    [[ 38 "AMPERSAND"  ]]
    [[ 39 "QUOTE"      ]]
    [[ 40 "LEFTPAREN"  ]]
    [[ 41 "RIGHTPAREN" ]]
    [[ 42 "ASTERISK"   ]]
    [[ 43 "PLUS"       ]]
    [[ 44 "COMMA"      ]]
    [[ 45 "MINUS"      ]]
    [[ 46 "PERIOD"     ]]
    [[ 47 "SLASH"      ]]
    [[ 48 0 ]]
    [[ 49 1 ]]
    [[ 50 2 ]]
    [[ 51 3 ]]
    [[ 52 4 ]]
    [[ 53 5 ]]
    [[ 54 6 ]]
    [[ 55 7 ]]
    [[ 56 8 ]]
    [[ 57 9 ]]
    [[ 58 "COLON" ]]
    [[ 59 "SEMICOLON" ]]
    [[ 60 "LESS" ]]
    [[ 61 "EQUALS" ]]
    [[ 62 "GREATER" ]]
    [[ 63 "QUESTION" ]]
    [[ 64 "AT" ]]
    ! Skip uppercase letters
    [[ 91 "LEFTBRACKET" ]]
    [[ 92 "BACKSLASH" ]]
    [[ 93 "RIGHTBRACKET" ]]
    [[ 94 "CARET" ]]
    [[ 95 "UNDERSCORE" ]]
    [[ 96 "BACKQUOTE" ]]
    [[ 97 "a" ]]
    [[ 98 "b" ]]
    [[ 99 "c" ]]
    [[ 100 "d" ]]
    [[ 101 "e" ]]
    [[ 102 "f" ]]
    [[ 103 "g" ]]
    [[ 104 "h" ]]
    [[ 105 "i" ]]
    [[ 106 "j" ]]
    [[ 107 "k" ]]
    [[ 108 "l" ]]
    [[ 109 "m" ]]
    [[ 110 "n" ]]
    [[ 111 "o" ]]
    [[ 112 "p" ]]
    [[ 113 "q" ]]
    [[ 114 "r" ]]
    [[ 115 "s" ]]
    [[ 116 "t" ]]
    [[ 117 "u" ]]
    [[ 118 "v" ]]
    [[ 119 "w" ]]
    [[ 120 "x" ]]
    [[ 121 "y" ]]
    [[ 122 "z" ]]
    [[ 127 "DELETE" ]]
    ! End of ASCII mapped keysyms
    ! International keyboard syms
    [[ 160 "WORLD_0" ]]           ! 0xA0
    [[ 161 "WORLD_1" ]]
    [[ 162 "WORLD_2" ]]
    [[ 163 "WORLD_3" ]]
    [[ 164 "WORLD_4" ]]
    [[ 165 "WORLD_5" ]]
    [[ 166 "WORLD_6" ]]
    [[ 167 "WORLD_7" ]]
    [[ 168 "WORLD_8" ]]
    [[ 169 "WORLD_9" ]]
    [[ 170 "WORLD_10" ]]
    [[ 171 "WORLD_11" ]]
    [[ 172 "WORLD_12" ]]
    [[ 173 "WORLD_13" ]]
    [[ 174 "WORLD_14" ]]
    [[ 175 "WORLD_15" ]]
    [[ 176 "WORLD_16" ]]
    [[ 177 "WORLD_17" ]]
    [[ 178 "WORLD_18" ]]
    [[ 179 "WORLD_19" ]]
    [[ 180 "WORLD_20" ]]
    [[ 181 "WORLD_21" ]]
    [[ 182 "WORLD_22" ]]
    [[ 183 "WORLD_23" ]]
    [[ 184 "WORLD_24" ]]
    [[ 185 "WORLD_25" ]]
    [[ 186 "WORLD_26" ]]
    [[ 187 "WORLD_27" ]]
    [[ 188 "WORLD_28" ]]
    [[ 189 "WORLD_29" ]]
    [[ 190 "WORLD_30" ]]
    [[ 191 "WORLD_31" ]]
    [[ 192 "WORLD_32" ]]
    [[ 193 "WORLD_33" ]]
    [[ 194 "WORLD_34" ]]
    [[ 195 "WORLD_35" ]]
    [[ 196 "WORLD_36" ]]
    [[ 197 "WORLD_37" ]]
    [[ 198 "WORLD_38" ]]
    [[ 199 "WORLD_39" ]]
    [[ 200 "WORLD_40" ]]
    [[ 201 "WORLD_41" ]]
    [[ 202 "WORLD_42" ]]
    [[ 203 "WORLD_43" ]]
    [[ 204 "WORLD_44" ]]
    [[ 205 "WORLD_45" ]]
    [[ 206 "WORLD_46" ]]
    [[ 207 "WORLD_47" ]]
    [[ 208 "WORLD_48" ]]
    [[ 209 "WORLD_49" ]]
    [[ 210 "WORLD_50" ]]
    [[ 211 "WORLD_51" ]]
    [[ 212 "WORLD_52" ]]
    [[ 213 "WORLD_53" ]]
    [[ 214 "WORLD_54" ]]
    [[ 215 "WORLD_55" ]]
    [[ 216 "WORLD_56" ]]
    [[ 217 "WORLD_57" ]]
    [[ 218 "WORLD_58" ]]
    [[ 219 "WORLD_59" ]]
    [[ 220 "WORLD_60" ]]
    [[ 221 "WORLD_61" ]]
    [[ 222 "WORLD_62" ]]
    [[ 223 "WORLD_63" ]]
    [[ 224 "WORLD_64" ]]
    [[ 225 "WORLD_65" ]]
    [[ 226 "WORLD_66" ]]
    [[ 227 "WORLD_67" ]]
    [[ 228 "WORLD_68" ]]
    [[ 229 "WORLD_69" ]]
    [[ 230 "WORLD_70" ]]
    [[ 231 "WORLD_71" ]]
    [[ 232 "WORLD_72" ]]
    [[ 233 "WORLD_73" ]]
    [[ 234 "WORLD_74" ]]
    [[ 235 "WORLD_75" ]]
    [[ 236 "WORLD_76" ]]
    [[ 237 "WORLD_77" ]]
    [[ 238 "WORLD_78" ]]
    [[ 239 "WORLD_79" ]]
    [[ 240 "WORLD_80" ]]
    [[ 241 "WORLD_81" ]]
    [[ 242 "WORLD_82" ]]
    [[ 243 "WORLD_83" ]]
    [[ 244 "WORLD_84" ]]
    [[ 245 "WORLD_85" ]]
    [[ 246 "WORLD_86" ]]
    [[ 247 "WORLD_87" ]]
    [[ 248 "WORLD_88" ]]
    [[ 249 "WORLD_89" ]]
    [[ 250 "WORLD_90" ]]
    [[ 251 "WORLD_91" ]]
    [[ 252 "WORLD_92" ]]
    [[ 253 "WORLD_93" ]]
    [[ 254 "WORLD_94" ]]
    [[ 255 "WORLD_95" ]]           ! 0xFF
    ! Numeric keypad
    [[ 256 "KP0" ]]
    [[ 257 "KP1" ]]
    [[ 258 "KP2" ]]
    [[ 259 "KP3" ]]
    [[ 260 "KP4" ]]
    [[ 261 "KP5" ]]
    [[ 262 "KP6" ]]
    [[ 263 "KP7" ]]
    [[ 264 "KP8" ]]
    [[ 265 "KP9" ]]
    [[ 266 "KP_PERIOD" ]]
    [[ 267 "KP_DIVIDE" ]]
    [[ 268 "KP_MULTIPLY" ]]
    [[ 269 "KP_MINUS" ]]
    [[ 270 "KP_PLUS" ]]
    [[ 271 "KP_ENTER" ]]
    [[ 272 "KP_EQUALS" ]]
    ! Arrows + Home/End pad
    [[ 273 "UP" ]]
    [[ 274 "DOWN" ]]
    [[ 275 "RIGHT" ]]
    [[ 276 "LEFT" ]]
    [[ 277 "INSERT" ]]
    [[ 278 "HOME" ]]
    [[ 279 "END" ]]
    [[ 280 "PAGEUP" ]]
    [[ 281 "PAGEDOWN" ]]
    ! Function keys
    [[ 282 "F1" ]]
    [[ 283 "F2" ]]
    [[ 284 "F3" ]]
    [[ 285 "F4" ]]
    [[ 286 "F5" ]]
    [[ 287 "F6" ]]
    [[ 288 "F7" ]]
    [[ 289 "F8" ]]
    [[ 290 "F9" ]]
    [[ 291 "F10" ]]
    [[ 292 "F11" ]]
    [[ 293 "F12" ]]
    [[ 294 "F13" ]]
    [[ 295 "F14" ]]
    [[ 296 "F15" ]]
    ! Key state modifier keys
    [[ 300 "NUMLOCK" ]]
    [[ 301 "CAPSLOCK" ]]
    [[ 302 "SCROLLOCK" ]]
    [[ 303 "RSHIFT" ]]
    [[ 304 "LSHIFT" ]]
    [[ 305 "RCTRL" ]]
    [[ 306 "LCTRL" ]]
    [[ 307 "RALT" ]]
    [[ 308 "LALT" ]]
    [[ 309 "RMETA" ]]
    [[ 310 "LMETA" ]]
    [[ 311 "LSUPER" ]]           ! Left "Windows" key
    [[ 312 "RSUPER" ]]           ! Right "Windows" key
    [[ 313 "MODE" ]]           ! "Alt Gr" key
    [[ 314 "COMPOSE" ]]           ! Multi-key compose key
    ! Miscellaneous function keys
    [[ 315 "HELP" ]]
    [[ 316 "PRINT" ]]
    [[ 317 "SYSREQ" ]]
    [[ 318 "BREAK" ]]
    [[ 319 "MENU" ]]
    [[ 320 "POWER" ]]           ! Power Macintosh power key
    [[ 321 "EURO" ]]           ! Some european keyboards
    [[ 322 "UNDO" ]]           ! Atari keyboard has Undo
    ! Add any other keys here
}} keysyms set
