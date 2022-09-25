local R,coerce,csv,fmt,kap,keys,map,o,obj,oo,push,sort
-------------------------------------------------------------------------------
-- maths
R=math.random

-- lists
function last(t)    return t[#t] end
function push(t, x) table.insert(t,x); return x end
function map(t, f)  local u={};for i,v in pairs(t)do u[1+#u]=f(v)end;return u end
function kap(t, f)  local u={};for k,v in pairs(t)do u[k]=f(k,v)end; return u end

-- sorting
function sort(t, f) table.sort(t,f); return t end
function keys(t) 
  local function want(k,x) if tostring(k):sub(1,1) ~= "_" then return k end end
  return sort(kap(t,want)) end

-- strings
fmt = string.format
function oo(t)      print(o(t)) end
function o(t) 
  if type(t) ~= "table" then return tostring(t) end
  local function filter(v) return fmt(":%s %s",v,o(t[v])) end
  t = #t>0 and map(t,tostring) or map(keys(t),filter)
  return "{".. table.concat(t," ") .."}" end

-- strings to things
function coerce(s,    fun) --- Parse `the` config settings from `help`
  function fun(s1)
    if s1=="true"  then return true  end
    if s1=="false" then return false end
    return s1 end
  return math.tointeger(s) or tonumber(s) or fun(s:match"^%s*(.-)%s*$") end

function csv(sFilename, fun,      src,s,t) --- call `fun` on csv rows
  src  = io.input(sFilename)
  while true do
    s = io.read()
    if   s
    then t={}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=coerce(s1) end; fun(t)
    else return io.close(src) end end end

-- objects
function obj(s,    t,i,new) 
  local isa=setmetatable
  function new(k,...) i=isa({},k); return isa(t.new(i,...) or i,k) end
  t={__tostring = function(x) return s..o(x) end}
  t.__index = t;return isa(t,{__call=new}) end
-------------------------------------------------------------------------------
local SOME=obj"SOME"
function SOME:new(max)
  return {sorted=false, _has={}, n=0, max=max or 512} end

function SOME:add(x)
  local function add(pos) self._has[pos]=x; self.sorted=false end
  if x ~= "?" then
    self.n = self.n+1 
    if #self._has < self.max        then add(1+#self._has)
    elseif R()    < self.max/self.n then add(R(#self._has)) end end end 

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

local COL=obj"COL"
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
  local function try2Merge(t,n,u)
    while n <= #t do
      local a,b = t[n], t[n+1]
      local ab  = n < #t and simpler(a.y, b.y, nMin) -- <=== aas
      u[1+#u]   = ab and XY(a.at, a.name, a.xlo, b.xhi, ab) or a
      n         = ab and n+2 or n+1 end
    return #t == #u and t or try2Merge(u,1,{}) 
  end ---------------------
  xys = try2Merge(xys,1,{})
  for n = 2,#xys do xys[n].xlo = xys[n-1].xhi end   -- fill in any gaps
  xys[1].xlo, xys[#xys].xhi = -math.huge, math.huge -- extend to +/- infinity
  return xys end

-------------------------------------------------------------------------------
local DATA=obj"DATA"
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


-----
load("../data/auto93.csv")

