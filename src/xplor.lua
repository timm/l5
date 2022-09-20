local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;
local the,help={}, [[
XPLOR: Bayesian active learning
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua XPLOR.lua [OPTIONS]

OPTIONS:
 -f  --file  file with csv data                  = ../data/auto93.csv
 -g  --go    start-up example                    = nothing
 -h  --help  show help                           = false
 -k  --k     Bayes hack: low attribute frequency = 1
 -m  --m     Bayes hack: low class frequency     = 2
 -M  --Min   stop at n^Min                       = .5
 -r  --rest  expansion best to rest              = 5
 -S  --Some  How many items to keep per row      = 256
 -s  --seed  random number seed                  = 10019]]

local betters,coerce,csv,data1,fmt,is,kap,keys,locals,lt,map,med
local o,obj,oo,ordered,per,push,sd,sort 
local lib={betters=betters,coerce=coerce,csv=csv,fmt=fmt,is=is,
           kap=kap, keys=leys,lt=lt,map=map,med=med,
           o=o,obj=obj,oo=oo,ordered=ordered,per=per,push=push,
           sd=sd,some=some,sort=sort}

function obj(s,    t,i,new) 
  local isa=setmetatable
  function new(k,...) i=isa({},k); return isa(t.new(i,...) or i,k) end
  t={__tostring = function(x) return s..o(x) end}
  t.__index = t;return isa(t,{__call=new}) end

local COLS,DATA,NUM,SYM = obj"COLS", obj"DATA", obj"NUM", obj"SYM"

function DATA:new(t) --- constructor
   return  {names=t, 
           rows={}, 
           cols=COLS(t) } end

function COLS:new(t)
  return self:columns({names=t, 
                       klass=nil,
                       all={}, 
                       x={}, 
                       y={}}) end 

function NUM:new(n,s) --- constructor for summary of columns
  n,s = n or 0, s or ""
  return {n=0, 
          at=n, 
          name=s, 
          mu=0, m2=0, 
          lo=1E32, hi=-1E32, 
           w=is.weight(s)} end

function SYM:new(n,s) --- summarize stream of symbols
  return {n=0, at=n, name=s, 
          mode=nil, 
          most=-1, 
          has={}} end

function XY:new(n,s,nlo,nhi,sym) --- Keep the `y` values from `xlo` to `xhi`
  return {txt= s,                    -- name of this column
          at  = n,                   -- offset for this column
          xlo = nlo,                 -- min x seen so far
          xhi = nhi or nlo,          -- max x seen so far
          y   = sym or Sym(n,s)} end -- y symbols see so far

-- ## COLS ----- ----- ---------------------------------------------------------
function is.skip(s)   return s:find":$"     end
function is.num(s)    return s:find"^[A-Z]" end
function is.goal(s)   return s:find"[!+-]$" end
function is.klass(s)  return s:find"!$"     end
function is.weight(s) return s:find"-$" and -1 or 1 end

function COLS:columns(cols) 
  for n,s in pairs(cols.names) do
    col = (is.num(s) and NUM or SYM)(n,s)
    push(cols.all, col)
    if not is.skip(s) then
      if is.klass(s) then cols.klass= col end
      push(is.goal(s) and cols.y and cols.x, col) end end 
  return cols end

function COLS:add(t)
  for _,cols in pairs({self.x, self.y}) do
    for _,col in pairs(cols) do
       col:add(t[col.at]) end end end

-- ## DATA ----- ----- ---------------------------------------------------------
function DATA:of(fun) --- return columns that satisfy `fun`
  return map(self.cols,function(c) if fun(c.name) then return c end end) end

function DATA:add(t) --- add a new row, update column summaries.
  push(self.rows,t)
  self.cols:add(t) end

function DATA:sorted(      order,goals) --- sort `self.rows`
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

function DATA:bestRest(m,n,     best,rest,rows) --- divide `self.rows`
  best, rest, rows = {}, {}, self:sorted()
  for i = 1,m do push(best, rows[i]) end 
  for i = m+1,#rows, (#rows - m+1)/(n*m)//1 do push(rest, rows[i]) end
  return best, rest end 
 
function DATA:xys(col,datas)
  local n,all,xys = 0,{},{}
  for y,data in pairs(datas) do
    for _,row in pairs(data.rows) do
      local x = row[col.at]
      if x=="?" then
        n = n+1
        local bin = col:discretize(x) 
        xys[bin] = xys[bin] or push(all, XY(col.at,col.txt,x)) 
        xys[bin]:add(x,y) end end end
  all = sort(all,lt"xlo")
  return col:merge(all, n^the.Min) end

-- ## NUM  ----- ----- ---------------------------------------------------------
function NUM:add(x) --- Update 
  if x ~= "?" then
    self.n  = self.n + 1
    local d = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n<0 and 0 or (self.m2<0 and 0 or (self.m2/(self.n-1))^.5)
    if x > self.hi then self.hi = x end
    if x < self.lo then self.lo = x end end end

function NUM:norm(n) --- normalize `n` 0..1 (in the range lo..hi)
  local lo,hi = self.lo,self.hi
  return (hi - lo) < 1E-9 and 0 or (n - lo)/(hi - lo) end

function NUM:discretize(n,    tmp) --- discretize `Num`s,rounded to (hi-lo)/bins
  tmp = (self.hi - self.lo)/(the.bins - 1)
  return self.hi == self.lo and 1 or math.floor(n/tmp+.5)*tmp end 

function NUM:merge(xys,nMin,    try2Merge) --- Can we combine any adjacent ranges?
  function try2Merge(t,    n,u,merged)
    while n <= #t do
      local a,b       = t[n], t[n+1]
      local mergedSym = n < #t and a.y:simpler(b.y, nMin)
      u[1+#u]         = mergedSym or XY(col.at,col.name,a.xlo,b.xhi,mergedSym)
      n               = mergedSym and n+2 or n+1 end
    return #t == #u and t or look4Merges(u) 
  end --------------------
  xys = try2Merge(xys,1,{})
  for n = 2,#xys do xys[n].xlo = xys[n-1].xhi end   -- fill in any gaps
  xys[1].xlo, xys[#xys].xhi = -math.huge, math.huge -- extend to +/- infinity
  return xys end

-- ## SYM  ----- ----- ---------------------------------------------------------
function SYM:add(s,  n) --- `n` times (default=1), update `self` with `s` 
  if s~="?" then 
    inc = n or 1
    self.n  = self.n + inc
    self.has[s] = inc + (self.has[s] or 0) 
    if self.has[s] > self.most then
      self.most,self.mode = self.has[s], s end end end

function SYM:discretize(x) return x end 
function SYM:merge(t)      return t end 

function Sym:entropy(     e,fun) --- entropy
  function fun(p) return p*math.log(p,2) end
  e=0; for _,n in pairs(self.has) do if n>0 then e=e-fun(n/self.n) end end
  return e end

function Sym:simpler(sym,tiny) --- replace self? is self+sym simpler than parts?
  local whole = Sym(self.at, self.txt)
  for x,n in pairs(self.has) do whole:add(x,n) end
  for x,n in pairs(sym.has)  do whole:add(x,n) end
  local e1, e2, e12 = self:entropy(), sym:entropy(), whole:entropy()
  if self.n < tiny or sym.n < tiny or e12 <= (self.n*e1 + sym.n*e2)/whole.n then 
    return whole end end

-- ## XY  ----- ----- ----------------------------------------------------------
function XY:__tostring() --- print
  local x,lo,hi,big = self.txt, self.xlo, self.xhi, math.huge
  if     lo ==  hi  then return fmt("%s == %s", x, lo)
  elseif hi ==  big then return fmt("%s >  %s", x, lo)
  elseif lo == -big then return fmt("%s <= %s", x, hi)
  else                   return fmt("%s <  %s <= %s", lo,x,hi) end end

function XY:add(x,y) --- Update `xlo`,`xhi` to cover `x`. And add `y` to `self.y`
  if x~="?" then
    if x < self.xlo then self.xlo=x end
    if x > self.xhi then self.xhi=x end
    self.y:add(y) end end

function XY:select(row,     x) --- Return true if `row` selected by `self`
  x = row[self.at]
  if x =="?" then return true end ------------------ assume yes for unknowns
  if self.xlo==self.xhi and v==self.xlo then return true end     -- for symbols
  if self.xlo < x and x <= self.xhi     then return true end end -- for numerics

function XY:selects(rows) --- Return subset of `rows` selected by `self`
  return map(rows,function(row) if self:select(row) then return row end end) end

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

-- ### Misc
function load(src,  data,     row)
  function fun(t) if data then data:add(t) else data=DATA(t) end end
  if type(src)=="table" then csv(src, fun) else map(src or {}, fun) end
  return data end

function cli(t) --- update table slots via command-line flags
  for k,v in pairs(t) do
    local v=tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(k:sub(1,1)) or x=="--"..k then
         v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end 
  t[k] = coerce(v) end end

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
-- do this next line, always
help:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)", function(k,v) 
                                                           the[k]=coerce(v) end)

the=cli(the)                              -- update `the` from command line
if the.help then os.exit(print(help)) end -- maybe print help
--go.csv()                                -- run demos
--go.sorted()
go.bestRest()

-- do these next two line, always
for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end
return {lib=lib, the=the, COLS=COLS,DATA=DATA,NUM=NUM,SYM=SYM,XY=XY} 
