if arg[1]=="-h" or arg[1]=="--help" then os.exit(print[[
readme.lua: Assumes a simple Hungarian notation. Infer doco from LUA files
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2clause license

Usage: lua readme.lua  [-h] [file1.lua file2.lua ...] > doco.md

Options:
 -h --help Show help]]) end

-- Assumptions:
--  
-- 1. Lines with Markdown start with `-- ` (and  we will print those).
-- 2. We only show help on public function.
-- 3. Public functions are denoted with a  trailing "-->", followed by 
--    return type then some comment text. e.g.     
--    `function fred(s) --> str; Returns `s`, written as a string`   
--    Note the semi-colon. Do not skip it (its important).
-- 4. In public function arguments, lower case versions of class type 
--    (e.g. `data`) are instances of that type (e.g.  `data` are `DATA` 
--    so `datas` is a list of `DATA` instances).
-- 5  Built in types are num, str, tab, bool, fun
-- 6. User-defined types are ny word starting with two upper case 
--    leading letters is a class; e.g. DATA
-- 7. Public function arguments have the following type hints:
--    
-- | What        | Notes                                         |                                     
-- |:------------|:----------------------------------------------|
-- | 2 blanks    | 2 blanks denote start of optional arguments   |
-- | 4 blanks    | 4 blanks denote start of local arguments      |
-- | n           | prefix for numerics                           |
-- | s           | prefix for strings                            |
-- | is          | prefix for booleans                           |
-- | suffix fun  | suffix for functions                          |                      
-- | suffix s    | list of thing (so `names` is list of strings) |]]) end
--     
--------------------------------------------------------------------------------
local tbl= {} -- table of contents. dumped  (then reset) before every new heading
local obj= {} -- upper case class names
local are = {} -- type hint rules

-- ## Guessing types
function are.of(s)  --> ?str;  top level, tries all types
  return are.plural(s) or are.singular(s) end

function are.bool(s) --> ?"bool"; names starting with "is" are booleans
  if s:sub(1,2)=="is"     then return "bool" end end
function are.fun(s)  --> ?"fun"; names ending in "fun" are functions
  if s:sub(#s - 2)=="fun" then return "fun" end end
function are.num(s) --> ?"n"; names start with "n" are numbers 
  if s:sub(1,1)=="n"      then return "num" end end
function are.str(s) --> ?"s"; names starting with "s" are strings
 if s:sub(1,1)=="s"      then return "str"  end end
function are.tbl(s) --> ?"tab"; names ending the "s" are tables
 if s=="t"               then return "tab" end end

function are.plural(s) 
  if #s>1 and s:sub(#s)=="s"  then  
    local what = are.singular(s:sub(1,#s-1))
    return what and "["..what.."]"  or "tab" end end

function are.singular(s) 
  return obj[s] or are.str(s) or are.num(s) or are.tbl(s) or are.bool(s) or are.fun(s) end

--------------------------------------------------------------------------------
-- ## Low-level utilities
local dump,pretty,lines,dump
function hint(s1,type) --> str; if we know a type, add to arg (else return arg)
    return type and s1..":`"..type .. "`" or s1 end

function pretty(s) --> str; clean up the signature (no spaces, no local vars)
  return s:gsub("    .*",     "")
          :gsub(":new()",     "")
          :gsub("([^, \t]+)", function(s1) return hint(s1,are.of(s1)) end) end

function optional(s) --> str; removes local vars, returns the rest as a string
  local after,t = "",{}
  for s1 in s:gmatch("([^,]+)") do 
      if s1:find"  " then after="?" end
      t[1+#t] = s1:gsub("[%s]*$",after) end
  return table.concat(t,", ") end

function lines(sFilename, fun) --> nil; call `fun` on csv rows.
  local src  = io.input(sFilename)
  while true do
    local s = io.read()
    if s then fun(s) else return io.close(src) end end end

function dump() --> nil; if we have any tbl contents, print them then zap tbl
  if #tbl>0 then
    print("\n| What | Notes |\n|:---|:---|")
    for _,two in pairs(tbl) do print("| "..two[1].." | ".. two[2] .." |") end 
    print"\n" end
  tbl={} end 

--------------------------------------------------------------------------------
-- ## Main
function main() --> nil; for all lines on command line, print doco to standard output
  for _,file in ipairs(arg) do
    print("\n#",file,"\n")
    lines(file,function(line)
      if line:find"^[-][-] " then
        line:gsub("^[-][-] ([^\n]+)", 
                  function(x) dump(); -- dump anything hat needs to go
                              print(x:gsub(" [-][-][-][-][-].*",""),"") end) 
      else  
        line:gsub("[A-Z][A-Z]+", function(x) obj[x:lower()]=x end)
        line:gsub("^function[%s]+([^(]+)[(]([^)]*).*[-][-][>]([^;]+);(.*)",
                  function(fun,args,returns,comment) 
                     tbl[1+#tbl]={"<b>"..fun..'('..optional(pretty(args))..') &rArr; '..returns..'</b>',comment} 
                     end) end end) 
    dump() end  end

main()
