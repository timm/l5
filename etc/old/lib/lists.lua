-- deepcopy
local function copy(t1,    t2)
  if type(t1) ~= "table" then return t1 end
  t2={}; for k,v in pairs(t1) do t2[k] = copy(v) end
  return setmetatable(t2,getmetatable(t1))  end

-- Return the `n`-th thing from the sorted list `t`. e.g median is per(t.5).
local function per(t,n)
  n=math.floor(((n or .5)*#t)+.5); return t[math.max(1,math.min(#t,n))] end

-- Add to `t`, return `x`.
local function push(t,x) t[1+#t]=x; return x end

return {push=push,per=per,copy=copy}
