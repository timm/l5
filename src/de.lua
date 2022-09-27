cf=.3
f=.3
function any(t) return t[math.random(#t)] end

local k,old
for _=1,3 do
  for i,t in pairs(ts) do
    a,b,c,d = any(t),any(t), any(t),{}
    k=math.random(#a)
    old =a[k]
    for j,_ in pairs(a) do
      d[j] = math.random() < cf and  a[i] + f*(b[i] - c[j]) or a[i] end
    d[k] = old 
    if better(d,t) then t[i]=d end end end 


