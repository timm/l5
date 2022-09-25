local l=require"xplorlib"
local X=require"xplor"

local the,DATA,NUM,SYM    = X.the,X.DATA,X.NUM,X.SYM
local o,on,oo,csv,map,rnd = l.o,l.on,l.oo,l.csv,l.map,l.rnd

-- -----------------------------------------------------------------------------
local go={}
function go.the() oo(the)  end

function go.num(     num)
  num = NUM()
  for i=1,100 do num:add(i) end
  print(num.mu, num.sd) end

function go.sym(     sym)
  sym = SYM()
  for _,s in pairs{"a","a","a","a","b","b","c"} do sym:add(s) end
  print(sym.mode, sym:entropy()) end

function go.csv(      data1,data2)
  data1 = load(the.file)
  map(data1.cols.x, function(col) print(1,o(rnd(col:div()))) end) 
  print""
  data2 = data1:clone(data1.rows)
  map(data2.cols.x, function(col) print(2,o(rnd(col:div()))) end) end
  
function go.sorted(      data,rows)
  data = load(the.file)
  rows= data:sorted() 
  for i=1,#rows,30 do print(i,o(rows[i].cells)) end end

function go.bestRest(      data,best,rest)
  data = load(the.file)
  best,rest = data:bestRest(20,3) 
  print(#best, #rest) 
  local splits=data:xys(20,3)
  print(splits[1].score, splits[1].xy)
end

-- -----------------------------------------------------------------------------
the = l.cli(the)                  
on(the,go)
