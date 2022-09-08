
-- **Return true if `row1`'s goals are worse than `row2:`.**
function ROW:__lt(row2)
  local row1=self
  row1.evaled,row2.evaled= true,true
  local s1,s2,d,n,x,y=0,0,0,0
  local ys,e = row1._about.y,math.exp(1)
  for _,col in pairs(ys) do
    x,y= row1.cells[col.at], row2.cells[col.at]
    x,y= col:norm(x), col:norm(y)
    s1 = s1 - e^(col.w * (x-y)/#ys)
    s2 = s2 - e^(col.w * (y-x)/#ys) end
  return s2/#ys < s1/#ys end



-- **XY summarize data from the same rows from two columns.**   
-- `num2` is optional (defaults to `num1`).   
-- `y` is optional (defaults to a new NOM)
function XY:new(str,at,num1,num2,nom)
  return {txt = str,
          at  = at,
          xlo = num1, 
          xhi = num2 or num1, 
          y   = nom or NOM(str,at)} end



          ---- ---- ---- Discretization
-- **Divide column values into many bins, then merge unneeded ones**   
-- When reading this code, remember that NOMinals can't get rounded or merged
-- (only RATIOS).
local bins={}
function bins.find(rows,col)
  local n,xys = 0,{} 
  for _,row in pairs(rows) do
    local x = row.cells[col.at]
    if x~= "?" then
      n = n+1
      local bin = col.isNom and x or bins._bin(col,x)
      local xy  = xys[bin] or XY(col.txt,col.at, x)
      add2(xy, x, row.label)
      xys[bin] = xy end end
  xys = sort(xys, lt"xlo")
  return col.isNom and xys or bins._merges(xys,n^the.min) end

-- RATIOs get rounded into  `the.bins` divisions.
function bins._bin(ratio,x,     a,b,lo,hi)
  a = ratio:holds()
  lo,hi = a[1], a[#a]
  b = (hi - lo)/the.bins
  return hi==lo and 1 or math.floor(x/b+.5)*b  end 

-- While adjacent things can be merged, keep merging.
-- Then make sure the bins to cover &pm; &infin;.
function bins._merges(xys0,nMin) 
  local n,xys1 = 1,{}
  while n <= #xys0 do
    local xymerged = n<#xys0 and bins._merged(xys0[n], xys0[n+1],nMin) 
    xys1[#xys1+1]  = xymerged or xys0[n]
    n = n + (xymerged and 2 or 1) -- if merged, skip next bin
  end
  if   #xys1 < #xys0 
  then return bins._merges(xys1,nMin) 
  else xys1[1].xlo = -big
       for n=2,#xys1 do xys1[n].xlo = xys1[n-1].xhi end 
       xys1[#xys1].xhi = big
       return xys1 end end

-- Merge two bins if they are too small or too complex.
-- E.g. if each bin only has "rest" values, then combine them.
-- Returns nil otherwise (which is used to signal "no merge possible").
function bins._merged(xy1,xy2,nMin)   
  local i,j= xy1.y, xy2.y
  local k = NOM(i.txt, i.at)
  for x,n in pairs(i.has) do add(k,x,n) end
  for x,n in pairs(j.has) do add(k,x,n) end
  local tooSmall   = i.n < nMin or j.n < nMin 
  local tooComplex = div(k) <= (i.n*div(i) + j.n*div(j))/k.n 
  if tooSmall or tooComplex then 
    return XY(xy1.txt,xy1.at, xy1.xlo, xy2.xhi, k) end end 


    -- **XY summarize data from the same rows from two columns.**
-- `num2` is optional (defaults to `num1`).
-- `y` is optional (defaults to a new NOM)
function XY:new(str,at,num1,num2,nom)
  return {txt = str,
          at  = at,
          xlo = num1,
          xhi = num2 or num1,
          y   = nom or NOM(str,at)} end



