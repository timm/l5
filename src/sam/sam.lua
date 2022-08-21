-- sam.lua : reasoning via minimal sampling arcoss the data   
-- (c)2022 Tim Menzies <timm@ieee.org> BSD 2 clause license
local l=require"lib"
local any,cat,cli,coerce,copy,csv = l.any,l.cat,l.cli,l.coerce,l.copy,l.csv
local lines,many,obj,per,push = l.lines,l.many,l.obj,l.per,l.push
local rogues,words = l.rogues,l.words

local rand = math.random
local Cols,Data,Row,Num,Sym = obj"Cols", obj"Data", obj"Row",obj"Num", obj"Sym"

local the={bins    = 10,
           cohen   = .35,
           example = "ls", 
           ratios  = 256, 
           seed    = 10019, 
           some    = 512}

-- Num -------------------------------------------------------------------------
function Num:new(at,txt) 
  txt = txt or ""
  return {n=0,at=at or 0, txt=txt, details=nil, has={},
          hi= -math.huge, lo= math.huge, w=txt:find"-$" and -1 or 1} end

function Num:add(x)
  if x ~= "?" then
    local pos
    self.n  = self.n + 1
    self.lo = math.min(x, self.lo)
    self.hi = math.max(x, self.hi)
    if     #self.has < the.ratios        then pos = 1 + (#self.has) 
    elseif rand()    < the.ratios/self.n then pos = rand(#self.has) end
    if pos then self.details  = nil 
                self.has[pos] = x end end end

function Num:bin(x,     a,b,lo,hi)
  local b = (self.hi - self.lo)/the.bins
  return self.hi==self.lo and 1 or math.floor(x/b+.5)*b  end

function Num:discretize(x)
  _, details = self:holds()
  for _,bin in pairs(details) do
    if x> bin.lo and x<=bin.hi then return x end end end

function Num:dist(x,y)
   if x=="?" and y=="?" then return 1 end
   if     x=="?" then y=self:norm(y); x=y<.5 and 1 or 0
   elseif y=="?" then x=self:norm(x); y=x<.5 and 1 or 0
   else   x,y = self:norm(x), self:norm(y) end
  return math.abs(x-y) end

local function _div(a,epsilon,bins,   inc,one,all)
  inc = #a // bins
  one = {lo=a[1], hi=a[1], n=0}
  all = {one}
  for i = 1,#a-inc do
    if   one.n >= inc and a[i] ~= a[i+1] and one.hi-one.lo > epsilon 
    then one = push(all, {lo=one.hi, hi=a[i], n=0}) end
    one.hi = a[i]
    one.n  = bin.n + 1 end 
  all[1].lo     = -math.huge
  all[#bins].hi = math.huge
  return all end

function Num:holds(    inc,i)
  if not self.details then 
    table.sort(self.has)
   self.details = _div(self.has, self:div()*my.cohen, my.bins); end
  return self.has, self.details end

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
function Row:new(t) return {cells=t, cooked=copy(t), evaled=false} end

-- Cols ------------------------------
function Cols:new(names)
  self.names=names
  self.x, self.y, self.all, self.klass = {},{},{},nil
  for at,txt in pairs(names) do
    col = push(self.all, (txt:find"^[A-Z]" and Num or Sym)(at,txt))
    if not txt:find":$" then
      push(txt:find"[!+-]$" and self.y or self.x, col)
      if txt:find"!$" then self.klass=col end end end end

function Cols:add(row)
  for _,cols in pairs{i.x, i.y} do
    for col in pairs(cols) do
      col:add(row.cells[cols.at]) end end end

-- Data ------------------------------
function Data:new(s) 
  self.rows, self.cols = {}, nil
  if type(s)=="string" then csv(s, function(t)           self:add(t) end ) 
                       else for _,t in pairs(s or {}) do self:add(t) end end end  

function Data:add(t)
  if   self.cols
  then self.cols:add( push(self.rows, t.cells or Row(t)))
  else self.cols= Cols(t) end 
 
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
return {the=the, Cols=Cols, Data=Data, Num=Num, Sym=Sym}
