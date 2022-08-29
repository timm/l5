-- `Num` summarizes a stream of numbers.
local l=require"lib"
local the=require"about"
local obj,per = l.obj,l.per

-- Constructor
local Num = obj"Num"
function Num:new(c,s) 
  return {n=0,at=c or 0, name=s or "", _has={}, -- as per Sym
          lo= math.huge,   -- lowest seen
          hi= -math.huge,  -- highest seen
          isSorted=true,   -- no updates since last sort of data
          w = ((s or ""):find"-$" and -1 or 1)  
         } end

-- Reservoir sampler. Keep at most `the.nums` numbers 
-- (and if we run out of room, delete something old, at random).,  
function Num:add(v)
  if v~="?" then 
    self.n  = self.n + 1
    self.lo = math.min(v, self.lo)
    self.hi = math.max(v, self.hi)
    if     #self._has < the.nums  
    then   self.isSorted=false
           push(self._has,v)
    elseif math.random() < the.nums/self.n then
           self.isSorted=false
           self._has[math.random(#self._has)] = v end end end

-- Diversity (standard deviation for Nums, entropy for Syms)
function Num:div(    a)  a=self:nums(); return (per(a,.9)-per(a,.1))/2.58 end

-- Central tendency (median for Nums, mode for Syms)
function Num:mid() return per(self:nums(),.5) end 

-- Return kept numbers, sorted. 
function Num:nums()
  if not self.isSorted then table.sort(self._has); self.isSorted=true end
  return self._has end

return Num
