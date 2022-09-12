return require("lib").settings[[   

L5 : a lean little learning library, in LUA
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua l5.lua [OPTIONS]

OPTIONS:
 -e  --eg       start-up example                      = nothing
 -b  --bins     max number of bins                    = 16
 -d  --dump     on test failure, exit with stack dump = false
 -f  --file     file with csv data                    = ../data/auto93.csv
 -F  --Far      how far to look for poles (max=1)     = .95
 -h  --help     show help                             = false
 -m  --min      min size. If<1 then t^n else n.       = .5
 -n  --nums     number of nums to keep                = 512
 -p  --p        distance calculation coefficient      = 2
 -r  --rest     size of "rest" set                    = 3
 -s  --seed     random number seed                    = 10019
 -S  --Sample   how many numbers to keep              = 512 ]]
--    
-- ### Coding Conventions
--
-- |What|Notes|
-- |:---:|-----|
-- |`require"lib"`| Every file should start with `require"lib"`.|
-- | 2 blanks| 2 blanks denote optional arguments|
-- | 4 blanks  | 4 blanls denote local arguments|
-- | n         | prefix for numerics|
-- | s         | prefix for strings|
-- | is        | prefix for bools|
-- |fun        | preffix for functions|
-- | suffix s  | list of thing (so names is list of strings) |
-- |  c        | column index (usually) |
-- | help string|Found at start of code. Parse to extract settings.|
-- | eg.x      | Place for demos.  To run, use `lua l5.lua -e x`|
