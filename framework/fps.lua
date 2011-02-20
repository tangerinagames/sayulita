--[[
  fps.lua
  v0.1 -- FEB-28-2011

  FPS will add a frame/sec meter to your project
  
  to add it, but the following code in the scene that you'd like to see the FPS displayed
  
      local fps = require("fps")
      local performance = fps.PerformanceOutput.new()
  
      -- for this example I'll put the meter at the TopLeft corner
      performance.group:setReferencePoint(display.TopLeftReferencePoint)
      performance.group.x, performance.group.y = 0,  0
  
  Remember to remove this code when you are done debugging.
	
	NOTE: based on example code posted by Wizem on the Corona Code Exchange 10-21-2010
	
	The FPS displayed is the average of the last 10 frames (set by changing maxSavedFps below).
	The more values you save the more time it will take to calculate.  Play with it to see which
	is best for your app.
]]

local getTime = system.getTimer
local floor   = math.floor
local display = display
local Runtime = Runtime

module(...) -- Avoiding the use of package.seeall to keep the global namespace clean

-- private
local prevTime = 0
local maxSavedFps = 10
local savedFPS = {}
local indexFPS = 1
local framerate, minmaxrate, minmaxlabel, background

local function createLayout()
  local group = display.newGroup()
 
  framerate   = display.newText("0", -2,0, "Helvetica", 20)
  minmaxlabel = display.newText("min            max", -31, 0, "Helvetica", 10)
  minmaxrate  = display.newText("00        00", -28, 10, "Helvetica", 14)
  background  = display.newRect(-35, 0, 78, 30)
  
  framerate:setTextColor(255,255,255)
  background:setFillColor(0,0,0)
  
  group:insert(background)
  group:insert(framerate)
  group:insert(minmaxlabel)
  group:insert(minmaxrate)

  -- this sets the group to be mildly transparent by default.
  group.alpha = 0.6

  -- clear out the savedFPS values
  local i
  for i = 1, maxSavedFps do 
    savedFPS[i] = 0
  end
  return group
end
 
local minFPS = 99
local maxFPS = 0
local avgFPS = 0

local function addFPS(fps)
  savedFPS[indexFPS] = fps
  indexFPS = indexFPS + 1
  if (indexFPS > maxSavedFps) then indexFPS = 1 end
  local i
  local sum = 0
  minFPS = 99
  maxFPS = 0
  for i = 1, maxSavedFps do
    local sfps = savedFPS[i]
    if (sfps < minFPS) then minFPS = sfps end
    if (sfps > maxFPS) then maxFPS = sfps end
    sum = sum + sfps
  end
  avgFPS = floor(sum / maxSavedFps)
end
 
local function updateFPS()
  local curTime = getTime()
  local dt = curTime - prevTime
  prevTime = curTime
  
  addFPS(floor(1000/dt))

  framerate.text  = avgFPS
  minmaxrate.text = minFPS .. "         " .. maxFPS
end
 
-- only keep one instance of this
local instance = nil
-- public
function getMeter()
  if instance then return instance end
  instance = createLayout(self)
  
  Runtime:addEventListener("enterFrame", updateFPS)
  return instance
end