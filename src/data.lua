local l=require"lib"
local the  = require"about"
local Cols = require"cols"
local Row  = require"row"
local XY   = require"xy"
local csv,gt,lt,many,map,o,obj = l.csv,l.gt,l.lt,l.many,l.map,l.o,l.obj
local push,rnd,slice,sort      = l.push,l.rnd,l.slice,l.sort

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
-- Return two sets of rows, one for the best and the rest
function Data:bestOrRest(    m,n)
  table.sort(self.rows)
  for i,row in pairs(self.rows) do row.rank = math.floor(100*i/#self.rows) end
  n = #self.rows
  m = the.min >=1 and the.min or (#self.rows)^the.min
  return slice(self.rows,1,m), slice(self.rows,m+1) end 

-- For `showCols` (default=`data.cols.x`) in `data`, show `fun` (default=`mid`),
-- rounding numbers to `places` (default=2)
function Data:stats(  places,showCols,todo,    t,v)
    showCols, todo = showCols or self.cols.y, todo or "mid"
    t={}; for _,col in pairs(showCols) do 
            v=getmetatable(col)[todo](col)
            v=type(v)=="number" and rnd(v,places) or v
            t[col.name]=v end; return t end
  
-- ### Ranges
-- Return the XY bins that separate the `listOfRows`
function Data:contrasts(listOfRows,    out)
  out = {}
  for _,col in pairs(self.cols.x) do
    for _,xy in pairs(XY.discretize(col,listOfRows)) do
      push(out, xy) end end
  return out end

function Data:greedyBest(fun,   out,stop,loop,bests,rests)
  out = {}
  stop = the.min >=1 and the.min or (#self.rows)^the.min 
  function loop(bests,rests)
    if #bests + #rests > stop then
      local rests1 = many(rests, the.rest*#bests)
      local ord=function(xy) return {xy=xy,z=xy.y:score("yes",#bests,#rests1)} end
      for _,todo in pairs(sort(map(self:contrasts({yes=bests,no=rests1}),
                          ord),gt"z")) do
        todo = todo.xy
        local bests2 = todo:selects(bests)
        local rests2 = todo:selects(rests)
        if (#bests2+#rests2 < #bests+#rests) then
           if fun then fun(bests2,rests2,todo) end
           push(out, todo)
           return loop(bests2,rests2,out,stop) end  end  end
  end ---------------------------
  bests,rests = self:bestOrRest()
  loop(bests, rests)
  return out end 

-- That's all folks.
return Data
