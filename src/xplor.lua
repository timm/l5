local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;
local the,help={}, [[
XPLOR: Bayesian active learning
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua XPLOR.lua [OPTIONS]

OPTIONS:
 -f  --file  file with csv data                     = ../data/auto93.csv
 -g  --go    start-up example                       = nothing
 -h  --help  show help                              = false
 -k  --k     Bayes hack: low attribute frequency    = 1
 -m  --m     Bayes hack: low class frequency        = 2
 -S  --Some  How many items to keep per row         = 256
 -s  --seed  random number seed                     = 10019]]

local betters,coerce,count,csv,data1,DATA,fmt,is,kap,keys,locals,lt,map,norm
local o,oo,push,same,some1,SOME,somes,sort,slots,sum

-- ## Reading data
local _is={}
function _is.skip(s)  return s:find":$" end
function _is.num(s)   return  s:find"^[A-Z]" end
function _is.goal(s)  return  s:find"[!+-]$" end
function _is.klass(s) return  s:find"!$" end
function _is.weight(s)  return s:find"-$" and -1 or 1 end

-- ## NUM
function SOME(n,s) --- constructor for summary of numbers
  return {w=_is.weight(s or ""),at=n,name=s,_has={},isSorted=true,n=0} end

function some1(some,n,    pos)
  if n~="?" then
    some.n = some.n+1
    if #some._has < the.Some then pos=1+(#some._has)
    elseif math.random()<the.Some/some.n then pos=math.random(#some._has) end
    if pos then some.isSorted=false
                some._has[pos]= n end end end

function somes(some)
  if not some.isSorted then table.sort(some._has) end
  some.isSorted=true
  return some._has end

function norm(some,n,   t)
  t=somes(some)
  tmp =(t[#t] - t[1]) < 1E-9 and 0 or (n-t[1])/(t[#t] - t[1]) 
  return tmp
end

-- ## DATA
function DATA(t) 
   return {names=t,rows={},
           cols=kap(t,function(k,v) return SOME(k,t[k]) end)} end

function data1(t,  data) --- return data, incremented with row `t`
  if not data then data = DATA(t) else
    push(data.rows,t)
    map(data.cols, function(col) some1(col,t[col.at]) end) end
  return data end

function betters(data,   order,cols,n)
  cols = map(data.cols, function(col) if _is.goal(col.name) then return col end end)
  local s1,s2,x,y=0,0
  map(cols,oo)
  function order(row1,row2)
    for _,col in pairs(cols) do
      x,y= norm(col,row1[col.at]), norm(col,row2[col.at])
      s1 = s1 - 2.71828^(col.w * (x-y)/#cols)
      s2 = s2 - 2.71828^(col.w * (y-x)/#cols)  end
    return s1/#cols < s2/#cols end
  return sort(data.rows, order) end

-- ## Lib
-- ### Lists
function push(t,x)  --- push `x` onto `t`, return `x`
  table.insert(t,x); return t end

-- ### Sort
function sort(t,fun) --- return `t`, sorted using function `fun`. 
  table.sort(t,fun); return t end

function lt(x) --- return function that sorts ascending on key `x`
  return function(a,b) return a[x] < b[x] end end

-- ### String to thing
function coerce(s,    fun) --- Parse `the` config settings from `help`.
  function fun(s1)
    if s1=="true"  then return true end 
    if s1=="false" then return false end
    return s1 end 
  return math.tointeger(s) or tonumber(s) or fun(s:match"^%s*(.-)%s*$") end

function csv(sFilename, fun,      src,s,t) --- call `fun` on csv rows.
  src  = io.input(sFilename)
  while true do
    s = io.read()
    if   s 
    then t = {}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=coerce(s1) end; fun(t)
    else return io.close(src) end end end

-- ### Thing to String
function fmt(str,...) --- emulate printf
  return string.format(str,...) end

function oo(t)  --- Print a table `t` (non-recursive)
  print(o(t)) end 

function o(t) ---  Generate a print string for `t` (non-recursive)
  if type(t) ~= "table" then return tostring(t) end
  t = #t>0 and map(t,tostring)
            or map(keys(t),function(v) return fmt(":%s %s",v,o(t[v])) end)
  return "{".. table.concat(t," ") .."}" end

-- ### Meta
function map(t,fun) --- Return `t`, filter through `fun(value)` (skip nils)
  local u={}; for _,v in pairs(t) do u[1+#u] = fun(v) end; return u end

function kap(t,fun) --- Return `t` and its size, filtered via `fun(key,value)`
  local u={}; for k,v in pairs(t) do u[k]=fun(k,v) end; return u end

function keys(t) --- Return keys of `t`, sorted (skip any with prefix  `_`)
  return sort(kap(t,function(key,_)  
                if tostring(key):sub(1,1) ~= "_" then return key end end)) end

function locals () --- Return a list of local variables.
  local i,t = 1,{}
  while true do
    local k,v = debug.getlocal(2, i)
    if not k then break end
    if k:sub(1,1) ~= "_" then t[k]=v end
    i = i + 1 end
  return t end

-- -----------------------------------------------------------------------------
help:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)", function(k,v) 
  for n,x in ipairs(arg) do
    if x=="-"..(k:sub(1,1)) or x=="--"..k then
      v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
  the[k]=coerce(v) end)

if the.help then os.exit(print(help)) end

local go={}
function go.csv(      data)
  csv(the.file, function(row) data=data1(row,data)  end)
  oo(data.cols[1]) end 

function go.betters(      data,rows)
  csv(the.file, function(row) data=data1(row,data)  end)
  rows= betters(data) 
  for i=1,#rows,30 do print(i,o(rows[i])) end end

--go.csv()
go.betters()
for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end
local t=locals(); return t
