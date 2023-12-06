local ffi = require"ffi"
--- SDL/image header
local sdl = require"sdl2_ffi"
local img = require"sdl2_image"
----------------------------------------
require"utils"
Debug = true
--local r = ffi.new("SDL_Rect",{0,1,2,3})
--dprint(r.x,r.y,r.w,r.h)
----------------------------------------
local Input  = {none = 0,left = 1, right = 2, jump = 3 , restart = 4, quit = 5}
local Player = {}
local Map    = {}
local Game   = {}
--      { renderer = {},
--       inputs   = {false,false,false, false,false,false},
--       player   = {texture = nil, pos = {x=0,y=0}, vel = {x=0,y=0} },-- Player type
--       map      = {texture = nil,width = 0,height = 0,tiles = {}},
--       camera   = ffi.new("SDL_Point",{0,0})
--     }
local tilesPerRow = 16
local tileSize    = {x = 64, y = 64}

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
--- restartPlayer
------------------
function Player:restartPlayer()
  return
    {x = 170, y = 500},  -- pos
    {x = 0  , y = 0}     -- vel
end

--------------
--- newPlayer   -- Player type
--------------
function Player.newPlayer(texture)
  local ps, vl = Player.restartPlayer()
  return {
    texture = texture,
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
  return {
    renderer    = renderer,
    inputs      = {false,false,false, false,false,false},
    player      = Player.newPlayer(img.LoadTexture(renderer,"player.png")),
    map         = Map.newMap(img.LoadTexture(renderer,"grass.png"),"default.map"),
    camera      = ffi.new("SDL_Point",{0,0}),
    -- method
    handleInput = Game.handleInput,
    render      = Game.render,
  }
end

-----------
-- toInput
-----------
function toInput(key)
  if key == sdl.SCANCODE_A         then
    dprint("LEFT")
    return Input.left
  elseif key == sdl.SCANCODE_D     then
    dprint("RIGHT")
    return Input.right
  elseif key == sdl.SCANCODE_SPACE then
    dprint("JUMP")
    return Input.jump
  elseif key == sdl.SCANCODE_R     then
    dprint("RESTART")
    return Input.restart
  elseif key == sdl.SCANCODE_Q     then
    dprint("QUIT")
    return Input.quit
  else
    dprint("NONE")
    return Input.none
  end
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
      dprint("keydown")
      self.inputs[toInput(event.key.keysym.scancode)] = true
    elseif kind == sdl.KEYUP then
      dprint("keydup")
      self.inputs[toInput(event.key.keysym.scancode)] = false
    end
  end
end

----------------
--- Game:render
----------------
function Game:render()
   sdl.RenderClear(self.renderer)
   local p = { x = self.player.pos.x - self.camera.x
             , y = self.player.pos.y - self.camera.y}
   renderTee(self.renderer, self.player.texture, p)
   renderMap(self.renderer, self.map, self.camera)
   sdl.RenderPresent(self.renderer)
end

--------
---------
--- main
---------
function main()
  if sdlFailIf(0 == sdl.init(sdl.INIT_VIDEO + sdl.INIT_TIMER + sdl.INIT_EVENTS),
    "SDL2 initialization failed") then
    return -1
  end
  if sdlFailIf(sdl.TRUE == sdl.SetHint("SDL_RENDER_SCALE_QUALITY", "2"),
     "Linear texture filtering could not be enabled") then return -1
  end

  local imgFlags = img.INIT_PNG
  sdlFailIf(0 ~= img.Init(imgFlags), "SDL2 Image initialization failed")

  local window = sdl.CreateWindow("Our own 2D platformer written in Luajit",
      sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
      1280, 720, sdl.WINDOW_SHOWN)
  if sdlFailIf(0 ~= window,"Window could not be created") then return -1 end

  local renderer = sdl.CreateRenderer(window,-1,
    sdl.RENDERER_ACCELERATED or sdl.RENDERER_PRESENTVSYNC)
  if sdlFailIf(0 ~= renderer,"Renderer could not be created") then return -1 end

  sdl.SetRenderDrawColor(renderer,110,132,174,255)

  local game = Game.newGame(renderer)

  --------------
  --- Main loop
  --------------
  -- Game loop, draws each frame
  while not game.inputs[Input.quit] do
    game:handleInput()
    game:render()
  end

  --------------
  --- End procs
  --------------
  sdl.DestroyRenderer(renderer)
  sdl.DestroyWindow(window)
  img.quit()
  sdl.quit()
end

---------
--- main
---------
main()
