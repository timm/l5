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

local coerce,count,csv,fmt,is,kap,keys,map
local o,oo,push,same,sort,slots,sum

-- ## Reading data
_is={}
function _is.skip(s)  return s:find":$" end
function _is.num(s)   return not _is.skip(s) and s:find"^[A-Z]" end
function _is.goal(s)  return not _is.skip(s) and s:find"[!+-]$" end
function _is.klass(s) return not _is.skip(s) and s:find"!$" end
function _is.weight(s) 
  if s:find"-$" then return -1 end
  if s:find"+$" then return  1 end end

function _ord(x,y) 
  x= type(x)=="string" and -math.huge or x
  y= type(y)=="string" and -math.huge or y
  return x < y end

-- ## NUM
function NUM() --- constructor for summary of numbers
  return {_has={},isSorted=true,n=0} end

function num1(num,n,    pos)
  if n~="?" then
    self.n = self.n+1
    if #self._has < the.Sample then pos=1+(#self._has)
    elseif math.random()<the.Sample/self.n then pos=math.random(#self._has) end
    if pos then self.isSorted=false
                self._has[pos]= n end end end

function nums(num)
  if not num.isSorted then table.sort(num._has) end
  num.isSorted=true
  return num._has end

-- ## DATA
function DATA(t) 
   return {names=t, rows={},
           nums=kap(t,
                    function(k,v) if is.num(v) then return NUM() end end)} end

function data1(t,  data) --- return data, incremented with row `t`
  if not data then data = DATA(t) else
    push(data.rows,t)
    kap(data.nums, function(k,num) num1(num,t[k]) end) end
  return data end

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
  t= #t>0 and map(t,tostring) 
          or  kap(slots(t),function(k,v) return fmt(":%s %s",k,t[k]) end) 
  return "{".. table.concat(t,", ") .."}" end

-- ### Meta
function same(x) --- return `x` 
  return x end

function count(t,fun)  --- Count how many Return sum of items in `t`, filtered via `fun` 
  return sum(t, function(v) return 1 end) end

function sum(t,fun)  --- Return sum of items in `t`, filtered via `fun` 
  local n=0; for _,v in pairs(t) do n=n+fun(v) end; return n end

function map(t,fun) --- Return `t`, filter through `fun(value)` (skip nils )
  local u={}; for _,v in pairs(t) do u[1+#u] = fun(v) end; return u end

function kap(t1,fun) --- Return `t`, filtered via `fun(key,value)`, (skip nils) 
  local t2={}; for k,v in pairs(t1) do t2[k] = fun(k,v) end; return t2 end

function keys(t) --- Return keys of `t`, sorted (skip any with prefix  _`)
  return sort(kap(t,function(key,_) 
                if tostring(key):sub(1,1) ~= "_" then return key end end)) end

function locals (    t,i) --- Return a list of local variables.
  local i,t = 1,{}
  while true do
    local k,v = debug.getlocal(2, i)
    if not k then break end
    if k:sub(1,1) ~= "_" then t[k]=v end
    i = i + 1 end
  return t end

-- -----------------------------------------------------------------------------
help:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+=([%S]+)", function(k,v) 
  for n,x in ipairs(arg) do
    if x=="-"..(k:sub(1,1)) or x=="--"..k then
      v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
  the[k]=coerce(v) end)

if the.help then os.exit(print(help)) end

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
