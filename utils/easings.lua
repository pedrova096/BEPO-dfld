local M = {}
M.__index = M

-- Linear
M.linear = function(t) return t end

-- Quad
M.in_quad = function(t) return t * t end
M.out_quad = function(t) return t * (2 - t) end
M.inout_quad = function(t)
  if t < 0.5 then
    return 2 * t * t
  else
    return -1 + (4 - 2 * t) * t
  end
end

-- Cubic
M.in_cubic = function(t) return t * t * t end
M.out_cubic = function(t) return 1 - math.pow(1 - t, 3) end
M.inout_cubic = function(t)
  if t < 0.5 then
    return 4 * t * t * t
  else
    return 1 - math.pow(-2 * t + 2, 3) / 2
  end
end

-- Quart
M.in_quart = function(t) return t * t * t * t end
M.out_quart = function(t) return 1 - math.pow(1 - t, 4) end
M.inout_quart = function(t)
  if t < 0.5 then
    return 8 * t * t * t * t
  else
    return 1 - math.pow(-2 * t + 2, 4) / 2
  end
end

-- Quint
M.in_quint = function(t) return t * t * t * t * t end
M.out_quint = function(t) return 1 - math.pow(1 - t, 5) end
M.inout_quint = function(t)
  if t < 0.5 then
    return 16 * t * t * t * t * t
  else
    return 1 - math.pow(-2 * t + 2, 5) / 2
  end
end

-- Sine
M.in_sine = function(t) return 1 - math.cos(t * math.pi / 2) end
M.out_sine = function(t) return math.sin(t * math.pi / 2) end
M.inout_sine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end

-- Expo
M.in_expo = function(t)
  if t == 0 then return 0 end
  return math.pow(2, 10 * (t - 1))
end
M.out_expo = function(t)
  if t == 1 then return 1 end
  return 1 - math.pow(2, -10 * t)
end
M.inout_expo = function(t)
  if t == 0 then return 0 end
  if t == 1 then return 1 end
  if t < 0.5 then
    return math.pow(2, 20 * t - 10) / 2
  else
    return (2 - math.pow(2, -20 * t + 10)) / 2
  end
end

-- Circ
M.in_circ = function(t) return 1 - math.sqrt(1 - t * t) end
M.out_circ = function(t) return math.sqrt(1 - math.pow(t - 1, 2)) end
M.inout_circ = function(t)
  if t < 0.5 then
    return (1 - math.sqrt(1 - math.pow(2 * t, 2))) / 2
  else
    return (math.sqrt(1 - math.pow(-2 * t + 2, 2)) + 1) / 2
  end
end

-- Back
M.in_back = function(t)
  local c1 = 1.70158
  local c3 = c1 + 1
  return c3 * t * t * t - c1 * t * t
end
M.out_back = function(t)
  local c1 = 1.70158
  local c3 = c1 + 1
  return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
end
M.inout_back = function(t)
  local c1 = 1.70158
  local c2 = c1 * 1.525
  if t < 0.5 then
    return (math.pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2
  else
    return (math.pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2
  end
end

-- Elastic
M.in_elastic = function(t)
  if t == 0 then return 0 end
  if t == 1 then return 1 end
  return -math.pow(2, 10 * (t - 1)) * math.sin((t - 1.1) * 5 * math.pi)
end
M.out_elastic = function(t)
  if t == 0 then return 0 end
  if t == 1 then return 1 end
  return math.pow(2, -10 * t) * math.sin((t - 0.1) * 5 * math.pi) + 1
end
M.inout_elastic = function(t)
  if t == 0 then return 0 end
  if t == 1 then return 1 end
  if t < 0.5 then
    return -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * (2 * math.pi) / 4.5)) / 2
  else
    return (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * (2 * math.pi) / 4.5)) / 2 + 1
  end
end

-- Bounce (out_bounce defined first, others added after)
M.out_bounce = function(t)
  local n1 = 7.5625
  local d1 = 2.75
  if t < 1 / d1 then
    return n1 * t * t
  elseif t < 2 / d1 then
    return n1 * (t - 1.5 / d1) * (t - 1.5 / d1) + 0.75
  elseif t < 2.5 / d1 then
    return n1 * (t - 2.25 / d1) * (t - 2.25 / d1) + 0.9375
  else
    return n1 * (t - 2.625 / d1) * (t - 2.625 / d1) + 0.984375
  end
end

-- Add bounce functions that depend on out_bounce
M.in_bounce = function(t)
  return 1 - M.out_bounce(1 - t)
end

M.inout_bounce = function(t)
  if t < 0.5 then
    return (1 - M.out_bounce(1 - 2 * t)) / 2
  else
    return (1 + M.out_bounce(2 * t - 1)) / 2
  end
end


return M
