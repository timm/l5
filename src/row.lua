local l=require"lib"
local the=require"about"
local o, oo = l.o, l.oo
local copy,lt,map,obj,sort = l.copy,l.lt,l.map,l.obj,l.sort

-- `Row` holds one record
local Row = obj"Row"

-- ### Create
function Row:new(t,data) 
  return {cells     = t,          -- one record
          cooked    = l.copy(t),  -- used if we discretize data
          isEvaled  = false,      -- true if y-values evaluated.
          outerSpace= data        -- background space of all examples
         } end

-- ### Query
-- `self` is ranked before `row2` if self "dominates" `row`
function Row:__lt(row2)
  self.evaled, row2.evaled= true,true
  local s1,s2,d,n,x,y=0,0,0,0
  local ys = self.outerSpace.cols.y
  for _,col in pairs(ys) do
    x,y= self.cells[col.at], row2.cells[col.at]
    x,y= col:norm(x), col:norm(y)
    s1 = s1 - 2.71828^(col.w * (x-y)/#ys)
    s2 = s2 - 2.71828^(col.w * (y-x)/#ys) end
  return s1/#ys < s2/#ys end

function Row:cols(cols)
  return map(cols, function(col) return self.cells[col.at] end) end
  
-- ### Distance
-- Distance between rows (returns 0..1). For unknown values, assume max distance.
function Row:dist(row2,    d)
  d = 0
  for i,col in pairs(self.outerSpace.cols.x) do 
    d = d + col:dist(self.cells[col.at], row2.cells[col.at])^the.p end
  return (d/#self.outerSpace.cols.x)^(1/the.p) end

-- Sort `rows` (default=`data.rows`) by distance to `self`.
function Row:around(rows,     fun)
  function fun(row2) return {row=row2, dist=self:dist(row2)} end
  return sort(map(rows, fun),lt"dist") end

-- Look for something `the.far` away from `self`. 
function Row:far(rows) 
  return per(self:around(rows),the.far).row end

-- That's all folks.
return Row
