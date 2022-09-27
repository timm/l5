--------------------------------------------------------------------------------
local tbl= {} -- table of contents. dumped, then reset before every new heading
local obj= {} -- upper case class names
local is = {} -- type hint rules

function is.of(s)  --- try all the things
  return is.plural(s) or is.singular(s) end

function is.plural(s,   s1,what) 
  if #s>1 and s:sub(#s)=="s"  then  
    s1   = s:sub(1,#s-1)
    what = is.singular(s1)
    return what and "["..what.."]"  or "tab" end end

function is.singular(s) 
  return obj[s] or is.str(s) or is.num(s) or is.tbl(s) or is.bool(s) or is.fun(s) end

function is.bool(s) if s:sub(1,2)=="is"     then return "bool" end end
function is.fun(s)  if s:sub(#s - 2)=="fun" then return "fun" end end
function is.num(s)  if s:sub(1,1)=="n"      then return "num" end end
function is.str(s)  if s:sub(1,1)=="s"      then return "str"  end end
function is.tbl(s)  if s=="t"               then return "tab" end end

--------------------------------------------------------------------------------
-- hint utils
local dump,pretty,lines,dump
function hint(s1,type) --- if we know a type, add to arg. Else return arg
    return type and s1..":`"..type .. "`" or s1 end

function pretty(s) --- clean up the signature
  return s:gsub("    .*",     "")
          :gsub(":new()",     "")
          :gsub("([^, \t]+)", function(s1) return hint(s1,is.of(s1)) end) end

function optional(s)
  local after,t = "",{}
  for s1 in s:gmatch("([^,]+)") do 
      if s1:find"  " then after="?" end
      t[1+#t] = s1:gsub("[%s]*$",after) end
  return table.concat(t,", ") end

-- Low-level utils
function lines(sFilename, fun,      src,s) --- call `fun` on csv rows.
  src  = io.input(sFilename)
  while true do
    s = io.read()
    if s then fun(s) else return io.close(src) end end end

function dump() --- if we have any tbl contents, print them then zap tbl
  if #tbl>0 then
    print("\n| What | Notes |\n|:---|:---|")
    for _,two in pairs(tbl) do print("| "..two[1].." | ".. two[2] .." |") end 
    print"\n" end
  tbl={} end 

--------------------------------------------------------------------------------
-- Main
for _,file in ipairs(arg) do
  print("\n#",file,"\n")
  lines(file,function(line)
    if line:find"^[-][-] " then
      line:gsub("^[-][-] ([^\n]+)", 
                function(x) dump(); -- dump anything hat needs to go
                            print(x:gsub(" [-][-][-][-][-].*",""),"") end) 
    else  
      line:gsub("[A-Z][A-Z]+", function(x) obj[x:lower()]=x end)
      line:gsub("^function[%s]+([^(]+)[(]([^)]*).*[-][-][-](.*)",
                function(fun,args,comment) 
                   tbl[1+#tbl]={"<b>"..fun..'('..optional(pretty(args))..')</b>',comment} 
                   end) end end) 
  dump() end 
