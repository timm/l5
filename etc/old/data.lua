local l=require"lib"
local the  = require"about"
local Cols = require"cols"
local Row  = require"row"
local XY   = require"xy"
local any,csv,fmt,gt,lt,many,map   = l.any,l.csv,l.fmt,l.gt,l.lt,l.many,l.map
local o,oo,obj,push,rnd,slice,sort = l.o,l.oo,l.obj,l.push,l.rnd,l.slice,l.sort

-- `Data` is a holder of `rows` and their sumamries (in `cols`).
local Data = obj"Data"

-- ### Create
function Data:new(src) 
  self.cols = nil -- summaries of data
  self.rows = {}  -- kept data
  if   type(src) == "string" 
  then csv(src,  function(row) self:add(row) end) 
  else for _,row in pairs(src or {}) do self:add(row) end end end

-- Duplicate `self`'s structure, add in `src` if is supplied.
function Data:clone(  src,    out)
    out = Data({self.cols.names})
    for _,row in pairs(src or {}) do out:add(row) end
    return out end

-- ### Update
-- Add a `row` to `data`. Calls `add()` to  updatie the `cols` with new values.
function Data:add(xs,    row)
 if   not self.cols  -- true when handling first line (with the column names)
 then self.cols = Cols(xs) 
 else row= push(self.rows, xs.cells and xs or Row(xs,self)) --ensure xs is a Row
      for _,todo in pairs{self.cols.x, self.cols.y} do
        for _,col in pairs(todo) do 
          col:add(row.cells[col.at]) end end end end

-- ### Query
-- Add percentile rank to rows, then scramble row order and forget we peeked.
function Data:cheat(    m,n)
  table.sort(self.rows)
  for i,row in pairs(self.rows) do 
    row.rank = math.floor(100*i/#self.rows) 
    row.evaled = false end
  self.rows = l.shuffle(self.rows) end

-- For `showCols` (default=`data.cols.x`) in `data`, show `fun` (default=`mid`),
-- rounding numbers to `places` (default=2)
function Data:stats(  places,showCols,todo,    t,v)
    showCols, todo = showCols or self.cols.y, todo or "mid"
    t={}; for _,col in pairs(showCols) do 
            v=getmetatable(col)[todo](col)
            v=type(v)=="number" and rnd(v,places) or v
            t[col.name]=v end; return t end

-- ### Distance
-- Spit rows in two based on distance to two distant points.
function Data:half(rows,  above)
  local sample = many(rows, the.Sample)
  if above then oo(above.cells) end
  local x  = above or any(sample):far(sample)
  local y  = x:far(sample)
  local c  = x:dist(y)
  local rxs= function(r, a,b)
               a, b = r:dist(x), r:dist(y)
               return {r=r, x=(a^2 + c^2 - b^2)/(2*c)} end
  local xs,ys = {},{}
  for j,rx in pairs(sort(map(rows,rxs), lt"x")) do 
    push(j<#rows/2 and xs or ys, rx.r) end
  return {xs=xs, ys=ys, x=x, y=y, c=c} end

function Data:bestLeaf(rows,  above,stop)
  stop = stop or (the.min >=1 and the.min or (#rows)^the.min)
  if   #rows < stop
  then return rows
  else 
       local node = self:half(rows,above)
       if    node.x < node.y 
       then  return self:bestLeaf(node.xs, node.x, stop)
       else  return self:bestLeaf(node.ys, node.y, stop) end end end

-- ### Ranges
-- Return the XY bins that separate the `listOfRows`
function Data:contrasts(listOfRows,    out)
  out = {}
  for _,col in pairs(self.cols.x) do
    for _,xy in pairs(XY.discretize(col,listOfRows)) do
      push(out, xy) end end
  return out end

function Data:greedyBest(out,stop,loop,bests,rests)
  out = {}
  stop = the.min >=1 and the.min or (#self.rows)^the.min 
  print("stop",stop)
  function loop(bests,rests)
    if   #bests + #rests >= stop
    then
      local rests1 = many(rests, the.rest*#bests)
      local ord=function(xy) return {xy=xy,z=xy.y:score("yes",#bests,#rests1)} end
      for i,todo in pairs(sort(map(self:contrasts({yes=bests,no=rests1}),
                          ord),gt"z")) do
        if i <= 10 then
          io.write("+")
          todo = todo.xy
          local bests2 = todo:selects(bests)
          local rests2 = todo:selects(rests)
          if (#bests2+#rests2 < #bests+#rests) then
             io.write("!")
             push(out, todo)
             return loop(bests2,rests2) end end end end
    return out, bests,rests 
  end ---------------------------
  bests,rests = self:bestOrRest()
  return loop(bests, rests) end

-- That's all folks.
return Data
