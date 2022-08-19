-- sam.lua : reasoning via minimal sampling arcoss the data
-- (c)2022 Tim Menzies <timm@ieee.org> BSD 2 clause license
local l=require"lib"
local any,cat,cli,coerce,copy,csv = l.any,l.cat,l.cli,l.coerce,l.copy,l.csv
local lines,many,obj,push = l.lines,l.many,l.obj,l.push
local rogues,words = l.rogues,l.words

local rand = math.random
local Cols,Data,Row,Num,Sym = obj"Cols", obj"Data", obj"Row",obj"Num", obj"Sym"

local the={example="ls", ratios=256, bins=8, seed=10019, some=512}
-- Num -------------------------------------------------------------------------
function Num:new(at,txt) 
  txt = txt or ""
  return {n=0,at=at or 0, txt=txt, ready=false, has={},
          hi= -math.huge, lo= math.huge, w=txt:find"-$" and -1 or 1} end

function Num:add(x)
  if x ~= "?" then
    local pos
    self.n  = self.n + 1
    self.lo = math.min(x, self.lo)
    self.hi = math.max(x, self.hi)
    if     #self.has < the.ratios        then pos = 1 + (#self.has) 
    elseif rand()    < the.ratios/self.n then pos = rand(#self.has) end
    if pos then self.ready=false 
                self.has[pos]=x end end end

function Num:discretize(x)
  local b = (self.hi - self.lo)/the.bins
  return self.hi==self.lo and 1 or math.floor(x/b+.5)*b  end 

function Num:dist(x,y)
   if x=="?" and y=="?" then return 1 end
   if     x=="?" then y=self:norm(y); x=y<.5 and 1 or 0
   elseif y=="?" then x=self:norm(x); y=x<.5 and 1 or 0
   else   x,y = self:norm(x), self:norm(y) end
  return math.abs(x-y) end

function Num:holds()
  if not self.ready then table.sort(self.has); self.ready=true end
  return self.has end

function Num:norm(num)
  return self.hi - self.lo < 1E-9 and 0 or (num-self.lo)/(self.hi-self.lo) end

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


-- Row -------------------------------------------------------------------------
function Row:new(cells) return {cells=cells, cooked=copy(cells)} end

-- Cols ------------------------------------------------------------------------
function Cols:new(names)
  self.names, self.x, self.y, self.all= names, {}, {}, {} 
  for at,txt in pairs(names) do
    local what = txt:find"^[A-Z]" and Num or Sym
    local col  = push(self.all, what(at,txt))
    if not txt:find":$" then
      push(txt:find"[!+-]$" and self.y or self.x, col) end end end

-- Data ------------------------------------------------------------------------
local function rows(src)
  if type(src) == "table" then return src else
    local u={}; csv(src, function(t) push(u,t) end); return u end end

function Data:new(rows)
  self.rows, self.cols = {},{}
  for i,row in pairs(rows) do
    if   i==1 
    then self.cols = Cols(row) 
    else push(self.rows, Row(row))
         for cols in pairs{self.cols.x, self.cols.y} do
           for col in pairs(cols) do col:add(row[col.at]) end end end end  
  for cols in pairs{self.cols.x, self.cols.y} do
    for _,row in pairs(self.rows) do
        row.cooked[col.at] = col:discretize(row.cells[col.at]) end end end 

-- function Data:around(row1, rows)
--   return sort(map(rows, function(row2) return {row=row2,d = row1-row2} end),--#
--              lt"d") end
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
