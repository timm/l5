local l=require"keyslib"
local the=l.options[[

KEYS: multi-objective semi-supervised explainations
(c)2022 Tim Menzies <timm@ieee.org> BSD-2 license

Usage: lua keysgo.lua [Options]

Options:
 -b  --bins  minimum bin width                   = 16
 -f  --file  file with csv data                  = ../data/auto93.csv
 -g  --go    start-up example                    = nothing
 -h  --help  show help                           = false
 -K  --K     Bayes hack: low attribute frequency = 1
 -M  --M     Bayes hack: low class frequency     = 2
 -m  --min   stop at n^Min                       = .5
 -r  --rest  expansion best to rest              = 5
 -S  --Some  How many items to keep per row      = 256
 -s  --seed  random number seed                  = 10019]]

local coerce,csv,fmt,kap,keys = l.R,l.coerce,l.csv,l.fmt,l.kap,l.keys
local map,o,obj,oo,push       = l.map,l.o,l.obj,l.oo,l.push
local rand,rint,sort          = l.rand,l.rint,l.sort

local SOME,COL,DATA,XY=obj"SOME", obj"COL", obj"DATA",obj"XY"
-------------------------------------------------------------------------------
function XY:new(n,s,nlo,nhi) --- Count the `y` values from `xlo` to `xhi`
  return {name= s,                  -- name of this column
          at  = n,                   -- offset for this column
          xlo = nlo,                 -- min x seen so far
          xhi = nhi or nlo,          -- max x seen so far
          n   = 0,                   -- number of items seen
          y   = {}} end              -- y symbols see so far

function XY:__tostring() --- print
  local x,lo,hi,big = self.name, self.xlo, self.xhi, math.huge
  if     lo ==  hi  then return fmt("%s == %s", x, lo)
  elseif hi ==  big then return fmt("%s >  %s", x, lo)
  elseif lo == -big then return fmt("%s <= %s", x, hi)
  else                   return fmt("%s <  %s <= %s", lo,x,hi) end end

function XY:add(nx,sy,  n) --- `n` times (default=1), count `sy` & expand to cover `nx` 
  if nx~="?" then
    n = n or 1
    self.n     = n + self.n 
    self.y[sy] = n + (self.y[sy] or 0)    -- count
    if nx < self.xlo then self.xlo=nx end -- expand
    if nx > self.xhi then self.xhi=nx end end end

function XY:select(row,     x) --- return true if `row` selected by `self`
  x = row[self.at]
  if x =="?" then return row end ------------------ assume yes for unknowns
  if self.xlo==self.xhi and v==self.xlo then return row end     -- for symbols
  if self.xlo < x and x <= self.xhi     then return row end end -- for numerics

function XY:selects(rows) --- return subset of `rows` selected by `self`
  return map(rows,function(row) return self:select(row) end) end

function XY:merge(xy,nMin) --- if whole simpler than parts, return merged self+xy
  local whole = XY(self.n, self.s, self.xlo, xy.xhi)
  for y,n in pairs(self.y) do whole:add(self.xlo,y,n) end
  for y,n in pairs(xy.y)   do whole:add(xy.xhi,  y,n) end
  if self.n < nMin or xy.n < nMin then return whole end -- merge if too small
  local e1,e2,e12= ent(self.y), ent(xy.y), ent(whole.y)
  if e12 <= (self.n*e1 + xy.n*e2)/whole.n               -- merge if whole simpler
  then return whole end end

-------------------------------------------------------------------------------
function SOME:new(max)
  return {sorted=false, _has={}, n=0, max=max or 512} end

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

function COL:new(n,s)
  n,s=n or 0, s or ""
  return {has=SOME(), at=n, name=s,
          is=kap(is,function(k,fun) return fun(s) end)} end 

function COL:add(x) self.has:add(x); return self end

function COL:norm(n)
  local t=self.has:nums()
  return n=="?" and n or t[#t]-t[1]<1E-9 and 0 or (n-t[1])/(t[#t]-t[1]) end 

function COL:discretize(x)
  if not self.is.num then return x else
    local t=self.has:nums()
    local tmp = (t[#t] - t[1])/(the.bins - 1)
    return t[#t]==t[1] and 1 or math.floor(x/tmp+.5)*tmp end end

function COL:merge(xys, nMin) --- Can we combine any adjacent ranges?
  if not self.is.num then return xys end
  local function merges(t,n,u) 
    while n <= #t do
      local xy1,xy2 = t[n], t[n+1]
      local xy12    = n < #t and xy1:merge(xy2, nMin) 
      u[1+#u]       = xy12 or xy1
      n             = xy12 and n+2 or n+1 end
    return #t == #u and t or merges(u,1,{}) 
  end ---------------------
  xys = merges(xys,1,{})
  for n = 2,#xys do xys[n].xlo = xys[n-1].xhi end   -- fill in any gaps
  xys[1].xlo, xys[#xys].xhi = -math.huge, math.huge -- extend to +/- infinity
  return xys end

-------------------------------------------------------------------------------
function DATA:new(names)
  self = {rows={}, cols={names=names, all={},x={},y={}}}
  for n,s in pairs(names) do
    col = push(self.cols.all, COL(n,s))
    if not is.skip(s) then
      if is.klass(s) then self.cols.klass=col end
      push(is.goal(s)  and self.cols.y or self.cols.x, col) end end
  return self end

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

function DATA:sorted() --- sort `self.rows`
    return sort(self.rows, 
                function(row1,row2,    s1,s2,x,y)
                  s1,s2,x,y=0,0
                  for _,col in pairs(self.cols.y) do
                    x = col:norm(row1[col.at])
                    y = col:norm(row2[col.at])
                    s1= s1 - math.exp(col.is.w * (x-y)/#self.cols.y)
                    s2= s2 - math.exp(col.is.w * (y-x)/#self.cols.y) end
                  return s1/#self.cols.y < s2/#self.cols.y end) end

function load(file,    data)
  csv(file, function(row) 
              if data then data:add(row) else data=DATA(row) end end) 
  oo(data.cols.all[1].has:nums()) end

function DATA:xys(m,n)
  local function xys(col,datas,      x,n,all,bin,xys)
    n,all,xys = 0,{},{}
    for y,data in pairs(datas) do
      for _,row in pairs(data.rows) do
        x = row[col.at]
        if x ~= "?" then
          n        = n+1
          bin      = col:discretize(x) 
          xys[bin] = xys[bin] or push(all, XY(col.at,col.name,x)) 
          xys[bin]:add(x,y) end end end
    return col:merge(sort(all,lt"xlo"), n^the.Min) 
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

-- That's all folks
return {the=the, DATA=DATA, COL=COL, XY=XY, SOME=SOME}
