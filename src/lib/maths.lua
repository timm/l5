require"strings"
-- ### Maths
function rnd(x, places) 
  local mult = 10^(places or 2)
  return math.floor(x * mult + 0.5) / mult end

  return {rnd=rnd}

