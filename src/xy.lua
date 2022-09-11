local l=require"lib"
local obj = l.obj
local the=require"about"
local Sym=require"sym"
local lt,map,sort = l.lt,l.map,l.sort

-- `XY` stores the `y` symbols seen between `xlo` and `xlo`.
local XY=obj"XY"

-- ### Create
function XY:new(c,s,nlo,nhi,nom)
  return {name= s,          -- name of this column
          at  = c,          -- offset for this column
          xlo = nlo,        -- min x seen so far
          xhi = nhi or nlo, -- max x seen so far
          y   = nom or Sym(c,s) -- y symbols see so far
          } end

-- ### Print
function XY:__tostring()
  local x,lo,hi,big = self.name, self.xlo, self.xhi, math.huge
  if     lo ==  hi  then return string.format("%s == %s", x, lo)
  elseif hi ==  big then return string.format("%s >  %s", x, lo)
  elseif lo == -big then return string.format("%s <= %s", x, hi)
  else                   return string.format("%s <  %s <= %s", lo,x,hi) end end

-- ### Update
-- Extend `xlo` `xhi` to cover `x`. Also, add `y` to `self.y`.
function XY:add(x,y)
  if x~="?" then
    if x < self.xlo then self.xlo=x end
    if x > self.xhi then self.xhi=x end
    self.y:add(y) end 
  return self end

-- ### Misc
function XY:merged(xy2,nMin,    new)
  new = self.y:merged(xy2.y, nMin)
  if new then
    return XY(self.at,self.name,self.xlo,xy2.xhi,new) end end

-- Return true if `row` selected by `self`
function XY:select(row,     v)
  v = row.cells[self.at]
  if v =="?" then return true end ------------------ assume yes for unknowns
  if self.xlo==self.xhi and v==self.xlo then return true end -- for symbols
  if self.xlo < v and v <= self.xhi     then return true end -- for numerics
end

-- Return subset of `rows` selected by `self`
function XY:selects(rows)
  return map(rows,function(row) if self:select(row) then return row end end) end

-- ## Class Methods
-- Manipulates sets of `XY`s.

-- ### Discretization
function XY.discretize(col,listOfRows,   xys,n)
  xys,n = XY.unsuper(col,listOfRows)
  return XY.super(col,xys,n) end

-- Supervised discretization
function XY.super(col,xys,n)
  n = the.min >= 1 and the.min or n^the.min
  return col:merges(sort(xys,lt"xlo"), n) end

-- Simple unsupervised discretization
function XY.unsuper(col,listOfRows)
  local n,xys = 0,{} 
  for label, rows in pairs(listOfRows) do
    for _,row in pairs(rows) do
      local x = row.cells[col.at]
      if x ~= "?" then
        n = n+ 1
        local bin = col:discretize(x)
        xys[bin]  = xys[bin] or XY(col.at,col.name,x)
        xys[bin]:add(x,label) end end end
  local xys1={}; for _,xy in pairs(xys) do l.push(xys1,xy) end 
  return sort(xys1,lt"xlo"), n end

-- That's all folks
return XY
