local main_font = nil
local blinky_stars = nil
local intro_music = nil
local logo = nil
local inst_vortex = nil
local active_level = nil
local current_level = 1
local showing_instructions_3f = false
local ended_3f = false
local util = require("util")
local starfield = require("starfield")
local level = require("level")
local vortext = require("vortex")
local levels = {{planets = {{distance = 300, resources = {0}, size = 2, tile = 1}}, ship = {vx = -1, vy = 0}, vortex = {radius = 40, x = 400, y = 100}}, {planets = {{distance = 400, resources = {0}, size = 3, tile = 1}}, ship = {vx = -0.5, vy = 0.5}, vortex = {radius = 30, x = 300, y = 200}}, {planets = {{distance = 400, resources = {0}, size = 3, tile = 1}, {distance = 300, resources = {0, 10}, size = 2, tile = 3}}, ship = {vx = -0.5, vy = 0.5}, vortex = {radius = 50, x = 300, y = 100}}, {planets = {{distance = 400, resources = {0}, size = 3, tile = 1}, {distance = 250, resources = {50}, size = 2, tile = 3}, {distance = 500, resources = {0}, size = 1, tile = 2}}, ship = {vx = -0.5, vy = 0}, vortex = {radius = 50, x = 100, y = 300}}, {planets = {{distance = 400, resources = {0, 50}, size = 3, tile = 1}, {distance = 500, resources = {25, 75}, size = 2, tile = 3}, {distance = 600, resources = {0}, size = 1, tile = 2}}, ship = {vx = -0.5, vy = 0}, vortex = {radius = 50, x = 600, y = 100}}}
local function move_to_next_level()
  current_level = (current_level + 1)
  if (current_level > 5) then
    ended_3f = true
    return nil
  else
    active_level = level.create(levels[current_level])
    return nil
  end
end
local function replay_level()
  active_level = level.create(levels[current_level])
  return nil
end
local function start_game()
  active_level = level.create(levels[current_level])
  return nil
end
love.load = function()
  love.graphics.setDefaultFilter("nearest", "nearest")
  blinky_stars = starfield.create()
  math.randomseed(os.time())
  level.load(move_to_next_level, replay_level)
  inst_vortex = vortext.create((love.graphics.getWidth() / 2), 130, 40)
  logo = love.graphics.newImage("assets/logo.png")
  intro_music = love.audio.newSource("assets/intro.mp3", "static")
  intro_music:setVolume(0.29999999999999999)
  intro_music:setLooping(true)
  main_font = love.graphics.newImageFont("assets/font.png", (" abcdefghijklmnopqrstuvwxyz" .. "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" .. "123456789.,!?-+/():;%&`'*#=[]\""))
  return nil
end
local function center_text(s, r)
  assert((nil ~= r), ("Missing argument %s on %s:%s"):format("r", "main.fnl", 110))
  assert((nil ~= s), ("Missing argument %s on %s:%s"):format("s", "main.fnl", 110))
  do
    local w = (love.graphics.getWidth() / 2)
    local t = love.graphics.newText(main_font, s)
    local x = math.floor((w - (t:getWidth() / 2)))
    return love.graphics.print(s, x, r)
  end
end
local function main_screen()
  starfield.draw(blinky_stars)
  love.graphics.draw(logo, ((love.graphics.getWidth() - logo:getWidth()) / 2), 100)
  love.graphics.setColor(255, 0, 0, 200)
  return center_text("A mediocre space adventure", 180)
end
local text_render_offset = 600
local intro_text_opacity = 255
local function offsetted_text(s, offset, color)
  assert((nil ~= color), ("Missing argument %s on %s:%s"):format("color", "main.fnl", 130))
  assert((nil ~= offset), ("Missing argument %s on %s:%s"):format("offset", "main.fnl", 130))
  assert((nil ~= s), ("Missing argument %s on %s:%s"):format("s", "main.fnl", 130))
  color[4] = intro_text_opacity
  love.graphics.setColor(unpack(color))
  return love.graphics.print(s, 20, math.floor((text_render_offset + (20 * offset))))
end
local function render_text()
  local s = 0
  offsetted_text("Year: 3880 A.D. GAT, 34.33.090 STANDARD GALACTIC", s, {0, 255, 0})
  offsetted_text("Human reign on this galaxy is coming to an end.", (s + 2), {200, 200, 200})
  offsetted_text("Uncontrolled greed has caused the already faltering galactic economy to collapse.", (s + 4), {200, 200, 200})
  offsetted_text("The planetary systems are on their own.", (s + 5), {200, 200, 200})
  offsetted_text("There's no SPOOKY-DORA plasma ion fuel left to power interplanetary", (s + 7), {200, 200, 200})
  offsetted_text("transport systems.  Lack of food and resources has caused unprecedented", (s + 8), {200, 200, 200})
  offsetted_text("civil unrest across planetary systems.  People are dying, there's", (s + 9), {200, 200, 200})
  offsetted_text("wide-spread looting.", (s + 10), {200, 200, 200})
  offsetted_text("There's no law, no order.", (s + 11), {200, 200, 200})
  offsetted_text("The only way to slow down the eventual demise of these systems is to", (s + 13), {200, 200, 200})
  offsetted_text("get transportation back up.", (s + 14), {200, 200, 200})
  offsetted_text("There's no fuel to power transportation, but there's GRAVITY.", (s + 18), {200, 200, 200})
  love.graphics.setColor(255, 13, 255, 255)
  love.graphics.draw(logo, ((love.graphics.getWidth() - logo:getWidth()) / 2), math.floor((text_render_offset + 600)))
  center_text("An OK space adventure", math.floor((text_render_offset + 680)))
  love.graphics.setColor(255, 255, 255, 255)
  return center_text("Press the SPACE key to continue.", math.floor((text_render_offset + 700)))
end
local function second_screen()
  starfield.draw(blinky_stars)
  return render_text()
end
local playing_intro_music_3f = false
local function second_screen_update(t)
  starfield.update(blinky_stars, t)
  local function _0_()
    if not playing_intro_music_3f then
      intro_music:play()
      playing_intro_music_3f = true
      return nil
    end
  end
  _0_()
  local function _1_()
    if (text_render_offset < -100) then
      local new_op = math.max(0, (intro_text_opacity - (50 * t)))
      intro_text_opacity = new_op
      return nil
    end
  end
  _1_()
  if (text_render_offset > -200) then
    text_render_offset = (text_render_offset - (20 * t))
    return nil
  else
    return nil
  end
end
local function game_screen_update(t)
  assert((nil ~= t), ("Missing argument %s on %s:%s"):format("t", "main.fnl", 185))
  starfield.update(blinky_stars, t)
  return level.update(active_level, t)
end
local function game_screen()
  starfield.draw(blinky_stars)
  love.graphics.setColor(255, 255, 255, 255)
  return level.draw(active_level)
end
local function instructions_screen_update(t)
  assert((nil ~= t), ("Missing argument %s on %s:%s"):format("t", "main.fnl", 194))
  starfield.update(blinky_stars, t)
  return vortext.update(inst_vortex, t)
end
local function instructions_screen()
  starfield.draw(blinky_stars)
  love.graphics.setColor(255, 255, 255, 255)
  center_text("GOAL: Pick up as many planetary resources as possible and reach the", 50)
  vortext.draw(inst_vortex)
  love.graphics.setColor(255, 13, 255, 255)
  center_text("The N.E.O.N. Vortex", 180)
  love.graphics.setColor(128, 255, 128, 255)
  center_text("Planetary resources hover around the planets.", 205)
  love.graphics.setColor(255, 255, 255, 255)
  center_text("          SPACE : Launch Spacecraft               ", 230)
  center_text("              S : Adjust Speed up                 ", 245)
  center_text("          MOUSE : Adjust planet's orbital position", 260)
  center_text("Launch vector and thrust cannot be configured, we try to make", 290)
  center_text("do with whatever propulsion resources we have.", 305)
  center_text("Needless to say, don't run into planets.", 340)
  return center_text("When ready, press the SPACE key.", 380)
end
local function thanks_screen()
  love.graphics.setColor(255, 255, 255, 255)
  center_text("Thanks for playing!", 20)
  center_text("Attributions", 60)
  center_text("----------------------", 75)
  center_text("Planets textures: Rawdanitsu @ OpenGameArt", 95)
  center_text("Explosion: StumpyStrust @ OpenGameArt", 110)
  center_text("Explosion Sound: NenadSimic @ OpenGameArt", 125)
  center_text("Resource Pop: farfadet46 @ OpenGameArt", 140)
  center_text("Gameplay Music: Alone by Sudocolon @ OpenGameArt", 155)
  center_text("Victory Music: Axton Crolly @ OpenGameArt", 170)
  return center_text("Crate Image: Bluerobin2 @ OpenGameArt", 185)
end
love.update = function(t)
  if active_level then
    return game_screen_update(t)
  elseif showing_instructions_3f then
    return instructions_screen_update(t)
  else
    return second_screen_update(t)
  end
end
love.draw = function()
  love.graphics.setFont(main_font)
  if ended_3f then
    return thanks_screen()
  elseif active_level then
    return game_screen()
  elseif showing_instructions_3f then
    return instructions_screen()
  else
    return second_screen()
  end
end
love.keypressed = function(key, unicode)
  print(math.floor(text_render_offset))
  if active_level then
    return level.keypressed(active_level, key, unicode)
  elseif (showing_instructions_3f and (key == "space")) then
    return start_game()
  elseif (not showing_instructions_3f and (key == "space") and (math.floor(text_render_offset) <= -200)) then
    showing_instructions_3f = true
    return intro_music:stop()
  elseif (key == "space") then
    intro_text_opacity = 0
    text_render_offset = -200
    return nil
  end
end
return love.keypressed
