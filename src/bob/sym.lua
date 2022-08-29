-- `Symm` summarizes a stream of symbols.
local l=require"lib"
local obj=l.obj

-- Constructor
local Sym = obj"Sym"
function Sym:new(c,s) 
  return {n=0,          -- items seen
          at=c or 0,    -- column position
          name=s or "", -- column name
          _has={}       -- kept data
         } end

-- Add one thing to `col`. 
function Sym:add(v) return self:adds(v,1) end

-- Add n  things to `col`. 
function Sym:add(v,n)
  if v~="?" then self.n=self.n+n; self._has[v]= n+(self._has[v] or 0) end end

-- Diversity of distribution. Entropy.
function Sym:div(    e,fun)
  function fun(p) return p*math.log(p,2) end
  e=0; for _,n in pairs(self._has) do if n>0 then e=e - fun(n/self.n) end end
  return e end 

-- Central tendency (median)
function Sym:mid(col,    most,mode) 
  most=-1; for k,v in pairs(self._has) do if v>most then mode,most=k,v end end
  return mode end 

return Sym
