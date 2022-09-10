local o =require("strings").o

local function new(k,...) 
  local i=setmetatable({},k);
  return setmetatable(t.new(i,...) or i,k) end

-- obj("Thing") enables a constructor Thing:new() ... and a pretty-printer
-- for Things.
local function obj(s,    t)
  t={__tostring = function(x) return s..o(x) end}
  t.__index = t;return setmetatable(t,{__call=new}) end

return  {obj=obj}

