local l=require"lib"
local obj,per = l.obj,l.per

-- `Num` summarizes a stream of numbers.
local Num=obj"Num"
function Num:new(c,s) 
  return {n=0,at=c or 0, name=s or "", _has={}, -- as per Sym
          lo= math.huge,   -- lowest seen
          hi= -math.huge,  -- highest seen
          isSorted=true,   -- no updates since last sort of data
          w = ((s or ""):find"-$" and -1 or 1)  
         } end

-- Return kept numbers, sorted. 
function Num:nums()
  if not self.isSorted then table.sort(self._has) end
  self.isSorted = true 
  return self._has end

-- Reservoir sampler. Keep at most `the.nums` numbers 
-- (and if we run out of room, delete something old, at random).,  
function Num:add(v,    pos)
  if v~="?" then 
    self.n  = self.n + 1
    self.lo = math.min(v, self.lo)
    self.hi = math.max(v, self.hi)
    if     #self._has < the.nums           then pos=1 + (#self._has) 
    elseif math.random() < the.nums/self.n then pos=math.random(#self._has) end
    if pos then self.isSorted = false 
                self._has[pos] = tonumber(v) end end end 

-- distance between two values.
function Num:dist(v1,v2)
  if   v1=="?" and v2=="?" then return 1 end
  v1,v2 = self:norm(v1), self:norm(v2)
  if v1=="?" then v1 = v2<.5 and 1 or 0 end 
  if v2=="?" then v2 = v1<.5 and 1 or 0 end
  return math.abs(v1-v2) end 

-- Return middle
function Num:mid() return per(self:nums(), .5) end

-- Return diversity
function Num:div() return (per(self:nums(), .9) - per(self:nums(),.1))/2.58 end

-- Normalized numbers 0..1. Everything else normalizes to itself.
function Num:norm(n) 
  return x=="?" and x or (n-self.lo)/(self.hi-self.lo + 1E-32) end


