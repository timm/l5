
-- P. L'Ecuyer, "Combined Multiple Recursive Random Number Generators"
-- Operations Research, 44, 5 (1996), 816–822.

-- generates a 'random' number x, 0 <= x < 1
local random
do
    -- fill these two arrays with start values in [0..2^31-1)
    local X = {990831825, 586698796, 1722973357}
    local Y = {239391773, 1747290357, 373426315}

    -- moduli
    local M1 = 2147483647
    local M2 = 2145483479

    function random()
        local xn = (63308*X[2] - 183326*X[3]) % M1
        local yn = (86098*Y[1] - 539608*Y[3]) % M2
        X = {xn, X[1], X[2]}
        Y = {yn, Y[1], Y[2]}
        return ((xn - yn) % M1)/M1
    end
end

for i = 1, 10000 do
    local r = random()
    print(r)
end

