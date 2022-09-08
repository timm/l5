-- [about](about.html) | [bob](bob.html) | [cols](cols.html) | [data](data.html) |
-- [eg](eg.html) | [lib](lib.html) | [num](num.html) | [row](row.html) | [sym](sym.html)<hr>

local l=require"lib"
local the  = require"about"
local Cols = require"Cols"
local Row  = require"Row"
local csv,lt,push,rnd = l.csv,l.lt,l.push,l.rnd

-- `Data` is a holder of `rows` and their sumamries (in `cols`).
function Data:new(src) 
  self.cols = nil -- summaries of data
  self.rows = {}  -- kept data
  if   type(src) == "string" 
  then csv(src,  function(row) self:add(row) end) 
  else for _,row in pairs(src or {}) do self:add(row) end end end

-- Add a `row` to `data`. Calls `add()` to  updatie the `cols` with new values.
function Data:add(xs,    row)
 if   not self.cols 
 then self.cols = Cols(xs) 
 else row= push(self.rows, xs.cells and xs or Row(xs,self)) --ensure xs is a Row
      for _,todo in pairs{self.cols.x, self.cols.y} do
        for _,col in pairs(todo) do 
          col:add(row.cells[col.at]) end end end end

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
