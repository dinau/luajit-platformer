local ffi = require"ffi"
--- SDL/image header
local sdl = require"sdl2_ffi"
local img = require"sdl2_image"
local ttf = require"sdl2_ttf"
ffi.cdef[[
unsigned long GetTickCount();
]]
----------------------------------------
local utils = require"utils"
Debug = true
--local r = ffi.new("SDL_Rect",{0,1,2,3})
--dprint(r.x,r.y,r.w,r.h)
----------------------------------------
local Input     = {none = 0,left = 1, right = 2, jump = 3 , restart = 4, quit = 5}
local Collision = {x = 0, y = 1, corner = 2}
local Player    = {}
local Map       = {}
local Time      = {}
local Game      = {}
--      { renderer = {},
--       inputs   = {false,false,false, false,false,false},
--       player   = {texture = nil, pos = {x=0,y=0}, vel = {x=0,y=0} },-- Player type
--       map      = {texture = nil,width = 0,height = 0,tiles = {}},
--       camera   = ffi.new("SDL_Point",{0,0})
--     }

local windowSize = {x = 1280, y = 720}
local tilesPerRow = 16
local tileSize    = {x = 64, y = 64}
local playerSize  = {x = 64, y = 64}

local air    =   0
local start  =  78
local finish = 110

--------------
--- renderTee
--------------
function renderTee(renderer,texture,pos)
  local x = pos.x
  local y = pos.y
  local bodyParts = {
    {ffi.new("SDL_Rect",{192,64,64,32}),  ffi.new("SDL_FRect",{x-60,y   ,96,48})
    ,sdl.FLIP_NONE}, -- back feet shadow
    {ffi.new("SDL_Rect",{96 ,0 ,96,96}),  ffi.new("SDL_FRect",{x-48,y-48,96,96})
    ,sdl.FLIP_NONE}, -- body shadow
    {ffi.new("SDL_Rect",{192,64 ,64,32}), ffi.new("SDL_FRect",{x-36,y   ,96,48})
    ,sdl.FLIP_NONE}, -- front feet shadow
    {ffi.new("SDL_Rect",{192,32 ,64,32}), ffi.new("SDL_FRect",{x-60,y   ,96,48})
    ,sdl.FLIP_NONE}, -- back feet
    {ffi.new("SDL_Rect",{0  ,0  ,96,96}), ffi.new("SDL_FRect",{x-48,y-48,96,96})
    ,sdl.FLIP_NONE}, -- body
    {ffi.new("SDL_Rect",{192,32 ,64,32}), ffi.new("SDL_FRect",{x-36,y   ,96,48})
    ,sdl.FLIP_NONE}, -- front feet
    {ffi.new("SDL_Rect",{64 ,96 ,32,32}), ffi.new("SDL_FRect",{x-18,y-21,36,36})
    ,sdl.FLIP_NONE}, -- left eye
    {ffi.new("SDL_Rect",{64 ,96 ,32,32}), ffi.new("SDL_FRect",{x-6,y-21 ,36,36})
    ,sdl.FLIP_HORIZONTAL}, -- right eye
  }
  for i=1,#bodyParts do
    sdl.RenderCopyExF(renderer,texture
                      ,bodyParts[i][1] ,bodyParts[i][2],0.0
                      ,nil ,bodyParts[i][3])
  end
end

--------------
--- renderMap
--------------
function renderMap(renderer,map, camera)
  local clip = ffi.new("SDL_Rect",{0,0 ,tileSize.x ,tileSize.y})
  local dest = ffi.new("SDL_Rect",{0,0 ,tileSize.x ,tileSize.y})

  for i=1,#map.tiles do
    local tileNr = map.tiles[i]
    if tileNr ~= 0 then

      clip.x = (tileNr % tilesPerRow ) * tileSize.x
      clip.y = math.floor(tileNr / tilesPerRow ) * tileSize.y
      dest.x = ((i-1) % map.width) * tileSize.x - camera.x
      dest.y = math.floor((i-1) / map.width) * tileSize.y - camera.y

      sdl.RenderCopy(renderer, map.texture, clip, dest)
    end
  end
end

------------------
--- renderTextSub
------------------
function renderTextSub(renderer, font, text, x, y, outline, color)
  ttf.SetFontOutline(font,outline)
  local surface = ttf.RenderUTF8_Blended(font, text, color)
  if utils.sdlFailIf(nil ~= surface,"Could not render text surface") then os.eixt(1) end
  sdl.SetSurfaceAlphaMod(surface, color.a)
  local source = ffi.new("SDL_Rect",{0, 0, surface.w, surface.h})
  local dest   = ffi.new("SDL_Rect",{x - outline, y - outline, surface.w, surface.h})
  local texture = sdl.CreateTextureFromSurface(renderer,surface)
  if utils.sdlFailIf(nil ~= texture,"Could not create texture from rendered text") then os.eixt(1) end
  sdl.FreeSurface(surface)
  sdl.RenderCopyEx(renderer, texture, source, dest, 0.0, nil, sdl.FLIP_NONE)
  sdl.DestroyTexture(texture)
end

---------------
--- renderText
---------------
function Game:renderText(text, x, y, color)
  local outlineColor = ffi.new("SDL_Color",{0, 0, 0, 0x8f})
  renderTextSub(self.renderer, self.font, text, x, y, 2, outlineColor)
  renderTextSub(self.renderer, self.font, text, x, y, 0, color)
end

------------------
--- restartPlayer
------------------
function Player:restartPlayer()
  return
    {x = 170, y = 500},  -- pos
    {x = 0  , y = 0},    -- vel
    -1, -- begin
    -1  -- finish
end

--------------
--- newTime     -- Time type
--------------
function Time.newTime()
  return {
    begin   =  0,
    finish  = -1,
    best    = -1
  }
end

--------------
--- newPlayer   -- Player type
--------------
function Player.newPlayer(texture)
  local ps, vl, begin, finish = Player.restartPlayer()
  return {
    texture = texture,
    time    = Time.newTime(),
    restartPlayer = Player.restartPlayer,
    pos = ps,
    vel = vl
  }
end

------------
--- newMap     -- : Map type
------------
function Map.newMap(texture,file)
  local result = {tiles = {}, texture = texture, width = 0,height = 0} -- Map type

  for line in io.lines(file) do
    local width = 0
    for i,word in pairs( line:split(" ") ) do
      if word ~= "" then
        local value = tonumber(word)
        if value > 255 then
          print("Invalid value " .. word .. "in map " .. file)
        end
        table.insert(result.tiles, value)
        width = width + 1
      end
    end
    if (result.width > 0) and (result.width ~= width) then
      print("Incompatible line length in map " .. file)
    end
    result.width = width
    result.height = result.height + 1
  end
  return result
end

------------
--- newGame   -- Game type
------------
function Game.newGame(renderer)
  local fontName = "DejaVuSans.ttf"
  local f = ttf.OpenFont(fontName, 28)
  if utils.sdlFailIf(f ~= nil,"Font Load: " .. fontName) then os.exit(1) end
  return {
    renderer    = renderer,
    inputs      = {false,false,false, false,false,false},
    player      = Player.newPlayer(img.LoadTexture(renderer,"player.png")),
    map         = Map.newMap(img.LoadTexture(renderer,"grass.png"),"default.map"),
    camera      = ffi.new("SDL_Point",{0,0}),
    font        = f,
    -- method
    handleInput = Game.handleInput,
    render      = Game.render,
    moveBox     = Game.moveBox,
    physics     = Game.physics,
    moveCamera  = Game.moveCamera,
    logic       = Game.logic,
    renderText  = Game.renderText
  }
end

-----------
-- toInput
-----------
local toInput = function (key)
  if     key == sdl.SCANCODE_A or key == sdl.SCANCODE_H or key == sdl.SCANCODE_LEFT then
    return Input.left
  elseif key == sdl.SCANCODE_D or key == sdl.SCANCODE_L or key == sdl.SCANCODE_RIGHT then
    return Input.right
  elseif key == sdl.SCANCODE_SPACE or key == sdl.SCANCODE_UP  then
    return Input.jump
  elseif key == sdl.SCANCODE_J     then return Input.jump
  elseif key == sdl.SCANCODE_K     then return Input.jump
  elseif key == sdl.SCANCODE_R     then return Input.restart
  elseif key == sdl.SCANCODE_Q     then return Input.quit
  else return Input.none end
end

--------------------
-- Game:handleInput
--------------------
function Game:handleInput()
  local event = ffi.new("SDL_Event")
  while sdl.pollEvent(event) ~= 0 do
    local kind = event.type
    if kind == sdl.QUIT then
      self.inputs[Input.quit] = true
    elseif kind == sdl.KEYDOWN then
      self.inputs[toInput(event.key.keysym.scancode)] = true
    elseif kind == sdl.KEYUP then
      self.inputs[toInput(event.key.keysym.scancode)] = false
    end
  end
end

----------------
--- Game:render
----------------
function Game:render(tick)
  -- Draw over all drawings of the last frame with the default color
  sdl.RenderClear(self.renderer)
  -- Actual drawing here
  local p = { x = self.player.pos.x - self.camera.x
            , y = self.player.pos.y - self.camera.y}
  renderTee(self.renderer, self.player.texture, p)
  renderMap(self.renderer, self.map, self.camera)

  local time = self.player.time
  local white = ffi.new("SDL_Color",{0xff, 0xff, 0xff, 0xff})
  if time.begin >= 0 then
    self:renderText(formatTime(tick - time.begin), 50, 100, white)
  elseif time.finish >= 0 then
    self:renderText("Finished in: " .. formatTime(time.finish), 50, 100, white)
  end
  if time.best >= 0 then
    self:renderText("Best time: " .. formatTime(time.best), 50, 150, white)
  end

  -- Show the result on screen
  sdl.RenderPresent(self.renderer)
end

------------
--- getTile
------------
function getTile(map, x, y)
  local nx = utils.clamp(math.floor(x / tileSize.x), 0, map.width - 1)
  local ny = utils.clamp(math.floor(y / tileSize.y), 0, map.height - 1)
  local pos = math.ceil(ny * map.width + nx)
  return map.tiles[pos+1]
end

---------------
--- getTileSub
---------------
function getTileSub(map, pos)
  getTile(map,math.floor(pos.x), math.floor(pos.y))
end

---------------
--- isSolidSub
---------------
function isSolidSub(map, x, y)
  local val = getTile(map,x,y)
  return (val ~= air) and (val ~= start) and (val ~= finish)
end

------------
--- isSolid
------------
function isSolid(map, point)
  return isSolidSub(map, math.ceil(point.x), math.ceil(point.y))
end

-------------
--- onGround
-------------
function onGround(map, pos, size)
  local sz = { x = size.x * 0.5, y = size.y * 0.5}
  local pt1 = {x = pos.x - sz.x, y = pos.y + sz.y + 1}
  local pt2 = {x = pos.x + sz.x, y = pos.y + sz.y + 1}
  return isSolid(map, pt1) or isSolid(map, pt2)
end

------------
--- testBox
------------
function testBox(map, pos, size)
  local sz =   {x = size.x * 0.5, y = size.y * 0.5}
  return isSolid(map,{x = pos.x - sz.x, y = pos.y - sz.y}) or
         isSolid(map,{x = pos.x + sz.x, y = pos.y - sz.y}) or
         isSolid(map,{x = pos.x - sz.x, y = pos.y + sz.y}) or
         isSolid(map,{x = pos.x + sz.x, y = pos.y + sz.y})
end

----------------
--- vector2dLen
----------------
function vector2dLen(vec)
  return math.sqrt((vec.x * vec.x) + (vec.y * vec.y))
end

-----------------
--- Game:moveBox
-----------------
function Game:moveBox(map, size)
  local  distance = vector2dLen(self.player.vel)
  local  maximum = math.floor(distance)

  if distance < 0 then do return end end

  local fraction = 1.0 / (maximum + 1)
  local result = {}
  for i = 0, maximum do
    local newPos = {}
    newPos.x = self.player.pos.x + (self.player.vel.x * fraction)
    newPos.y = self.player.pos.y + (self.player.vel.y * fraction)

    if testBox(map, newPos, size) then
      local hit = false
      local pt = {x = self.player.pos.x, y = newPos.y}
      if testBox(map, pt, size) then
        table.insert(result,Collision.y)
        newPos.y = self.player.pos.y
        self.player.vel.y = 0
        hit = true
      end

      pt = {x = newPos.x, y = self.player.pos.y}
      if testBox(map, pt, size) then
        table.insert(result,Collision.x)
        newPos.x = self.player.pos.x
        self.player.vel.x = 0
        hit = true
      end

      if not hit then
        table.insert(result,Collision.corner)
        newPos = self.player.pos
        self.player.vel = {x = 0, y = 0}
      end

    end
    self.player.pos.x = newPos.x
    self.player.pos.y = newPos.y
  end -- for end
  return result
end

-----------------
--- Game:physics
-----------------
function Game:physics()
  if self.inputs[Input.restart] then
    self.player.pos, self.player.vel,
    self.player.time.begin, self.player.time.finish = self.player:restartPlayer()
  end

  local ground = onGround(self.map, self.player.pos, playerSize)

  if self.inputs[Input.jump] then
    if ground then
      self.player.vel.y = -21
    end
  end
  local direction = utils.boolToInt(self.inputs[Input.right]) -
                    utils.boolToInt(self.inputs[Input.left])
  -- direction is [0 or 1 or -1]

  self.player.vel.y = self.player.vel.y + 0.75
  if ground then
    self.player.vel.x = 0.5 * self.player.vel.x + 4.0 * direction
  else
    self.player.vel.x = 0.95 * self.player.vel.x + 2.0 * direction
  end
  self.player.vel.x = utils.clamp(self.player.vel.x, -8, 8)

  self:moveBox(self.map, playerSize)
end

---------------
--- moveCamera
---------------
function Game:moveCamera()
  local halfWin = windowSize.x / 2
  if fluidCamera then
    local dist = self.camera.x - self.player.pos.x + halfWin
    self.camera.x = self.camera.x - 0.05 * dist
  elseif innerCamera then
    local leftArea  = self.player.pos.x - halfWin - 100
    local rightArea = self.player.pos.x - halfWin + 100
    self.camera.x = clamp(self.camera.x, leftArea, rightArea)
  else
    self.camera.x = self.player.pos.x - halfWin
  end
end

---------------
--- formatTime
---------------
function formatTime(ticks)
  local mins  = math.floor(math.floor(ticks / 50) / 60)
  local secs  = math.ceil(ticks / 50) % 60
  local cents = math.ceil(ticks % 50) * 2
  return string.format("%02d:%02d:%02d",mins,secs,cents)
end

----------
--- logic
----------
function Game:logic(tick)
  -- template time: untyped = game.player.time
  local tile =  getTileSub(self.map, self.player.pos)
  if tile == start then
    time.begin = tick
  elseif tile == finish then
    if self.player.time.begin >= 0 then
      self.player.time.finish = tick - self.player.time.begin
      self.player.time.begin = -1
      if (self.player.time.best < 0) or
         (self.player.time.finish < self.player.time.best) then
        self.player.time.best = self.player.time.finish
      end
      print("Finished in ", formatTime(self.player.time.finish))
    end
  end
end

---------
--- main
---------
local main = function()
  if utils.sdlFailIf(0 == sdl.init(sdl.INIT_VIDEO + sdl.INIT_TIMER + sdl.INIT_EVENTS),
    "SDL2 initialization failed") then os.exit(1) end
  if utils.sdlFailIf(sdl.TRUE == sdl.SetHint("SDL_RENDER_SCALE_QUALITY", "2"),
     "Linear texture filtering could not be enabled") then os.exit(1) end

  local imgFlags = img.INIT_PNG
  if utils.sdlFailIf(0 ~= img.Init(imgFlags), "SDL2 Image initialization failed") then os.exit(1) end
  if utils.sdlFailIf(0 == ttf.Init(), "SDL2_tff font driver initialization failed") then os.exit(1) end

  local window = sdl.CreateWindow("Our own 2D platformer written in Luajit",
      sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
      windowSize.x, windowSize.y, sdl.WINDOW_SHOWN)
  if utils.sdlFailIf(0 ~= window,"Window could not be created") then os.exit(1) end

  local renderer = sdl.CreateRenderer(window,-1,
    sdl.RENDERER_ACCELERATED or sdl.RENDERER_PRESENTVSYNC)
  if utils.sdlFailIf(0 ~= renderer,"Renderer could not be created") then os.exit(1) end

  sdl.SetRenderDrawColor(renderer,110,132,174,255)

  local game = Game.newGame(renderer)
  local startTime = ffi.C.GetTickCount()
  local lastTick = 0

  --------------
  --- Main loop
  --------------
  -- Game loop, draws each frame
  while not game.inputs[Input.quit] do
    game:handleInput()
    local diff =  math.floor((ffi.C.GetTickCount() - startTime)*50) / 1000
    local newTick = math.ceil( diff )
    for tick = lastTick + 1, newTick do
      game:physics()
      game:moveCamera()
      game:logic(tick)
    end
    lastTick = newTick

    game:render(lastTick)
  end

  --------------
  --- End procs
  --------------
  sdl.DestroyRenderer(renderer)
  sdl.DestroyWindow(window)
  ttf.Quit()
  img.Quit()
  sdl.Quit()
end

---------
--- main
---------
main()
