local ffi = require"ffi"
--- SDL/image header
local sdl = require"sdl2_ffi"
local img = require"sdl2_image"
----------------------------------------
local utils = require"utils"
Debug = true
--local r = ffi.new("SDL_Rect",{0,1,2,3})
--dprint(r.x,r.y,r.w,r.h)
----------------------------------------
local Input  = {none = 0,left = 1, right = 2, jump = 3 , restart = 4, quit = 5}
local Player = {}
local Game   = {}
--      { renderer = {},
--       inputs   = {false,false,false, false,false,false},
--       player   = {texture = nil, pos = {x=0,y=0}, vel = {x=0,y=0} },-- Player type
--       camera   = ffi.new("SDL_Point",{0,0})
--     }

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
--- newGame   -- Game type
------------
function Game.newGame(renderer)
  return {
    renderer    = renderer,
    inputs      = {false,false,false, false,false,false},
    player      = Player.newPlayer(img.LoadTexture(renderer,"player.png")),
    camera      = ffi.new("SDL_Point",{0,0}),
    -- method
    handleInput = Game.handleInput,
    render      = Game.render,
  }
end

-----------
-- toInput
-----------
local toInput = function (key)
  if key == sdl.SCANCODE_A         then
    utils.dprint("LEFT")
    return Input.left
  elseif key == sdl.SCANCODE_H     then
    utils.dprint("LEFT")
    return Input.left
  elseif key == sdl.SCANCODE_D     then
    utils.dprint("RIGHT")
    return Input.right
  elseif key == sdl.SCANCODE_L     then
    utils.dprint("RIGHT")
    return Input.right
  elseif key == sdl.SCANCODE_SPACE then
    utils.dprint("JUMP")
    return Input.jump
  elseif key == sdl.SCANCODE_J     then
    utils.dprint("JUMP")
    return Input.jump
  elseif key == sdl.SCANCODE_K     then
    utils.dprint("JUMP")
    return Input.jump
  elseif key == sdl.SCANCODE_R     then
    utils.dprint("RESTART")
    return Input.restart
  elseif key == sdl.SCANCODE_Q     then
    utils.dprint("QUIT")
    return Input.quit
  else
    utils.dprint("NONE")
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
      utils.dprint("keydown")
      self.inputs[toInput(event.key.keysym.scancode)] = true
    elseif kind == sdl.KEYUP then
      utils.dprint("keydup")
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
   sdl.RenderPresent(self.renderer)
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

  local window = sdl.CreateWindow("Our own 2D platformer written in Luajit",
      sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
      1280, 720, sdl.WINDOW_SHOWN)
  if utils.sdlFailIf(0 ~= window,"Window could not be created") then os.exit(1) end

  local renderer = sdl.CreateRenderer(window,-1,
    sdl.RENDERER_ACCELERATED or sdl.RENDERER_PRESENTVSYNC)
  if utils.sdlFailIf(0 ~= renderer,"Renderer could not be created") then os.exit(1) end

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
