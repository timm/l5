--  __                                
-- /\ \__    __                        
-- \ \ ,_\  /\_\     ___     __  __  
--  \ \ \/  \/\ \  /' _ `\  /\ \/\ \ 
--   \ \ \_  \ \ \ /\ \/\ \ \ \ \_\ \  
--    \ \__\  \ \_\\ \_\ \_\ \/`____ \  
--     \/__/   \/_/ \/_/\/_/  `/___/> \  
--                               /\___/           
--                               \/__/            

local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;
local help=[[
TINY2: a lean little learning library, in LUA
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua l5.lua [OPTIONS]

OPTIONS:
 -b  --bins    max number of bins                     = 16
 -d  --dump    on test failure, exit with stack dump  = false
 -f  --file    file with csv data                     = ../data/auto93.csv
 -F  --Far     how far to look for poles (max=1)      = .95
 -g  --go      start-up example                       = nothing
 -h  --help    show help                              = false
 -m  --min     min size. If<1 then t^min else min.    = .5
 -n  --nums    number of nums to keep                 = 512
 -p  --p       distance calculation coefficient       = 2
 -r  --rest    size of "rest" set                     = 5
 -s  --seed    random number seed                     = 10019
 -S  --Sample  how many numbers to keep               = 512]]

local any,cli,coerce,copy,csv,fmt,gt,lt,many,map,o,obj,oo,per,pop 
local push,red,rnd,rogues,settings,shallowCopy,shuffle
local slice,sort,the,xys,yellow
local isa=setmetatable
function obj(s,    t,i,new) 
  function new(k,...) i=isa({},k); return isa(t.new(i,...) or i,k) end
  t={__tostring = function(x) return s..o(x) end}
  t.__index = t;return isa(t,{__call=new}) end

local Data,Num,Row = obj"Data", obj"Num", obj"Row"
local Some,Sym,XY  = obj"Some", obj"Sym", obj"XY"

--[[ Type hints conventions:
| Function args   | Notes                                       |
|:---------------:|---------------------------------------------|
| 2 blanks        | 2 blanks denote optional arguments          |
| 4 blanks        | 4 blanks denote local arguments             |
| n               | prefix for numerics                         |
| s               | prefix for strings                          |
| is              | prefix for booleans                         |
| fun             | prefix for functions                        |
| suffix s        | list of thing (so names is list of strings) |
| xy,row,col,data | for Xys, Rows, Num or Syms, Data objects    | 

Another convention is that my code starts with a  help string (at top
of file) that is parsed to find the settings. Also my code ends with
lots of `go.x()` functions that describe various demos. To run
these, use `lua tiny2.lua -go x`. --]]
---------------------------------------------------------------- 
function Row:new(t) --- Hold one record
  return {evaled=false,
          cells=t,
          cooked=shallowCopy(t)} end

function Sym:new(n,s) --- Summarize stream of symbols.
    return {at=n or 0,
            txt=s or "",
            n=0,
            has={}} end

function Some:new(n,s)  --- Keep at most the.Sample numbers
  return {at=n or 0, txt=s or "",n=0, _has={},
          isSorted=true } end

function Num:new(c,x) --- Summarize stream of numbers
  return {at=c or 0,txt=x or "",n=0,
         lo= 1E32,  hi= -1E32, 
         has=Some(),
          w=(x or ""):find"-$" and -1 or 1} end

function Data:new(src) --- Store rows of data. Summarize rows in `self.cols`.
  self.rows = {}
  self.cols = {names={},all={},x={},y={}}
  if   type(src)=="string"
  then csv(src,       function(row) self:add(row) end)
  else map(src or {}, function(row) self:add(row) end) end  end

function XY:new(n,s,nlo,nhi,nom) --- Keep the `y` values from `xlo` to `xhi`
  return {txt= s,                    -- name of this column
          at  = n,                   -- offset for this column
          xlo = nlo,                 -- min x seen so far
          xhi = nhi or nlo,          -- max x seen so far
          y   = nom or Sym(n,s)} end -- y symbols see so far

-- ## Row     ----- ----- ------------------------------------------------------
-- ### sort
function Row:better(row,data) --- order two rows
  self.evaled, row.evaled = true,true
  local s1,s2,d,n,x,y,ys=0,0,0,0
  ys = data.cols.y
  for _,col in pairs(ys) do
    x,y= self.cells[col.at], row.cells[col.at]
    x,y= col:norm(x), col:norm(y)
    s1 = s1 - 2.71828^(col.w * (x-y)/#ys)
    s2 = s2 - 2.71828^(col.w * (y-x)/#ys) end
  return s1/#ys < s2/#ys end

-- ### dist
function Row:dist(row,data,   tmp,n,d1) -- distance between rows
  tmp,n = 0,0
  for _,col in pairs(data.cols.x) do
    d1     = col:dist(self.cells[col.at], row.cells[col.at])
    n, tmp = n + 1,  tmp + d1^the.p end
  return (tmp/n)^(1/the.p) end

function Row:dists(rows,data) --- sort `rows` by distance to `r11.
  return sort(map(rows,
           function(row) return {r=row,d=self:dist(row,data)} end),lt"d") end

function Row:far(rows,data) -- Find an item in `rows`, far from `row1.
  return per(self:dists(rows,data),the.far).r end
-- ## XY    ----- ----- ------------------------------------------------------
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

function XY:select(row,     v) --- Return true if `row` selected by `self`
  v = row.cells[self.at]
  if v =="?" then return true end ------------------ assume yes for unknowns
  if self.xlo==self.xhi and v==self.xlo then return true end -- for symbols
  if self.xlo < v and v <= self.xhi     then return true end -- for numerics
end

function XY:selects(rows) --- Return subset of `rows` selected by `self`
  return map(rows,function(row) if self:select(row) then return row end end) end

-- ### Class methods
function XY.deltas(col,datas) --- find ranges the most separate datas
  local n,xys = 0,{} 
  for label, data in pairs(datas) do
    for _,row in pairs(data.rows) do
      local x = row.cells[col.at]
      if x ~= "?" then
        n = n + 1
        local bin = col:discretize(x)
        xys[bin]  = xys[bin] or XY(col.at,col.txt,x)
        xys[bin]:add(x,label) end end end
  local xys1={}; for _,xy in pairs(xys) do push(xys1,xy) end 
  xys1 = col:xys(sort(xys1, lt"xlo"), the.min >= 1 and the.min or n^the.min) 
  if #xys1 > 1 then return xys1 end end  -- if size==1, nothing found

-- ## Sym     ----- ----- -----------------------------------------------------
-- ### Create
function Sym:merge(sym,     out) --- merge two sysms
  out = Sym(self.at, self.txt)
  for x,n in pairs(self.has) do out:add(x,n) end
  for x,n in pairs(sym.has)  do out:add(x,n) end
  return out end

-- ### update
function Sym:add(s,  n) --- Update.
  if s~="?" then 
    n = n or 1
    self.n      = n+self.n
    self.has[s] = n+(self.has[s] or 0) end end

-- ### dist
function Sym:dist(s1,s2) -- Gap between two symbols.
  return  s1=="?" and s2=="?" and 1 or s1==s2 and 0 or 1 end

-- ### query
function Sym:entropy(     e,fun) -- Entropy
  function fun(p) return p*math.log(p,2) end
  e=0; for _,n in pairs(self.has) do if n>0 then e=e-fun(n/self.n) end end
  return e end

function Sym:score(goal,B,R) --- how well does self select for goal?
  local b,r,epsilon = 0,0,1E-30
  for x,n in pairs(self.has) do
    if x == goal then b=b+n else r=r+n end end
  b,r = b/(B+epsilon), r/(R+epsilon) -- B,R are the total bests and rests
  return b^2/(b+r+epsilon) end

-- ### Discretize
function Sym:xys(xys)      return xys end --- Sym columns do nothing to xys
function Sym:discretize(x) return x end --- Discretize `Sym`s (just returning x)

 function Sym:simpler(sym,tiny) --- returns self+sym if whole better than parts
    local whole = self:merge(sym)
    local e1, e2, e12 = self:entropy(), sym:entropy(), whole:entropy()
    if self.n< tiny or sym.n< tiny or e12 <= (self.n*e1 + sym.n*e2)/whole.n then 
      return whole end end

-- ## Some   ----- ----- -------------------------------------------------------
-- ### update
function Some:add(x,    pos) --- update
  if x~="?" then
    self.n = self.n+1
    if #self._has < the.Sample then pos=1+(#self._has)
    elseif math.random()<the.Sample/self.n then pos=math.random(#self._has) end
    if pos then self.isSorted=false
                self._has[pos]= x end end end

-- ### query
function Some:nums()
  if not self.isSorted then table.sort(self._has) end
  self.isSorted=true
  return self._has end

-- ## Num     ----- ----- ------------------------------------------------------
-- ### update
function Num:add(n) --- update
  if n~="?" then self.n = self.n+1
                 self.lo = math.min(n,self.lo)
                 self.hi = math.max(n,self.hi)
                 self.has:add(n)  end end

-- ### query
function Num:norm(n,   lo,hi) --- convert `n` to 0..1 for min..max
  lo,hi=self.lo,self.hi
  return n=="?" and n or (hi-lo < 1E-0 and 0 or  (n-lo)/(hi-lo + 1E-32)) end

function Num:pers(ns,    a) --- report a list over percentiles
  a=self.has:nums()
  return map(ns,function(p) return per(a,p) end) end

-- ### dist
function Num:dist(n1,n2) --- return 0..1. If unknowns, assume max distance.
  if   n1=="?" and n2=="?" then return 1 end
  n1,n2 = self:norm(n1), self:norm(n2)
  if n1=="?" then n1 = n2<.5 and 1 or 0 end
  if n2=="?" then n2 = n1<.5 and 1 or 0 end
  return math.abs(n1-n2) end

-- ### Discretize
function Num:discretize(x,    tmp) --- discretize `Num`s,rounded to (hi-lo)/bins
  tmp = (self.hi - self.lo)/(the.bins - 1)
  return self.hi==self.lo and 1 or math.floor(x/tmp+.5)*tmp end 

function Num:xys(xys,nMin,    tryMerging) --- Can we combine any adjacent ranges?
  function tryMerging(xys0,    n,xys1,a,b,mergedSym)
    n,xys1 = 1,{}
    while n <= #xys0 do
      a = xys0[n]
      if n < #xys0 then
        b = xys0[n+1] -- try and merge two adjacent bins
        mergedSym = a.y:simpler(b.y, nMin)
        if mergedSym then
          a = XY(self.at, self.txt, a.xlo, b.xhi, mergedSym)
          n = n+1 end -- skip over the merged item 
      end
      push(xys1, a)
      n = n + 1 
    end
    return #xys1 == #xys0 and xys0 or tryMerging(xys1)
  end -----------
  xys = tryMerging(xys)
  for n = 2,#xys do xys[n].xlo = xys[n-1].xhi end    -- fill in any gaps
  xys[1].xlo, xys[#xys].xhi    = -math.huge, math.huge  -- extend to +/- infinity
  return xys end

-- ## Data    ----- ----- ------------------------------------------------------
-- ### create
function Data:clone(  src,    data) --- Copy structure. Optionally, add in data.
  data= Data{self.cols.names}
  map(src or {}, function (row) data:add(row) end)
  return data end

-- ### update
function Data:add(row) --- the new row is either a header, or a data row  
  local function header(row) --- Create `Num`s and `Sym`s for the column headers
    self.cols.names = row
    for n,s in pairs(row) do
      local col = push(self.cols.all, (s:find"^[A-Z]" and Num or Sym)(n,s))
      if not s:find":$" then
        push(s:find"[!+-]" and self.cols.y or self.cols.x, col) end end end
  local function body(row) --- Crete new row. Store in `rows`. Update cols.
    row = row.cells and row or Row(row) -- Ensure `row` is a `Row`.
    push(self.rows, row)
    for _,cols in pairs{self.cols.x, self.cols.y} do
      for _,col in pairs(cols) do
        col:add(row.cells[col.at]) end end 
  end ------------------------------------
  if #self.cols.all==0 then header(row) else body(row) end end

-- ### query
function Data:cheat(   ranks) --- return percentile ranks for rows
  ranks = {}
  for i,row in pairs(self:betters()) do
    push(ranks, row)
    row.evaled = false
    row.rank = math.floor(.5+ 100*i/#self.rows) end
  self.rows = shuffle(self.rows)
  return ranks end

--- ### dist
function Data:betters(rows,data) --- order a whole list of rows
  return sort(rows or self.rows,
              function(r1,r2) return r1:better(r2,self) end) end

--- ### cluster
function Data:half(  above, --- split data by distance to two distant points
                  some,x,y,c,rxs,xs,ys)
  some= many(self.rows, the.Sample)
     x= above or any(some):far(some,self)
     y= x:far(some,self)
     c= x:dist(y,self)
   rxs=function(r) return
         {r=r,x=(x:dist(r,self)^2 + c^2 - y:dist(x,self)^2)/(2*c)} end
  xs,ys= self:clone(), self:clone()
  for j,rx in pairs(sort(map(self.rows,rxs),lt"x")) do
    if j<=#self.rows/2 then xs:add(rx.r) else ys:add(rx.r) end end
  return {xs=xs, ys=ys, x=x, y=y, c=c} end

function Data:best(  above,stop,rest) ---recursively hunt  for best leaf
  stop = stop or (the.min >=1 and the.min or (#self.rows)^the.min)
  rest = rest or self:clone()
  if   #self.rows < stop
  then return self, above ,rest
  else local node = self:half(above)
       if    node.x:better(node.y,self)
       then  for _,row in pairs(node.ys.rows) do rest:add(row) end
             return node.xs:best(node.x, stop, rest)
       else  for _,row in pairs(node.xs.rows) do rest:add(row) end
             return node.ys:best(node.y, stop, rest) end end end 

--- ### Decision tree
function Data:rule(rest,  out,stop)
  if not stop then -- first time through. initialize the space
    rest = self:clone(many(rest.rows, the.rest*#self.rows))
    return self:rule(rest,{},the.min >=1 and the.min or (#self.rows)^the.min) 
  end
  local function cuts(out)
    for _,col in pairs(self.cols.x) do
      for _,xy in pairs(XY.deltas(col,{yes=self,no=rest}) or {}) do
        push(out, {xy=xy,z=xy.y:score("yes",#self.rows,#rest.rows)}) end end
    return out 
  end ------- 
  local xy,best1,rest1
  if (#self.rows + #rest.rows) > stop then 
    for i,cut in pairs(sort(cuts({}),gt"z")) do 
      if i <= 10 then
        xy=cut.xy
        best1 = xy:selects(self.rows)
        rest1 = xy:selects(rest.rows)
        if (#best1 + #rest1 < #self.rows + #rest.rows) then
           push(out,xy)
           return self:clone(best1):rule(self:clone(rest1), out,stop) end end end end 
  return out,self,rest end
      
-- ## Lib    ----- ----- -------------------------------------------------------
-- ### Sampling
function any(t) return t[math.random(#t)] end --- select one, at random

function many(t1,n,  t2) --- select `n`
  n = math.floor(.5 + n)
  if n >= #t1 then return shuffle(t1) end
  t2={}; for i=1,n do push(t2, any(t1)) end; return t2 end

function shuffle(t,   j) --- Randomly shuffle, in place, the list `t`.
  for i=#t,2,-1 do j=math.random(i); t[i],t[j]=t[j],t[i] end; return t end

-- ### Maths
function rnd(x, places) 
  local mult = 10^(places or 2)
  return math.floor(x * mult + 0.5) / mult end

-- ### Strings
fmt = string.format --- printf clone

local function color(s,n)  --- colorize text
  return fmt("\27[1m\27[%sm%s\27[0m",n,s) end 

function red(s)     return color(s,31) end
function yellow(s)  return color(s,34) end

function oo(t) print(o(t)) return t end --- print nested lists
function o(t,   seen,show,u) ---  coerce to string (skip loops, sort slots)
  if type(t) ~=  "table" then return tostring(t) end
  seen=seen or {}
  if seen[t] then return "..." end
  seen[t] = t
  function show(k,v)
    if not tostring(k):find"^_"  then
      v = o(v,seen)
      return #t==0 and fmt(":%s %s",k,v) or o(v,seen) end end
  u={}; for k,v in pairs(t) do u[1+#u] = show(k,v) end
  if #t==0 then table.sort(u) end
  return "{"..table.concat(u," ").."}" end

-- ### Lists
function map(t1,fun,    t2)  --- apply `fun` to all of `t1` (skip nil results)
  t2={}; for _,v in pairs(t1) do t2[1+#t2] = fun(v) end; return t2 end

function per(t,p) --- return the pth (0..1) item of `t`.
  p=math.floor(((p or .5)*#t)+.5); return t[math.max(1,math.min(#t,p))] end

function push(t,x) t[1+#t]=x; return x end --- at `x` to `t`, return `x`
function pop(t)    return table.remove(t) end --- remove(and return) last item

function slice(t,  nGo,nStop,nStep,    u) --- return t[go..stop] by step
  u={}
  for j=(nGo or 1)//1,(nStop or #t)//1,(nStep or 1)//1 do u[1+#u]=t[j] end
  return u end

function shallowCopy(t)  return copy(t,true) end --- shallow copy of list
function copy(t,  shallow, u) --- copy list
  if type(t) ~= "table" then return t end
  u={}; for k,v in pairs(t) do u[k] = shallow and v or copy(v,shallow) end
  return setmetatable(u,getmetatable(t))  end

-- ### Sorting 
function sort(t,f) table.sort(t,f); return t end --- sort(and return) list
function lt(x)  return function(t1,t2) return t1[x] < t2[x] end end ---sort <
function gt(x)  return function(t1,t2) return t1[x] > t2[x] end end ---sort >

-- ### Settings
function settings(s,     t) --- create a `the` variable
  t = {_help=s}
  s:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)", 
         function(k,x) t[k]=coerce(x) end)
  return t end

function coerce(s,    fun) --- Parse `the` config settings from `help`.
  function fun(s1)
    if s1=="true"  then return true end 
    if s1=="false" then return false end
    return s1 end 
  return math.tointeger(s) or tonumber(s) or fun(s:match"^%s*(.-)%s*$") end

function cli(t) -- Updates from command-line. Bool need no values (just flip)
  for slot,v in pairs(t) do
    v = tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(slot:sub(1,1)) or x=="--"..slot then
        v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
    t[slot] = coerce(v) end
  if t.help then 
    t._help=t._help
            :gsub("%s([-][-]?%S[a-z]*)",function (s) return " "..yellow(s) end)
            :gsub("([A-Z][A-Z]+)"      ,function (s) return red(s) end)
    os.exit(print("\n"..t._help.."\n")) end
  return t end

-- ### csv
function csv(sFilename, fun,      src,s,t) --- call `fun` cells in each CSV line
  src  = io.input(sFilename)
  while true do
    s = io.read()
    if   s 
    then t = {}; for s1 in s:gmatch("([^,]+)") do t[1+#t] = coerce(s1) end
         fun(t) 
    else return io.close(src) end end end
-- ## Demos/Tests  ----- ----- -------------------------------------------------
local go = {}
function go.the() oo(the) end

function go.num(  z)
  z=Num(); for i=1,100 do z:add(i) end; print(z) end

function go.sym(  z)
  z=Sym(); for _,x in pairs{1,1,1,1,2,2,3} do z:add(x) end;
  print(z) end

function go.eg( d)
  d=Data(the.file);  map(d.cols.x,print) end

function go.dist(    num,d,r1,r2,r3)
  d=Data(the.file)
  num=Num()
  for i=1,20 do
    r1= any(d.rows)
    r2= any(d.rows)
    r3= r1:far(d.rows,d)
    io.write(rnd(r1:dist(r3,d))," ")
    num:add(rnd(r1:dist( r2,d))) end
  oo(sort(num.has:nums()))
  print(#d.rows) end

function go.sort(     d,rows,ranks)
  d = Data(the.file)
  ranks = d:cheat()
  for i=1,#d.rows,32 do print(o(ranks[i].cells),"\t",o(d.rows[i].cells)) end
  end

function go.clone(    d1,d2)
  d1 = Data(the.file)
  d2 = d1:clone(d1.rows); 
  oo(d1.cols.x[2])
  oo(d2.cols.x[2]) end

function go.half( d,node)
  d=Data(the.file)
  node = d:half()
  print(#node.xs.rows, #node.ys.rows, node.x:dist(node.y,d)) end

function go.best(    num1,num2,num3,num4)
  num1,num2,num3,num4 = Num(),Num(),Num(),Num()
  for i=1,10 do
    local d=Data(the.file)
    local ranks = d:cheat()
    local leaf,best = d:best()
    local evaled=0
    for _,row in pairs(d.rows) do
        if row.evaled then 
          evaled=evaled+1
          num1:add(row.rank) end end
    num4:add(evaled)
    num3:add(best.rank)
    for _,row in pairs(leaf.rows) do num2:add(row.rank) end end 
  local t={0,.25,.5,.75,1}
  print(the.file,o(num1:pers(t)), o(num2:pers(t)),
                 o(num3:pers(t)), o(num4:pers(t))) end

function go.xys(     d,all,few,best,ranks,rest)
  print("\n#----",the.file,"---------------------------")
  d = Data(the.file)
  ranks=d:cheat()
  all=#d.rows
  few=all^.5
  best = d:clone(slice(ranks, 1, few))
  rest = d:clone(slice(ranks, all-few))
  print("#",o{best=#best.rows, rest=#rest.rows})
  for _,col in pairs(d.cols.x) do
    map(XY.deltas(col,{best=best,rest=rest}) or {},
        function(xy,  tmp) 
          local tmp= rnd(xy.y:score("best",#best.rows, #rest.rows))
          if tmp > .1 then
            print(table.concat({the.file, tostring(xy),tmp, o(xy.y.has)},", ")) end end ) end end

function go.rule(     d,all,few,best,ranks,rest,_,selected,num,rule,best1,rest1)
  print("\n#----",the.file,"---------------------------")
  num={}
  d = Data(the.file)
  ranks=d:cheat()
  best,_,rest = d:best()
  rule,best1,rest1 = best:rule(rest)
  for _,row in pairs(best1.rows) do push(num,row.rank)end
  for _,row in pairs(rest1.rows) do push(num,row.rank)end
  local t={0,.25,.5,.75,1}; oo(sort(num)) end

-- ## Start  ----- ----- -------------------------------------------------------
local function on(settings,funs,   fails,old)
  fails=0
  old = copy(settings)
  for k,fun in pairs(funs) do
    if settings.go == "all" or settings.go == k then
      for k,v in pairs(old) do settings[k]=v end
      math.randomseed(settings.seed or 10019)
      print("#>>>>>",k)
      if fun()==false then fails = fails+1;print("F#AIL!!!!!",k); end end end
  for k,v in pairs(_ENV) do if not b4[k] then print("#?",k,type(v)) end end 
  os.exit(fails) end

the = cli(settings(help))
on(the,go)
