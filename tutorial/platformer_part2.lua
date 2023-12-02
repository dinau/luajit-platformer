--- SDL header
local ffi = require"ffi"
local sdl = require"sdl2_ffi"
require"utils"
----------------------------------------
Debug = true
local r = ffi.new("SDL_Rect",{0,1,2,3})
dprint(r.x,r.y,r.w,r.h)
---------------------------------------------

local Input = {none = 0,left = 1, right = 2, jump = 3 , restart = 4, quit = 5}
local Game = { renderer = {},
               inputs   = {false,false,false, false,false,false} }

-----------
-- newGame
-----------
function newGame(rndrr)
  Game.renderer = rndrr
  return Game
end

--------------------
-- toInput
--------------------
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

---------------
-- Game:render
---------------
function Game:render()
   sdl.RenderClear(self.renderer)
   sdl.RenderPresent(self.renderer)
end

--------
-- main
--------
function main()
  if sdlFailIf(0 == sdl.init(sdl.INIT_VIDEO + sdl.INIT_TIMER + sdl.INIT_EVENTS),
    "SDL2 initialization failed") then
    return -1
  end
  if sdlFailIf(sdl.TRUE == sdl.SetHint("SDL_RENDER_SCALE_QUALITY", "2"),
     "Linear texture filtering could not be enabled") then return -1
  end

  local window = sdl.CreateWindow("Our own 2D platformer",
      sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
      1280, 720, sdl.WINDOW_SHOWN)
  if sdlFailIf(0 ~= window,"Window could not be created") then return -1 end

  local renderer = sdl.CreateRenderer(window,-1,
    sdl.RENDERER_ACCELERATED or sdl.RENDERER_PRESENTVSYNC)
  if sdlFailIf(0 ~= renderer,"Renderer could not be created") then return -1 end

  sdl.SetRenderDrawColor(renderer,110,132,174,255)

  game = newGame(renderer)

  while not game.inputs[Input.quit] do
    game:handleInput()
    game:render()
  end

  sdl.DestroyRenderer(renderer)
  sdl.DestroyWindow(window)
  sdl.quit()
end

--------
-- main
--------
main()
