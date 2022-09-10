return require("lib").settings[[   

L5 : a little light learning library, in LUA
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua l5.lua [OPTIONS]

OPTIONS:
 -e  --eg       start-up example                      = nothing
 -b  --bins     max number of bins                    = 16
 -d  --dump     on test failure, exit with stack dump = false
 -f  --file     file with csv data                    = ../data/auto93.csv
 -h  --help     show help                             = false
 -m  --min      min size. If<1 then t^n else n.       = .5
 -n  --nums     number of nums to keep                = 512
 -p  --p        distance calculation coefficient      = 2
 -r  --rest     size of "rest" set                    = 3
 -s  --seed     random number seed                    = 10019
 -S  --sample   how many numbers to keep              = 512 ]]
--    
-- Coding Conventions
-- - Every file should start with `require"lib"`.
-- - Function argument conventions: 
--   -  two blanks denote optionas, four blanls denote locals:
--   -  prefix n,s,is,fun denotes number,string,bool,function; 
--   -  suffix s means list of thing (so names is list of strings)
--   -  c is a column index (usually)
-- - Code starts with a help string, from which we extract settings to the `the`
--  variable.
-- - Code ends with `eg`s, containing demo code. To run some example `x` then::
-- 
--     lua l5.lua -e x
