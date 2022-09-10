local coerce=require("strings").coerce

-- Parse `s` for lines containing options
local function settings(s,   t)
  t={}
  s:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)",
          function(k,x) t[k]=coerce(x) end)
  t._help=s
  return t end

-- Update settings from values on command-line flags. 
-- Booleans need no values (we just flip the defaults).
local function cli(t)
  for slot,v in pairs(t) do
    v = tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(slot:sub(1,1)) or x=="--"..slot then
        v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
    t[slot] = coerce(v) end
  if t.help then os.exit(print("\n"..help.."\n")) end
  return t end

return {cli=cli, settings=settings}
