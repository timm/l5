local l=require"xplorlib"
local X=require"xplor"

local the,DATA,NUM,SYM = X.the,X.DATA,X.NUM,X.SYM
local o,on,oo,csv,map  = l.o,l.on,l.oo,l.csv,l.map

-- -----------------------------------------------------------------------------
local go={}
function go.the() oo(the)  end

function go.num(     num)
  num=NUM()
  for i=1,100 do num:add(i) end
  print(num.mu, num.sd) end

function go.sym(     sym)
  sym=SYM()
  for _,s in pairs{"a","a","a","a","b","b","c"} do sym:add(s) end
  print(sym.mode, sym:entropy()) end

function go.csv(      data)
  data = load(the.file)
  map(data.cols.x, oo) end

function go.sorted(      data,rows)
  data = load(the.file)
  rows= data:sorted() 
  for i=1,#rows,30 do print(i,o(rows[i])) end end

function go.bestRest(      data,rows)
  csv(the.file, function(t) if data then data:add(t) else data=DATA(t) end end)
  data:bestRest(20,3) end

function go.contrast(    data)
  csv(the.file, function(t) if data then data:add(t) else data=DATA(t) end end)
  best, rest = data:bestRest(20,3) 
end

-- -----------------------------------------------------------------------------
the = l.cli(the)                  
on(the,go)
