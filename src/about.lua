return require("lib").settings[[   

BOB : summarized csv file
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua bob.lua [OPTIONS]

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

-- ## Coding Conventions
-- 
-- Every file should start with `require"lib"`.
-- 
-- Function argument conventions: 
-- - 1. two blanks denote optionas, four blanls denote locals:
-- - 2. prefix n,s,is,fun denotes number,string,bool,function; 
-- - 3. suffix s means list of thing (so names is list of strings)
-- - 4. c is a column index (usually)
-- 
-- Code starts with a help string, from which we extract settings to the `the`
-- variable.
-- 
-- Code ends with `eg`s, containing demo code. The command line
-- 
--     lua eg.lua -e x
-- 
-- runs example `x`.
