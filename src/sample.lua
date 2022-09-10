local l=require"lib"
local the=require"about"
local obj, per = l.obj, l.per

-- `Sample` keeps at most `the.sample` numbers.
local Sample=obj"Sample"

function Sample:new(c,s) 
  return {n=0,               -- number items seen so far
          _has={},           -- cache for values
          isSorted=true} end -- false if no sort since last update

-- Reservoir sampler. Keep at most `the.sample` numbers 
-- (and if we run out of space, delete something old, at random).,  
function Sample:add(v,    pos)
  self.n  = self.n + 1
  if     #self._has < the.sample           then pos=1 + (#self._has) 
  elseif math.random() < the.sample/self.n then pos=math.random(#self._has) end
  if pos then self.isSorted = false 
              self._has[pos] = tonumber(v) end end 

-- Return diversity
function Sample:div() return (per(self:nums(),.9) - per(self:nums(),.1))/2.58 end

-- Return middle
function Sample:mid() return per(self:nums(), .5) end

-- Return kept numbers, sorted. 
function Sample:nums()
  if not self.isSorted then table.sort(self._has) end
  self.isSorted = true 
  return self._has end

-- That's all folks.
return Sample
