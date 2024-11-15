local ffi = require"ffi"
--- SDL/image header
local sdl = require"sdl2_ffi"
local utils = require"utils"
Debug = true
--local r = ffi.new("SDL_Rect",{0,1,2,3})
--utils.dprint(r.x,r.y,r.w,r.h)
----------------------------------------
local Input  = {none = 0,left = 1, right = 2, jump = 3 , restart = 4, quit = 5}
local Game   = {}
--      { renderer = {},
--       inputs   = {false,false,false, false,false,false},
--      }

local windowSize = {x = 1280, y = 720}
------------
--- newGame   -- Game type
------------
function Game.newGame(renderer)
  return {
    renderer    = renderer,
    inputs      = {false,false,false, false,false,false},
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

  local srcName = string.sub(arg[0],1,-5)
  local window = sdl.CreateWindow(string.format("%s:  [ %s ]","Our own 2D platformer written in LuaJIT",srcName),
      sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
      windowSize.x, windowSize.y, sdl.WINDOW_SHOWN)
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
  sdl.quit()
end

---------
--- main
---------
main()
