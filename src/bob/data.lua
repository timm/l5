local l=require"lib"
local the  = require"about"
local Cols = require"Cols"
local Row  = require"Row"
local XY   = require"xy"
local csv,lt,o,obj,push,rnd,slice = l.csv,l.lt,l.o,l.obj,l.push,l.rnd,l.slice

-- `Data` is a holder of `rows` and their sumamries (in `cols`).
local Data = obj"Data"

function Data:new(src) 
  self.cols = nil -- summaries of data
  self.rows = {}  -- kept data
  if   type(src) == "string" 
  then csv(src,  function(row) self:add(row) end) 
  else for _,row in pairs(src or {}) do self:add(row) end end end

-- Add a `row` to `data`. Calls `add()` to  updatie the `cols` with new values.
function Data:add(xs,    row)
 if   not self.cols  -- true when handling first line (with the column names)
 then self.cols = Cols(xs) 
 else row= push(self.rows, xs.cells and xs or Row(xs,self)) --ensure xs is a Row
      for _,todo in pairs{self.cols.x, self.cols.y} do
        for _,col in pairs(todo) do 
          col:add(row.cells[col.at]) end end end end

-- Duplicate `self`'s structure, add in `src` if is supplied.
function Data:clone(  src,    out)
  out = Data({self.cols.names})
  for _,row in pairs(src or {}) do out:add(row) end
  return out end

-- Return two datas, one for the best and a sample of the rest.
function Data:bestOrRest(    m,n)
  table.sort(self.rows)
  n = #self.rows
  m = self:enough(n)
  return slice(self.rows,1,m), slice(self.rows,m+1,n,(n-m)//(the.rest*m)) end 

-- Return the XY bins that separate the `listOfRows`
function Data:contrasts(listOfRows,    out)
  out = {}
  for _,col in pairs(self.cols.x) do
    for _,xy in pairs(XY.contrasts(col,listOfRows)) do
      push(out, xy) end end
  return out end

-- Return smallest useful number of rows.
function Data:enough(n)
  return (the.min >=1 and the.min or (n or #self.rows)^the.min) // 1 end 

-- For `showCols` (default=`data.cols.x`) in `data`, show `fun` (default=`mid`),
-- rounding numbers to `places` (default=2)
function Data:stats(  places,showCols,fun,    t,v)
  showCols, fun = showCols or self.cols.y, fun or "mid"
  t={}; for _,col in pairs(showCols) do 
          v=fun(col)
          v=type(v)=="number" and rnd(v,places) or v
          t[col.name]=v end; return t end

-- That's all folks.
return Data
