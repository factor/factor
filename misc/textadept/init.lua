--[[
Sample init.lua for Textadept with the required "Jump to line" command line
option for the Textadept support in the Factor distribution.

This program is free software and comes without any warranty, express nor
implied.  It is, in short, warranted to do absolutely nothing but (possibly)
occupy storage space.  You can redistribute it and/or modify it under the terms
of the Do What The Fuck You Want To Public License, Version 2, as published by
Sam Hocevar.  Consult http://www.wtfpl.net/txt/copying for full legal details.
]]

_M.textadept = require 'textadept'

-- Add a "Jump to line" command line option.
function my_goto_line(line)
    _G.buffer:goto_line(line - 1)
end
args.register('-J', '--JUMP', 1, my_goto_line, 'Jump to line')
