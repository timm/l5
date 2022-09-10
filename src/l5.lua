local l=require"lib"
local csv,gt,map,o,oo,slice,sort = l.csv,l.gt,l.map,l.o,l.oo,l.slice,l.sort
local the = require"about"
local XY = require"xy"
local Num,Sym = require"num", require"sym"
local Data,Cols,Row = require"data", require"cols", require"row"
local eg,fails = {},0

-- To run a test:
-- 1. reset random number seed before running something.
-- 2. Cache the detaults settings, and...
-- 3. ... restore them after the test
-- 4. Print error messages or stack dumps as required.
-- 5. Return true if this all went well.
local function run(todo,     old,status,out,msg)
  if not eg[todo] then return end
  math.randomseed(the.seed) -- reset seed [1]
  old={}; for k,v in pairs(the) do old[k]=v end --  [2]
  if the.dump then -- [4]
    status,out=true, eg[todo]() -- crash on errors, printing stack dump
  else
    status,out=pcall(eg[todo]) -- on error, set status to false, then keep going.
  end
  for k,v in pairs(old) do the[todo]=v end -- restore old settings [3]
  msg = status and ((out==true and "PASS") or "FAIL") or "CRASH" -- [4]
  print("!!!!!!", msg, todo, status)
  return out or err end

-- Uncomment this test to check what happens when something goes wrong.
-- function eg.BAD() print(eg.dont.have.this.field) end

-- Sort all test names.
function eg.LIST(   t)
  t={}; for k,_ in pairs(eg) do t[1+#t]=k end; table.sort(t); return t end

-- List test names.
function eg.LS()
  print("\nExamples lua csv -e ...")
  for _,k in pairs(eg.LIST()) do print(string.format("\t%s",k)) end 
  return true end

-- Run all tests
function eg.ALL()
  for _,k in pairs(eg.LIST()) do 
    if k ~= "ALL" then
      print"\n-----------------------------------"
      if not runs(k) then fails=fails+ 1 end end end 
  return true end

-- Settings come from big string on top of `about.lua`
-- (maybe updated from command line)
function eg.the() oo(the); return true end

-- The middle and diversity of a set of symbols is called "mode" 
-- and "entropy" (and the latter is zero when all the symbols 
-- are the same).
function eg.sym(  sym,entropy,mode)
  sym=Sym()
  for _,x in pairs{"a","a","a","a","b","b","c"} do sym:add(x) end
  mode, entropy = sym:mid(), sym:div()
  entropy = (1000*entropy)//1/1000
  oo({mid=mode, div=entropy})
  return mode=="a" and 1.37 <= entropy and entropy <=1.38 end

-- The middle and diversity of a set of numbers is called "median" 
-- and "standard deviation" (and the latter is zero when all the nums 
-- are the same).
function eg.num(  num,mid,div)
  num=Num()
  for i=1,100 do num:add(i) end
  mid,div = num:mid(), num:div()
  print(mid ,div)
  return 50<= mid and mid<= 52 and 30.5 <div and div<32 end 

-- `Num`s store only a sample of the numbers added to it (and that storage 
-- is done such that the kept numbers span the range of inputs).
function eg.bignum(  num)
  num=Num()
  the.sample = 32
  for i=1,10000 do num:add(i) end
  oo(num._has:nums())
  return 32==#num._has._has; end

-- Show we can read csv files.
function eg.csv(   n) 
  n=0
  csv("../data/auto93.csv",function(row)
    n=n+1; if n> 10 then return else oo(row) end end); return true end

-- Can I load a csv file into a Data?.
function eg.data(   d)
  d = Data("../../data/auto93.csv")
  for _,col in pairs(d.cols.y) do oo(col) end
  return true end

-- Print some stats on columns.
function eg.stats(   data,mid,div)
  data = Data("../data/auto93.csv")
  print("xmid", o( data:stats(2, data.cols.x, "mid")))
  print("xdiv", o( data:stats(3, data.cols.x, "div")))
  print("ymid", o( data:stats(2, data.cols.y, "mid")))
  print("ydiv", o( data:stats(3, data.cols.y, "div")))
  return true end

-- Distance functions.
function eg.around(    data,around)
  data = Data("../data/auto93.csv") 
  print(data.rows[1]:dist(data.rows[2]))
  around = data.rows[1]:around(data.rows)
  for i=1,#data.rows,32 do print(i, o(around[i].row.cells),around[i].dist) end
  return true end

-- Multi-objective sorting can rank "good" rows before the others.
function eg.sort(    data,around)
  data = Data("../data/auto93.csv") 
  table.sort(data.rows)
  print(o(map(data.cols.y, function(col) return col.name end)))
  for i=1,#data.rows,32 do 
      print(o(data.rows[i]:cols(data.cols.y)),i) end 
  return true end

-- Sort on goals, report median goals seen in best or rest.
function eg.bestOrRest(   data,bestRows,restRows,best,rest)
  data = Data("../data/auto93.csv") 
  bestRows,restRows = data:bestOrRest()
  best,rest = data:clone(bestRows), data:clone(restRows)
  print("besty", o(best:stats()))
  print("resty", o(rest:stats()))
  return true end

-- Simple unsupervised discretization. Break numbers on (max-min)/the.bins.
function eg.unsuper(   data,bests,rests,fun,rows,best)
  data = Data("../data/auto93.csv") 
  bests,rests = data:bestOrRest()
  for _,col in pairs(data.cols.x) do
    print("\n" .. col.name)
    for _,xy in pairs(XY.unsuper(col,{bests=bests,rests=rests})) do 
       print(xy.y.n, 
             string.format("%-20s",o(xy.y._has)), 
             xy) end end 
  return true end

-- Supervised discretization. When we reflect on the unsupervised ranges,
-- some are too small and some needlessly complicate the data and some 
-- are very weak at selecting for the "best" rows. So lets combine the
-- small and complex ones and rank the remaining by how well they select for best.
function eg.super(   data,bests,rests,fun,rows,best,old,z)
  data = Data("../data/auto93.csv") 
  bests,rests = data:bestOrRest()
  fun = function(xy) return {xy=xy,z=xy.y:bestOrRest("bests", #bests, #rests)} end
  old=""
  for _,xy in pairs(map(data:contrasts({rests=rests,bests=bests}),fun)) do
    z=xy.z
    xy=xy.xy
    if xy.name ~= old then print("\n"..xy.name) end
    old = xy.name
    print(xy.y.n, 
          string.format("%-20s",o(xy.y._has)), 
          string.format("%-20s",xy),
          l.rnd(z,3)) end 
  -- rows=map(data.rows, 
  --          function(row) if best:selects(row) then return row end end)
  -- print(#rows)
  return true end

-- ---------------------------------
-- Start up
-- - Update settings from command-line.
-- - Run an example.
-- - Run some lint code (in this case, to find any rogue globals).
-- - Report back to the operating system the number of errors found.
the = l.cli(the)  
run(the.eg)
l.rogues() 
os.exit(fails) 
