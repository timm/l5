local l=require"keyslib"
local the=l.options[[

KEYS: Bayesian multi-objective semi-supervised explanations
(c)2022 Tim Menzies <timm@ieee.org> BSD-2 license

  .-------.                dispute: where bad==better
  | Ba    | Bad <----.     plan   : better - bad
  |    56 |          |     watch  : bad - better
  .-------.------.   |     explore: where bad and better is scarce
          | Be   |   v  
          |    4 | Better
          .------.

Usage: lua keysgo.lua [Options]

Options:
 -a  --aim   aim: plan,watch,explore or dispute  = plan
 -b  --bins  minimum bin width                   = 16
 -B  --beam  beam size                           = 10
 -f  --file  file with csv data                  = ../../data/auto93.csv
 -g  --go    start-up example                    = nothing
 -h  --help  show help                           = false
 -K  --K     Bayes hack: low attribute frequency = 1
 -M  --M     Bayes hack: low class frequency     = 2
 -m  --min   stop at n^Min                       = .5
 -r  --rest  expansion best to rest              = 5
 -S  --Some  How many items to keep per row      = 256
 -s  --seed  random number seed                  = 10019]]

local coerce,csv,ent,fmt,gt,kap = l.coerce, l.csv, l.ent, l.fmt, l.gt, l.kap
local keys,lt,map,o,obj,oo      = l.keys, l.lt, l.map, l.o, l.obj, l.oo
local push,rand,rint,sort       = l.push, l.rand, l.rint, l.sort

local SOME,COL,DATA,XY=obj"SOME", obj"COL", obj"DATA", obj"XY"
-------------------------------------------------------------------------------
function XY:new(s,n,nlo,nhi) --> XY; count the `y` values from `xlo` to `xhi`
          self.name= s                  -- name of this column
          self.at  = n                   -- offset for this column
          self.xlo = nlo                 -- min x seen so far
          self.xhi = nhi or nlo          -- max x seen so far
          self.n   = 0                   -- number of items seen
          self.y   = {} end              -- y symbols see so far

function XY:__tostring() --> str;  print
  local x,lo,hi,big = self.name, self.xlo, self.xhi, math.huge
  if     lo ==  hi  then return fmt("(%s == %s)", x, lo)
  elseif hi ==  big then return fmt("(%s >  %s)", x, lo)
  elseif lo == -big then return fmt("(%s <= %s)", x, hi)
  else                   return fmt("(%s <  %s <= %s)", lo,x,hi) end end

function XY:add(nx,sy,  n) -->nil   `n`[=1] times,count `sy`. Expand to cover `nx` 
  if nx~="?" then
    n = n or 1
    self.n     = n + self.n 
    self.y[sy] = n + (self.y[sy] or 0)    -- count
    if nx < self.xlo then self.xlo=nx end -- expand
    if nx > self.xhi then self.xhi=nx end end end

function XY:merge(xy) --> XY;  combine two items (assumes both from same column)
  local combined = XY(self.name, self.at, self.xlo, xy.xhi)
  for y,n in pairs(self.y) do combined:add(self.xlo,y,n) end
  for y,n in pairs(xy.y)   do combined:add(xy.xhi,  y,n) end
  return combined end

local aims={}
function aims.plan(b,r)    return b*2/(b+r+1E-32) end
function aims.watch(b,r)   return 0 or r*2/(b+r+1E-32) end
function aims.explore(b,r) return 1/r + 1/b end
function aims.dispute(b,r) return (b+r)/(b-r+1E-32) end

function XY:score(want,B,R) --> num; how well does `self` select for `want`?
  local b,r,e = 0,0,1E-30
  for got,n in pairs(self.y) do 
    if got==want then b=b+n else r=r+n end end
  b, r = b/(B+e), r/(R+e)
  return aims[the.aim](b,r) end

function XY:select(row,     x) --- return true if `row` selected by `self`
  x = row[self.at]
  if x =="?" then return row end ------------------ assume yes for unknowns
  if self.xlo==self.xhi and v==self.xlo then return row end     -- for symbols
  if self.xlo < x and x <= self.xhi     then return row end end -- for numerics

function XY:selects(rows) --- return subset of `rows` selected by `self`
  return map(rows,function(row) return self:select(row) end) end

function XY:simpler(xy,nMin) --- if whole simpler than parts, return merged self+xy
  local whole = self:merge(xy)
  if self.n < nMin or xy.n < nMin then return whole end -- merge if too small
  local e1,e2,e12= ent(self.y), ent(xy.y), ent(whole.y)
  if e12 <= (self.n*e1 + xy.n*e2)/whole.n               -- merge if whole simpler
  then return whole end end

-- ### Class methods 
-- For lists of `xy`s.
function XY.like(xys,sWant,nB,nR) --- likelihood we do/dont `sWant` `xys`
  local function like1(f,n,nall,nhypotheses,     prior,like)
    prior = (n+the.K)/(nall + the.K*nhypotheses)
    like  = math.log(prior)
    for c,n1 in pairs(f) do
      like = like + math.log((n1+the.M*prior)/(n +the.M)) end 
    return math.exp(like) 
  end ---------
  local yes,no={},{}
  for _,xy in pairs(xys) do
    for k,v in pairs(xy.y) do 
      local c = xy.at
      if k==sWant then yes[c]=(yes[c] or 0)+v else no[c]=(no[c] or 0)+v end end end 
  return aims[the.aim](like1(yes,nB,nB + nR,2), like1(no,nR,nB + nR,2)) end

function XY.canonical(xys) --- simplify a list of `xy` ranges
  local function merges(t,n,u)
    while n <= #t do
      local a,b,ab = t[n],t[n+1]
      ab           = b and a.name==b.name and a.xhi==b.xlo and a:merge(b)
      u[1+#u]      = ab or a
      n            = ab and n+2 or n+1 end
    return #t==#u and t,#t or merges(u,1,{}) 
  end -------------------------------
  return merges(sort(xys, function (a,b) 
              return a.name < b.name or (a.name==b.name and a.xlo < b.xlo) end),
              1,{}) end
-------------------------------------------------------------------------------
function SOME:new(max)
  self.sorted=false
  self._has={}
  self.n=0
  self.max=max or the.Some end

function SOME:add(x)
  local function add(pos) self._has[pos]=x; self.sorted=false end
  if x ~= "?" then
    self.n = self.n+1 
    if #self._has < self.max        then add(1+#self._has) 
    elseif rand() < self.max/self.n then add(rint(#self._has)) end end end 

function SOME:nums()
  if not self.sorted then table.sort(self._has) end
  self.sorted=true
  return self._has end
-------------------------------------------------------------------------------
local is={}
function is.skip(s)   return s:find":$"     end
function is.num(s)    return s:find"^[A-Z]" end
function is.goal(s)   return s:find"[!+-]$" end
function is.klass(s)  return s:find"!$"     end
function is.weight(s) return s:find"-$" and -1 or 1 end

function COL:new(s,n)
  n,s=n or 0, s or ""
  self.some=SOME()
  self.at=n
  self.name=s
  self.is=kap(is,function(k,fun)  return fun(s) end) end 

function COL:add(x) self.some:add(x); return self end

function COL:norm(n)
  local t=self.some:nums()
  return n=="?" and n or t[#t]-t[1]<1E-9 and 0 or (n-t[1])/(t[#t]-t[1]) end 

function COL:discretize(x)
  if not self.is.num then return x else
    local t=self.some:nums()
    local tmp = (t[#t] - t[1])/(the.bins - 1)
    return t[#t]==t[1] and 1 or math.floor(x/tmp+.5)*tmp end end

function COL:merge(xys, nMin) --- Can we combine any adjacent ranges?
  if not self.is.num then return xys end
  local function merges(t,n,u) 
    while n <= #t do
      local a,b,ab = t[n], t[n+1]
      ab           = b and a:simpler(b, nMin) 
      u[1+#u]      = ab or a
      n            = ab and n+2 or n+1 end
    return #t == #u and t or merges(u,1,{}) 
  end ---------------------
  xys = merges(xys,1,{})
  for n = 2,#xys do xys[n].xlo = xys[n-1].xhi end   -- fill in any gaps
  xys[1].xlo, xys[#xys].xhi = -math.huge, math.huge -- extend to +/- infinity
  return xys end

-------------------------------------------------------------------------------
function DATA:new(names)
  self.rows={}
  self.cols={names=names, all={},x={},y={}}
  for n,s in pairs(names) do
    local col = push(self.cols.all, COL(s,n))
    if not is.skip(s) then
      if is.klass(s) then self.cols.klass=col end
      push(is.goal(s)  and self.cols.y or self.cols.x, col) end end end

function DATA:dist(row1,row2)
  local function dist(col,x,y)
    if x=="?" and y=="?" then return 1 end
    if not col.is.num then return x==y and 0 or 1 else
      x,y = col:norm(x), col:norm(y)
      if x=="?" then x = y<.5 and 1 or 0 end
      if y=="?" then y = x<.5 and 1 or 0 end
      return math.abs(x-y) end 
  end 
  local d,n=0,0
  for i,col in pairs(self.cols.x) do
    n = n + 1
    d = d + dist(col,row1[col.at],row2[col.at])^2 end 
  return (d/n)^.5 end

function DATA:add(row)
  push(self.rows, row)
  for _,cols in pairs{self.cols.x, self.cols.y} do
    for _,col in pairs(cols) do 
     col:add(row[col.at]) end end end 

function DATA:clone(t)
  local data=DATA(self.cols.names)
  for _,row in pairs(t or {}) do data:add(row) end 
  return data end

function DATA:sorted() --- sort `self.rows`
    return sort(self.rows, 
                function(row1,row2,    s1,s2,x,y)
                  s1,s2,x,y=0,0
                  for _,col in pairs(self.cols.y) do
                    x = col:norm(row1[col.at])
                    y = col:norm(row2[col.at])
                    s1= s1 - math.exp(col.is.weight * (x-y)/#self.cols.y)
                    s2= s2 - math.exp(col.is.weight * (y-x)/#self.cols.y) end
                  return s1/#self.cols.y < s2/#self.cols.y end) end

function load(src,    data)
  local function add(row)
          if data then data:add(row) else data=DATA(row) end end 
  if type(src)=="string" then csv(src, add) else map(src or {},add) end
  return data end

function DATA:xys()
  local function bestRest(     rows,best,rest,m,step)
    rows      = self:sorted()
    best,rest = self:clone(), self:clone()
    m         = (#rows)^the.min//1
    step      = (#rows-m+1)/(the.rest*m)//1
    for i=1  , m    , 1    do best:add(rows[i]) end
    for i=m+1, #rows, step do rest:add(rows[i]) end 
    return best, rest, #best.rows, #rest.rows end
  local function xys(col,datas,      x,n,all,bin,xys)
    n,all,xys = 0,{},{}
    for y,data in pairs(datas) do
      for _,row in pairs(data.rows) do
        x = row[col.at]
        if x ~= "?" then
          n        = n+1
          bin      = col:discretize(x) 
          xys[bin] = xys[bin] or push(all, XY(col.name,col.at,x)) 
          xys[bin]:add(x,y) 
    end end end
    return col:merge(sort(all,lt"xlo"), n^the.min) 
  end -------------------------
  local out = {}
  local best,rest,B,R = bestRest()
  for _,col in pairs(self.cols.x) do
    for i,xy in pairs(xys(col,{best = best, rest = rest})) do
      push(out, {xy=xy, score=xy:score("best",B,R)}) end end
  return map(sort(out,gt"score"),function(z) return z.xy end),B,R end

--function DATA:learn()

-- That's all folks
return {the=the, DATA=DATA, COL=COL, XY=XY, SOME=SOME}
