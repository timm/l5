local l=require"lib"
local the=require"about"
local Sample=require"sample"
local obj, per = l.obj, l.per

-- `Num` summarizes a stream of numbers.
local Num=obj"Num"

-- ## Create
function Num:new(c,s) 
  return {n=0, at=c or 0, name=s or "",  -- as per Sym
          _has = Sample(),  -- where we keep, at most, `the.sample` nums
          lo = math.huge,   -- lowest seen
          hi = -math.huge,  -- highest seen
          w = ((s or ""):find"-$" and -1 or 1) -- are we minimizing this?
         } end

-- ## Update
-- Reservoir sampler. Keep at most `the.nums` numbers 
-- (and if we run out of room, delete something old, at random).,  
function Num:add(v,    pos)
  if v=="?" then return v end
  self.n  = self.n + 1
  self.lo = math.min(v, self.lo)
  self.hi = math.max(v, self.hi)
  self._has:add(v) end 

-- ## Discretize
-- Discretize a number, rounds to  `the.bins` divisions.
function Num:discretize(x,     tmp)
  tmp = (self.hi - self.lo)/(the.bins - 1)
  return self.hi==self.lo and 1 or math.floor(x/tmp+.5)*tmp end 

-- ## Distance
-- distance between two values.
function Num:dist(v1,v2)
  if   v1=="?" and v2=="?" then return 1 end
  v1,v2 = self:norm(v1), self:norm(v2)
  if v1=="?" then v1 = v2<.5 and 1 or 0 end 
  if v2=="?" then v2 = v1<.5 and 1 or 0 end
  return math.abs(v1-v2) end 

-- ## Query
-- Return diversity
function Num:div() return self._has:div() end

-- Return middle
function Num:mid() return self._has:mid() end

-- Normalized numbers 0..1. Everything else normalizes to itself.
function Num:norm(n) 
 return x=="?" and x or (n-self.lo)/(self.hi-self.lo + 1E-32) end

-- ## Discretize
-- If too (small or complex), adjacent bins. Repeat till no more merges found.
function Num:merges(xys0,nMin,   n,xys1,fillInAnyGaps) 
  function fillInAnyGaps(xys) -- extend across whole number line
     for n = 2,#xys do xys[n].xlo = xys[n-1].xhi end 
     xys[  1  ].xlo = -math.huge
     xys1[#xys].xhi =  math.huge
     return xys 
  end --------- 
  n,xys1 = 1,{}
  while n <= #xys0 do
    local xymerged  = n<#xys0 and xys0[n]:merged(xys0[n+1],nMin) --skip last bin 
    xys1[1 + #xys1] = xymerged or xys0[n]       -- push something to xys1      
    n               = n + (xymerged and 2 or 1) -- if merged, skip next bin
  end
  return #xys1 == #xys0 and fillInAnyGaps(xys0) or self:merges(xys1,nMin) end

-- That's all folks.
return Num
