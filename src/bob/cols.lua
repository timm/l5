-- `Cols` builds and maintains sets of columns.
local l=require"lib"
local obj,push = l.obj,l.push
local Num,Sym = require"num", require"sym"

-- Constructor. 
-- Columns are created once, then may appear in  multiple slots.
local Cols = l.obj"Cols"
function Cols:new(names,    col) 
  self.names=names -- all column names
  self.all={}      -- all the columns (including the skipped ones)
  self.klass=nil   -- the single dependent klass column (if it exists)
  self.x={}        -- independent columns (that are not skipped)
  self.y={}        -- dependent columns (that are not skipped)
  for c,s in pairs(names) do
    col = push(self.all, -- Numerics start with Uppercase. 
               (s:find"^[A-Z]*" and Num or Sym)(c,s))
    if not s:find":$" then -- some columns are skipped
       push(s:find"[!+-]" and self.y or self.x, col) -- some cols are goal cols
       if s:find"!$" then self.klass=col end end end end

return Cols
