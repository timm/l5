-- [about](about.html) | [cols](cols.html) | [data](data.html) |
-- [eg](eg.html) | [lib](lib.html) | [num](num.html) | [row](row.html) | [sym](sym.html)<hr>

local l=require"lib"
local the=require"about"
local copy,lt,map,obj = l.copy,l.lt,l.map,l.obj

-- `Row` holds one record
local Row = obj"Row"
function Row:new(t,from) 
  return {cells     = t,          -- one record
          cooked    = l.copy(t),  -- used if we discretize data
          isEvaled  = false,      -- true if y-values evaluated.
          background= from        -- background space of all examples
         } end

-- Distance between rows (returns 0..1). For unknown values, assume max distance.
function Row:dist(row2,    d)
  d = 0
  for _,col in pairs(self.background.cols.x) do 
    d = d + col:dist(self.cells[col.at], row2.cells[col.at])^the.p end
  return (d/#self.cols.x)^(1/the.p) end

-- Sort `rows` (default=`data.rows`) by distance to `self`.
function Row:around(rows,     fun)
  function fun(row2) return {row=row2, dist=self:dist(row2)} end
  return sort(map(rows, fun),lt"dist") end

-- That's all folks.
return Row
