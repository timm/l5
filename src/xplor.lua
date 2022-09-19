local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;
local the,help={}, [[
XPLOR: Bayesian active learning
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua XPLOR.lua [OPTIONS]

OPTIONS:
 -f  --file  file with csv data                     =../data/auto93.csv
 -g  --go    start-up example                       =nothing
 -h  --help  show help                              =false
 -k  --k     Bayes hack: low attribute frequency    =1
 -m  --m     Bayes hack: low class frequency        =2
 -s  --seed  random number seed                     =10019]]

local coerce,csv,fmt,kap,map,push,sort,slots
fmt = string.format

function push(t,x)   table.insert(t,x); return t end
function sort(t,fun) table.sort(t,fun); return t end

function map(t1,fun)  
  local t2={}; for _,v in pairs(t1) do t2[1+#t2] = fun(v) end; return t2 end

function kap(t1,fun)  
  local t2={}; for k,v in pairs(t1) do t2[k] = fun(k,v) end; return t2 end

function slots(t)  
  return sort(kap(t,function(k,_) 
                     if tostring(k):sub(1,1) ~= "_" then return k end end)) end

function oo(t) print(o(t)) end 
function o(t) 
  t= #t>0 and map(t,tostring) 
          or  kap(slots(t),function(k,v) return fmt(":%s %s",k,t[k]) end) 
  return "{".. table.concat(t,", ") .."}" end

function coerce(s,    fun) --- Parse `the` config settings from `help`.
  function fun(s1)
    if s1=="true"  then return true end 
    if s1=="false" then return false end
    return s1 end 
  return math.tointeger(s) or tonumber(s) or fun(s:match"^%s*(.-)%s*$") end

function csv(sFilename, fun,      src,s,t) --- call `fun` cells in each CSV line
  src  = io.input(sFilename)
  while true do
    s = io.read()
    if   s 
    then t = {}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=coerce(s1) end; fun(t)
    else return io.close(src) end end end

help:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+=([%S]+)", function(k,v) 
  for n,x in ipairs(arg) do
    if x=="-"..(k:sub(1,1)) or x=="--"..k then
      v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
  the[k]=coerce(v) end)

if the.help then os.exit(print(help)) end

csv(the.file,oo)
