local l=require"lib"

-- `Sym`s summarize a stream of symbols.
local Sym=l.obj"Sym"

function Sym:new(c,s) 
  return {n=0,          -- items seen
          at=c or 0,    -- column position
          name=s or "", -- column name
          _has={}       -- kept data
         } end

-- Add one thing to `col`. For Num, keep at most `nums` items.
function Sym:add(v,  inc)
  if v=="?" then return v end
  inc = inc or 1
  self.n = self.n + inc
  self._has[v] = inc + (self._has[v] or 0) end 

-- Score b^2/(b+r) where `b` is for any counts for `goals`.
function Sym:bestOrRest(goal,B,R,    b,r,e)
  b,r,e = 0,0,1E-30
  for x,n in pairs(self._has) do
    if x == goal then b=b+n else r=r+n end end
  b,r = b/(B+e), r/(R+e)
  return b^2/(b+r+e) end

-- Discretize a symbol (which means just return the symbol).
function Sym:discretize(x) return x end

-- distance between two values.
function Sym:dist(v1,v2)
  return  v1=="?" and v2=="?" and 1 or v1==v2 and 0 or 1 end

-- Diversity measure for symbols = entropy.
function Sym:div(    e,fun)
  function fun(p) return p*math.log(p,2) end
  e=0; for _,n in pairs(self._has) do if n>0 then e=e - fun(n/self.n) end end
  return e end 

-- Merge two ranges, if they are tooSmall or tooComplex
function Sym:merged(sym2,nMin,    new,tooSMall,t)   
  local new = Sym(self.at, self.name)
  for x,n in pairs(self._has) do new:add(x,n) end
  for x,n in pairs(sym2._has) do new:add(x,n) end
  local tooSmall  = self.n < nMin or sym2.n < nMin 
  local tooComplex= new:div() <= (self.n*self:div() + sym2.n*sym2:div())/new.n 
  if tooSmall or tooComplex then return new end end

-- Merge many XY ranges. For symbolic columns, just return the lists.
function Sym:merges(xys,...) return xys end

-- Central tendency
function Sym:mid(col,    most,mode) 
  most=-1; for k,v in pairs(self._has) do if v>most then mode,most=k,v end end
  return mode end 

-- That's all folks
return Sym
