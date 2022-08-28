local b4={}; for k,v in pairs(_ENV) do b4[k]=v end -- LUA trivia. Ignore.

-- Find rogue locals.
local function rogues()
  for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end end

return {rogues=rogues}
