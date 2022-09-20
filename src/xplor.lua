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
 -r  --rest  expansion best to rest                 = 5
 -S  --Some  How many items to keep per row         = 256
 -s  --seed  random number seed                     = 10019]]

local betters,coerce,csv,data1,DATA,ent,fmt,is,kap,keys,locals,lt,map,med,norm
local o,of,oo,ordered,per,push,sd,some1,COL,sort,sorted 
local function obj(s,    t,i,new) 
  local isa=setmetatable
  function new(k,...) i=isa({},k); return isa(t.new(i,...) or i,k) end
  t={__tostring = function(x) return s..o(x) end}
  t.__index = t;return isa(t,{__call=new}) end

local COL, DATA = obj"COL", obj"DATA"

-- ## DATA ----- ----- ---------------------------------------------------------
local is={}
function is.skip(s)   return s:find":$"     end
function is.num(s)    return s:find"^[A-Z]" end
function is.goal(s)   return s:find"[!+-]$" end
function is.klass(s)  return s:find"!$"     end
function is.weight(s) return s:find"-$" and -1 or 1 end

function DATA:new(t) 
   return {names=t,rows={},
           cols=kap(t,function(k,v) return COL(k,t[k]) end)} end

function DATA:of(fun)
  return map(self.cols,function(c) if fun(c.name) then return c end end) end

function DATA:add(t) --- return data, incremented with row `t`
  push(self.rows,t)
  map(self.cols, function(col) col:add(t[col.at]) end) end

function DATA:sorted(      order,goals)
  goals = self:of(is.goal)
  function order(row1,row2,    s1,s2,x,y)
    s1,s2,x,y=0,0
    for _,col in pairs(goals) do
      x  = col:norm(row1[col.at])
      y  = col:norm(row2[col.at])
      s1 = s1 - math.exp(col.w * (x-y)/#goals)
      s2 = s2 - math.exp(col.w * (y-x)/#goals)  end
    return s1/#goals < s2/#goals end
  return sort(self.rows, order) end

function DATA:bestRest(m,n,     best,rest,rows)
  best, rest, rows = {}, {}, self:sorted()
  for i = 1,m do push(best, rows[i]) end 
  for i = m+1,#rows, (#rows - m+1)/(n*m)//1 do push(rest, rows[i]) end
  return best, rest end 
 
-- ## COL  ----- ----- ---------------------------------------------------------
function COL:new(n,s) --- constructor for summary of columns
  return  {w=is.weight(s or ""),
             at=n,name=s,_has={},isSorted=false,freq={},n=0} end

function COL:add(x,    pos) --- keep, at most, `the.Some` items
  if x~="?" then
    self.n = self.n+1
    if #self._has < the.Some then pos = 1 + (#self._has)
    elseif math.random()<the.Some/self.n then pos=math.random(#self._has) end
    if pos then self.freq, self.isSorted = nil,nil
                self._has[pos]= x end end end

function COL:sorted() --- return `self`'s contents, sorted
  if not self.isSorted then table.sort(self._has) end
  self.isSorted=true
  return self._has end

function COL:counts()
  if not self.freq then
    self.freq={}
    for _,x in pairs(self._has) do self.freq=1+(self.freq[x]+0) end end
  return freq end

function COL:norm(n,    t) --- normalize `n` 0..1 (in the range lo..hi)
  t=self:sorted()
  return (t[#t] - t[1]) < 1E-9 and 0 or (n-t[1])/(t[#t] - t[1]) end

-- -----------------------------------------------------------------------------
-- ## Lib
-- ### Maths
function per(t,p) --- return the pth (0..1) item of `t`.
  p=math.floor(((p or .5)*#t)+.5); return t[math.max(1,math.min(#t,p))] end

function sd(t) --- return standard deviation of a sorted list `t`
  return (per(t,.9) - per(t,.1))/2.58 end

function med(t) --- return median of sorted list `t`
  return per(t,.5) end

function ent(t) --- entropy of a list of counts
  function fun(p) return p*math.log(p,2) end
  e=0; for _,n in pairs(t) do if n>0 then e=e-fun(n/self.n) end end
  return e end
 
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
    if s1=="true"  then return true  end
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

-- ### Misc
function load(src,  data,     row)
  function fun(t) if data then data:add(t) else data=DATA(t) end end
  if type(src)=="table" then csv(src, fun) else map(src or {}, fun) end
  return data end

function DATA:contrast(col,datas,      nump)
  local nunp,n,all,xys = is.num(col.name),0,{},{}
  for y,data in pairs(datas) do
    for _,row in pairs(data.rows) do
      local x = row[col.at]
      n = n+1
      local bin = nump and discretize(col,x) or x
      xys[bin] = xys[bin] or push(all, XY(col.at,col.txt,x)) 
      xys[bin]:add(x,y) end end 
  table.sort(all,lt"xlo")
  return nump and merge(all, n^the.Min) and all end

function discretize(col,n,    t,tmp) --- discretize `Num`s,rounded to (hi-lo)/bins
  t = col:sorted()
  tmp = (t[#t] - t[1])/(the.bins - 1)
  return t[#t]==t[1] and 1 or math.floor(n/tmp+.5)*tmp end 

function merge(xys,nMin,    tryMerging) --- Can we combine any adjacent ranges?
  function tryMerging(xys0,    n,xys1,merged)
    n,xys1 = 1,{}
    while n <= #xys0 do
      local mergedXY  = n<#xys0 and xys0[n]:merged(xys0[n+1], nMin)
      xys1[ 1+#xys1 ] = mergedXY or xys0[n]
      n               = mergedXY and n+2 or n+1 end
    return #xys1 < #xys1 and tryMerging(xys1) end
  xys = tryMerging(xys)
  for n = 2,#xys do xys[n].xlo = xys[n-1].xhi end   -- fill in any gaps
  xys[1].xlo, xys[#xys].xhi = -math.huge, math.huge -- extend to +/- infinity
  return xys end

-- -----------------------------------------------------------------------------
local go={}
function go.csv(      data)
  csv(the.file, function(t) if data then data:add(t) else data=DATA(t) end end)
  oo(data.cols[1]) end 

function go.sorted(      data,rows)
  csv(the.file, function(t) if data then data:add(t) else data=DATA(t) end end)
  rows= data:sorted() 
  for i=1,#rows,30 do print(i,o(rows[i])) end end

function go.bestRest(      data,rows)
  csv(the.file, function(t) if data then data:add(t) else data=DATA(t) end end)
  data:bestRest(20,3) end

function go.contrast(    data)
  csv(the.file, function(t) if data then data:add(t) else data=DATA(t) end end)
  best, rest = data:bestRest(20,3) 
end

-- -----------------------------------------------------------------------------
help:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)", function(k,v) 
  for n,x in ipairs(arg) do
    if x=="-"..(k:sub(1,1)) or x=="--"..k then
      v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
  the[k]=coerce(v) end)

if the.help then os.exit(print(help)) end

--go.csv()
--go.sorted()
go.bestRest()
for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end
local t=locals(); return t
