local l=require"xplorlib"
local the= l.settings[[

Xplor: Bayesian active learning
(c) 2022 Tim Menzies <timm@ieee.org> Bsd-2 license

Usage: lua xplorgo.lua [Options]

Options:
 -b  --bins  minimum bin width                   = 16
 -f  --file  file with csv data                  = ../data/auto93.csv
 -g  --go    start-up example                    = nothing
 -h  --help  show help                           = false
 -k  --k     Bayes hack: low attribute frequency = 1
 -m  --m     Bayes hack: low class frequency     = 2
 -M  --Min   stop at n^Min                       = .5
 -r  --rest  expansion best to rest              = 5
 -S  --Some  How many items to keep per row      = 256
 -s  --seed  random number seed                  = 937162211]]

local betters,cat,coerce,csv  = l.betters, l.cat, l.coerce, l.csv
local fmt,gt,kap,keys,lt,map,o= l.fmt,l.gt,l.kap,l.keys,l.lt,l.map,l.o
local obj,oo,ordered,per,push = l.obj,l.oo,l.ordered,l.per,l.push
local rnd,sort                = l.rnd,l.sort 
local is = {}

-- ## Classes
local COLS,NUM,SYM,XY = obj"COLS", obj"NUM", obj"SYM", obj"XY"
local DATA,ROW        = obj"DATA", obj"ROW"

function DATA:new(t) --- constructor
   return { rows = {}, 
            cols = COLS(t) } end

function ROW:new(t) --- constructor
   return  {cells=t, cooked={}} end

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
  return {name= s,                    -- name of this column
          at  = n,                   -- offset for this column
          xlo = nlo,                 -- min x seen so far
          xhi = nhi or nlo,          -- max x seen so far
          y   = sym or SYM(n,s)} end -- y symbols see so far

-- ## COLS ----- ----- ---------------------------------------------------------
function is.skip(s)   return s:find":$"     end
function is.num(s)    return s:find"^[A-Z]" end
function is.goal(s)   return s:find"[!+-]$" end
function is.klass(s)  return s:find"!$"     end
function is.weight(s) return s:find"-$" and -1 or 1 end

function COLS:columns(cols,    col) 
  for n,s in pairs(cols.names) do
    col = (is.num(s) and NUM or SYM)(n,s)
    push(cols.all, col)
    if not is.skip(s) then
      if is.klass(s) then cols.klass= col end
      push(is.goal(s) and cols.y or cols.x, col) end end 
  return cols end

function COLS:add(row)
  for _,cols in pairs({self.x, self.y}) do
    for _,col in pairs(cols) do
       col:add(row.cells[col.at]) end end end

function load(from,  data) --- if string(from), read file. else, load from list
  local function fun(t)  -- first row is special (defines the DATA instance)
    if data then data:add(t) else data=DATA(t) end end
  if type(from)=="string" then csv(from, fun) else map(src or {}, fun) end
  return data end

-- ## DATA ----- ----- ---------------------------------------------------------
function DATA:clone(  t)
  local data = DATA(self.cols.names)
  for _,row in pairs(t or {}) do data:add(row) end
  return data end

function DATA:add(t) --- add a new row, update column summaries.
  t = t.cells and t or ROW(t)
  push(self.rows,t)
  self.cols:add(t)  end 

function DATA:sorted() --- sort `self.rows`
    return sort(self.rows, function(row1,row2,    s1,s2,x,y)
                             s1,s2,x,y=0,0
                             for _,col in pairs(self.cols.y) do
                               x = col:norm(row1.cells[col.at])
                               y = col:norm(row2.cells[col.at])
                               s1= s1 - math.exp(col.w * (x-y)/#self.cols.y)
                               s2= s2 - math.exp(col.w * (y-x)/#self.cols.y) end
                             return s1/#self.cols.y < s2/#self.cols.y end) end
                             
function DATA:bestRest(m, n,     best,rest,rows) --- divide `self.rows`
  best, rest, rows = {}, {}, self:sorted()
  for i = 1,m do push(best, rows[i]) end 
  for i = m+1,#rows, (#rows - m+1)/(n*m)//1 do push(rest, rows[i]) end
  return best, rest end 

function DATA:xys(m,n)
  local function xys(col,datas,      x,n,all,bin,xys)
    n,all,xys = 0,{},{}
    for y,data in pairs(datas) do
      for _,row in pairs(data.rows) do
        x = row.cells[col.at]
        if x ~= "?" then
          n        = n+1
          bin      = col:discretize(x) 
          xys[bin] = xys[bin] or push(all, XY(col.at,col.name,x)) 
          xys[bin]:add(x,y) end end end
    return col:merge(sort(all,lt"xlo"), 
                     n^the.Min) 
  end -------------------------
  local most,split     = -1,nil
  local best,rest,rows = self:bestRest(m,n)
  local B,R = #best, #rest
  local out = {}
  for _,col in pairs(self.cols.x) do
    for i,xy in pairs(xys(col,{best = self:clone(best),
                               rest = self:clone(rest)})) do
      push(out, {xy=xy, score=xy.y:score("best",B,R)}) end end
  return sort(out,gt"score") end

-- ## NUM  ----- ----- ---------------------------------------------------------
-- If you are happy
function NUM:add(x) --- Update 
  if x ~= "?" then
    self.n  = self.n + 1
    local d = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n<0 and 0 or (self.m2<0 and 0 or (self.m2/(self.n-1))^.5)
    if x > self.hi then self.hi = x end
    if x < self.lo then self.lo = x end end end

function NUM:mid() 
  return self.mu end

function NUM:div() 
  return self.sd end

function NUM:norm(n) --- normalize `n` 0..1 (in the range lo..hi)
  local lo,hi = self.lo,self.hi
  return (hi - lo) < 1E-9 and 0 or (n - lo)/(hi - lo) end

function NUM:discretize(n,    tmp) --- discretize `Num`s,rounded to (hi-lo)/bins
  tmp = (self.hi - self.lo)/(the.bins - 1)
  return self.hi == self.lo and 1 or math.floor(n/tmp+.5)*tmp end 

function NUM:merge(xys, nMin) --- Can we combine any adjacent ranges?
  local function try2Merge(t,n,u)
    while n <= #t do
      local a,b = t[n], t[n+1]
      local ab  = n < #t and a.y:simpler(b.y, nMin)
      u[1+#u]   = ab and XY(a.at, a.name, a.xlo, b.xhi, ab) or a
      n         = ab and n+2 or n+1 end
    return #t == #u and t or try2Merge(u,1,{}) 
  end ---------------------
  xys = try2Merge(xys,1,{})
  for n = 2,#xys do xys[n].xlo = xys[n-1].xhi end   -- fill in any gaps
  xys[1].xlo, xys[#xys].xhi = -math.huge, math.huge -- extend to +/- infinity
  return xys end

-- ## SYM  ----- ----- ---------------------------------------------------------
function SYM:add(s,  n) --- `n` times (default=1), update `self` with `s` 
  if s~="?" then 
    n = n or 1
    self.n  = self.n + n
    self.has[s] = n + (self.has[s] or 0) 
    if self.has[s] > self.most then
      self.most,self.mode = self.has[s], s end end end

function SYM:mid() return self.mode end
function SYM:div() return self:entropy() end

function SYM:discretize(x) return x end 
function SYM:merge(t,_)    return t end 

function SYM:entropy(     e,fun) --- entropy
  function fun(p) return p*math.log(p,2) end
  e=0; for _,n in pairs(self.has) do if n>0 then e=e-fun(n/self.n) end end
  return e end

function SYM:simpler(sym, tiny) --- is `self+sym` simpler than its parts?
  local whole = SYM(self.at, self.name)
  for x,n in pairs(self.has) do whole:add(x,n) end
  for x,n in pairs(sym.has)  do whole:add(x,n) end
  local e1, e2, e12 = self:entropy(), sym:entropy(), whole:entropy()
  if self.n < tiny or sym.n < tiny or e12 <= (self.n*e1 + sym.n*e2)/whole.n then 
    return whole end end

function SYM:score(want,B,R)
  local b,r,e = 0,0,1E-32
  for k,v in pairs(self.has) do if k==want then b=b+v else r=r+v end end
  b,r = b/(B+e), r/(R+e)
  return b^2 / (b+r) end

-- ## XY  ----- ----- ----------------------------------------------------------
function XY:__tostring() --- print
  local x,lo,hi,big = self.name, self.xlo, self.xhi, math.huge
  if     lo ==  hi  then return fmt("%s == %s", x, lo)
  elseif hi ==  big then return fmt("%s >  %s", x, lo)
  elseif lo == -big then return fmt("%s <= %s", x, hi)
  else                   return fmt("%s <  %s <= %s", lo,x,hi) end end

function XY:add(nx, sy) --- Extend `xlo`,`xhi` to cover `x`. Add `y` to `self.y`
  if nx~="?" then
    if nx < self.xlo then self.xlo=nx end
    if nx > self.xhi then self.xhi=nx end
    self.y:add(sy) end end

function XY:select(row,     x) --- Return true if `row` selected by `self`
  x = row.cells[self.at]
  if x =="?" then return true end ------------------ assume yes for unknowns
  if self.xlo==self.xhi and v==self.xlo then return true end     -- for symbols
  if self.xlo < x and x <= self.xhi     then return true end end -- for numerics

function XY:selects(rows) --- Return subset of `rows` selected by `self`
  return map(rows,function(row) if self:select(row) then return row end end) end

---------------------------------------------------------------
return {the=the, COLS=COLS, DATA=DATA, NUM=NUM, SYM=SYM, XY=XY}
