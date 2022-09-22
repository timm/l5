local tbl,obj,is={},{},{}
local dump,lines,main,of,pretty,trim

tbl={}
obj={["funs"]="[fun]"}

function hint(s1,type) --- if we know a type, add to arg. Else return arg
    return type and s1..":`"..type .. "`" or s1 end

function of(s)  --- try all the things
  return obj[s] or is.str(s) or is.num(s) or is.tbl(s) or is.bool(s) or is.fun(s) end

is={}
function is.bool(s) if s:sub(1,2)=="is"     then return "bool" end end
function is.fun(s)  if s:sub(#s - 2)=="fun" then return "fun" end end
function is.num(s)  if s:sub(1,1)=="n"      then return "num" end end
function is.str(s)  if s:sub(1,1)=="s"      then return "str"  end end
function is.tbl(s)  if s=="t"               then return "tab" end end

function pretty(s) --- clean up the signature
    return s:gsub("[,]?    .*", ")")
            :gsub(":new()",    "")
            :gsub("([^, ()]+)", function(s1) 
                                  s1=trim(s1); return hint(s1,of(s1)) end) end

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

function trim(s) --- kill leading, trailing space
  return s:match"^%s*(.-)%s*$" end 

-- Main
for _,file in ipairs(arg) do
  print("\n#",file,"\n")
  lines(file,function(line)
    line:gsub("[A-Z][A-Z]+",      
              function(x) obj[x:lower()]=x 
                          obj[x:lower().."s"]="["..x.."]" end)
    if line:find"^[-][-] " then
      line:gsub("^[-][-] ([^\n]+)", 
                function(x) dump(); print(x:gsub("[-][-][-][-][-].*",""),"") end) 
    else  
      line:gsub("^function[%s]+([^-]+)[-][-][-] ([^\n]+)",
                function(lhs,rhs) tbl[1+#tbl] = {pretty(lhs),rhs} end) end end) 
  dump() end 
