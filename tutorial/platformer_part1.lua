local ffi = require"ffi"
--- SDL/image header
local sdl = require"sdl2_ffi"
local utils = require"utils"
Debug = true

function main()
  if utils.sdlFailIf(0 == sdl.init(sdl.INIT_VIDEO + sdl.INIT_TIMER + sdl.INIT_EVENTS),
    "SDL2 initialization failed") then os.exit(1) end
  if utils.sdlFailIf(sdl.TRUE == sdl.SetHint("SDL_RENDER_SCALE_QUALITY", "2"),
     "Linear texture filtering could not be enabled") then os.exit(1) end

  local window = sdl.CreateWindow("Our own 2D platformer written in Luajit",
      sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
      1280, 720, sdl.WINDOW_SHOWN)
  if utils.sdlFailIf(0 ~= window,"Window could not be created") then os.exit(1) end

  local renderer = sdl.CreateRenderer(window,-1,
    sdl.RENDERER_ACCELERATED or sdl.RENDERER_PRESENTVSYNC)
  if utils.sdlFailIf(0 ~= renderer,"Renderer could not be created") then os.exit(1) end

  sdl.SetRenderDrawColor(renderer,110,132,174,255)

  local count = 1000

  --------------
  --- Main loop
  --------------
  -- Game loop, draws each frame
  while count > 0 do
    sdl.RenderClear(renderer)
    sdl.RenderPresent(renderer)
    count = count - 1
  end
  print("OK !")

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
