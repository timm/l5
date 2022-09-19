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
local is={}
function is.skip(s)  return s:find":$" end
function is.num(s)   return not is.skip(s) and s:find"^[A-Z]" end
function is.goal(s)  return not is.skip(s) and s:find"[!+-]$" end
function is.klass(s) return not is.skip(s) and s:find"!$" end
function is.weight(s) 
   if s:find"-$" then return -1 end
   if s:find"+$" then return  1 end end

fmt = string.format

function push(t,x)   table.insert(t,x); return t end
function sort(t,fun) table.sort(t,fun); return t end

function sum(t,fun)  
  local n=0; for _,v in pairs(t) do n=n+fun(v) end; return n end
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

function locals (    t,i)
  local i,t = 1,{}
  while true do
    local k,v = debug.getlocal(2, i)
    if not k then break end
    if k:sub(1,1) ~= "_" then t[k]=v end
    i = i + 1 end
  return t end

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

function ord(x,y) 
  x= type(x)=="string" and math.huge or x
  y= type(y)=="string" and math.huge or y
  return x < y end

function num1(num,n)
  if n ~="!" then 
    num.lo = num.lo and math.minif n < num.lo then num.lo=n end
    if n > num.hi then num.hi=n end end end

function row1(d,row)
  if d then
    push(d.rows,row)
    kap(d.nums,function(k,num) num1(num,row[k]) end)
  else 
    d={head=row, rows={}}
    d.nums = kap(row,function(k,v) if is.num(v) then return {} end end) end 
  return d end

d=nil
csv(the.file, function(row) d=row1(d,row) end)
oo(d)

-- function betters(rows,nums) --- order two rows
--   n    = sum(cols,function(_) return 1 end)
--   function order(row1,row2)
--     for c,w in pairs(cols) do
--       x,y= row1[c], row2[c]
--       x,y= col:norm(x), col:norm(y)
--       s1 = s1 - math.exp(col.w * (x-y)/#ys)
--       s2 = s2 - math.exp(col.w * (y-x)/#ys) end
--   return s1/#ys < s2/#ys end
--
local t=locals(); return t
