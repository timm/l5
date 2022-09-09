local l=require"lib"
local obj = l.obj
local the=require"about"
local Sym=require"sym"
local lt,map,sort = l.lt,l.map,l.sort

-- `XY` stores the `y` symbols seen between `xlo` and `xlo`.
local XY=obj"XY"

function XY:new(c,s,nlo,nhi,nom)
  return {name= s,          -- name of this column
          at  = c,          -- offset for this column
          xlo = nlo,        -- min x seen so far
          xhi = nhi or nlo, -- max x seen so far
          y   = nom or Sym(c,s) -- y symbols see so far
          } end

-- Extend `xlo` `xhi` to cover `x`. Also, add `y` to `self.y`.
function XY:add(x,y)
  if x~="?" then
    if x < self.xlo then self.xlo=x end
    if x > self.xhi then self.xhi=x end
    self.y:add(y) end end

function XY:selects(row,     v)
  v = row.cells[self.at]
  if v =="?"                            then return true end
  if self.xlo==self.xhi and v==self.xlo then return true end
  if self.xlo < v and v <= self.xhi     then return true end end

-- 
function XY:merged(xy2,nMin,    new)
  new = self.y:merged(xy2.y, nMin)
  if new then
    return XY(self.at,self.name,self.xlo,xy2.xhi,new) end end

-- Class method. Create lots of XYs
function XY.contrasts(col,listOfRows)
  local n,xys = 0,{} 
  for label, rows in pairs(listOfRows) do
    for _,row in pairs(rows) do
      local x = row.cells[col.at]
      if x ~= "?" then
        n = n+ 1
        local bin = col:discretize(x)
        local xy  = xys[bin] or XY(col.at,col.name, x)
        xy:add(x, label)
        xys[bin] = xy end end end
  n = the.min >= 1 and the.min or n^the.min
  return col:merges(sort(xys,lt"xlo"), n) end

-- That's all folks
return XY
