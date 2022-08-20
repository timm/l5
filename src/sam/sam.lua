-- sam.lua : reasoning via minimal sampling arcoss the data   
-- (c)2022 Tim Menzies <timm@ieee.org> BSD 2 clause license
local l=require"lib"
local any,cat,cli,coerce,copy,csv = l.any,l.cat,l.cli,l.coerce,l.copy,l.csv
local lines,many,obj,per,push = l.lines,l.many,l.obj,l.per,l.push
local rogues,words = l.rogues,l.words

local rand = math.random
local Cols,Data,Row,Num,Sym = obj"Cols", obj"Data", obj"Row",obj"Num", obj"Sym"

local the={example="ls", ratios=256, bins=8, seed=10019, some=512}

-- Num -------------------------------------------------------------------------
function Num:new(at,txt) 
  txt = txt or ""
  return {n=0,at=at or 0, txt=txt, cache=nil, has={},
          hi= -math.huge, lo= math.huge, w=txt:find"-$" and -1 or 1} end

function Num:add(x)
  if x ~= "?" then
    local pos
    self.n  = self.n + 1
    self.lo = math.min(x, self.lo)
    self.hi = math.max(x, self.hi)
    if     #self.has < the.ratios        then pos = 1 + (#self.has) 
    elseif rand()    < the.ratios/self.n then pos = rand(#self.has) end
    if pos then self.cache=nil 
                self.has[pos]=x end end end

function Num:discretize(x,  y)
  for _,n in pairs(self.cache) do y=n; if x <= y then return y end end
  return y end

function Num:dist(x,y)
   if x=="?" and y=="?" then return 1 end
   if     x=="?" then y=self:norm(y); x=y<.5 and 1 or 0
   elseif y=="?" then x=self:norm(x); y=x<.5 and 1 or 0
   else   x,y = self:norm(x), self:norm(y) end
  return math.abs(x-y) end

local function _breaks(a)
  local b = #a//self.bins
  local t,n  = {}, b
  while n <= #a-b do if a[n]~=a[n+1] then push(t,a[n]); n=n+b else n=n+1 end end 
  return t end 

function Num:holds(    a,n,jump)
  if not self.cache then 
    table.sort(self.has)
    self.cache = _breaks(self.has) end
  return self.has, self.cache end

function Num:mid() return per(self:holds(),.5) end

function Num:norm(num)
  return self.hi - self.lo < 1E-9 and 0 or (num-self.lo)/(self.hi-self.lo) end

function Num:div(  a) 
  a=self:holds()
  return (per(a,.9) - per(a,.1))/2.58 end

-- Sym -------------------------------------------------------------------------
function Sym:new(at,txt) 
  return {n=0,at=at or 0, txt=txt or "", ready=false, has={}} end

function Sym:add(x)
  if x ~= "?" then
    self.n = self.n + 1
    self.has[x] = 1+(self.has[x] or 0) end end

function Sym:discretize(x) return x end

function Sym:dist(x,y) 
    return (x=="?" or y=="?") and 1 or x==y and 0 or 1 end

function Sym:mid(    mode,most)
  for k,n in pairs(i.has) do if not mode or n>most then mode,most=k,n end end
  return mode end

function Sym:div(  e)
  local function p(x) return x*math.log(x,2) end
  e=0; for _,v in pairs(i.has) do if v>0 then e=e-p(v/i.n) end; return e end end

-- Row ------------------------------
-- function Data.far(XXX) end
--
  
function Data:half(rows, above, all)
   local all  = all or self.rows
   local some = many(all, the.some)
   local left = above or far(any(some), some) end
-- (defmethod half ((i rows) &optional all above)
--   "Split rows in two by their distance to two remove points."
--   (let* ((all   (or    all (? i _has)))
--          (some  (many  all (! my some)))
--          (left  (or    above (far (any some) some)))
--          (right (far   left some))
--          (c     (dists left right))
--          (n 0)  lefts rights)
--     (labels ((project (row)
--                 (let ((a (dists row left))
--                       (b (dists row right)))
--                   (cons (/ (+ (* a a) (* c c) (- (* b b))) (* 2 c)) row))))
--       (dolist (one (sort (mapcar #'project all) #'car<))
--         (if (<= (incf n) (/ (length all) 2))
--           (push (cdr one) lefts)
--           (push (cdr one) rights)))
--       (values left right lefts rights c))))
--
-- -----------------------------------------------------------------------------
return {the=the,Cols=Cols, Data=Data, Num=Num, Sym=Sym}
