-- [about](about.html) | [cols](cols.html) | [data](data.html) |
-- [eg](eg.html) | [lib](lib.html) | [num](num.html) | [row](row.html) | [sym](sym.html)<hr>

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
function Sym:add(v)
  if v~="?" then self.n=self.n+1; self._has[v]= 1+(self._has[v] or 0) end end

function Sym:mid(col,    most,mode) 
  most=-1; for k,v in pairs(self._has) do if v>most then mode,most=k,v end end
  return mode end 

-- distance between two values.
function Sym:dist(v1,v2)
  return  v1=="?" and v2=="?" and 1 or v1==v2 and 0 or 1 end

-- Diversity measure for symbols = entropy.
function Sym:div(    e,fun)
  function fun(p) return p*math.log(p,2) end
  e=0; for _,n in pairs(self._has) do if n>0 then e=e - fun(n/self.n) end end
  return e end 


-- That's all folks
return Sym
