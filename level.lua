local hud = require("hud")
local ship = require("ship")
local planet = require("planet")
local vortex = require("vortex")
local lume = require("lume")
local util = require("util")
local tracking_info = nil
local bg_music = nil
local victory_music = nil
local level_switcher = nil
local level_replay = nil
local function find_mouse_intersect_planet(planets)
  assert((nil ~= planets), ("Missing argument %s on %s:%s"):format("planets", "level.fnl", 16))
  do
    local x = love.mouse.getX()
    local y = love.mouse.getY()
    local function _0_(p)
      local _1_ = planet.bounds(p)
      local x1 = _1_[1]
      local y1 = _1_[2]
      local x2 = _1_[3]
      local y2 = _1_[4]
      if (((x1 <= x) and (x <= x2)) and ((y1 <= y) and (y <= y2))) then
        return p
      end
    end
    return lume.first(lume.filter(planets, _0_))
  end
end
local function launch_level(level)
  assert((nil ~= level), ("Missing argument %s on %s:%s"):format("level", "level.fnl", 27))
  level.state = "in-flight"
  return nil
end
local function reset_level(level)
  assert((nil ~= level), ("Missing argument %s on %s:%s"):format("level", "level.fnl", 30))
  level.state = "awaiting-launch"
  level.duration = 0
  level.ship = ship.create(level["level-info"].ship.vx, level["level-info"].ship.vy)
  level["resource-score"] = 0
  level["survival-score-offered"] = 0
  for k, p in ipairs(level.planets) do
    planet.reset(p)
  end
  return nil
end
local function trigger_game_over(level)
  assert((nil ~= level), ("Missing argument %s on %s:%s"):format("level", "level.fnl", 40))
  level.state = "crashed"
  return ship["trigger-crash"](level.ship)
end
local function finish_level(level)
  assert((nil ~= level), ("Missing argument %s on %s:%s"):format("level", "level.fnl", 46))
  ship["fall-into-vortex"](level.ship, {level["level-info"].vortex.x, level["level-info"].vortex.y})
  level.state = "complete"
  return nil
end
local function _0_(level_info)
  local planets = {}
  for k, p in ipairs(level_info.planets) do
    table.insert(planets, planet.create(p.size, p.distance, p.resources, p.tile))
  end
  util.pp(planets)
  return {["level-info"] = level_info, ["resource-score"] = 0, ["speed-up"] = 1, ["survival-score-offered"] = 0, duration = 0, planets = planets, ship = ship.create(level_info.ship.vx, level_info.ship.vy), state = "awaiting-launch", vortex = vortex.create(level_info.vortex.x, level_info.vortex.y, level_info.vortex.radius)}
end
local function _1_(level)
  for k, p in ipairs(level.planets) do
    planet.draw(p)
  end
  ship.draw(level.ship)
  vortex.draw(level.vortex)
  return hud.draw(level)
end
local function _2_(level, key, unicode)
  if (key == "s") then
    local new_s = (level["speed-up"] + 1)
    local function _3_()
      if (new_s > 4) then
        return 1
      else
        return new_s
      end
    end
    level["speed-up"] = _3_()
    return nil
  elseif ((key == "space") and (level.state == "awaiting-launch")) then
    return launch_level(level)
  elseif ((key == "space") and (level.state == "in-flight")) then
    return reset_level(level)
  elseif ((key == "space") and (level.state == "in-flight")) then
    return reset_level(level)
  elseif ((key == "space") and (level.state == "crashed")) then
    return reset_level(level)
  elseif ((key == "space") and (level.state == "complete")) then
    return level_switcher()
  elseif ((key == "r") and (level.state == "complete")) then
    return level_replay()
  end
end
local function _3_(switcher, replay)
  planet.load()
  ship.load()
  hud.load()
  level_switcher = switcher
  level_replay = replay
  bg_music = love.audio.newSource("assets/alone.mp3", "static")
  bg_music:setLooping(true)
  victory_music = love.audio.newSource("assets/victory.mp3", "static")
  return victory_music:setVolume(0.29999999999999999)
end
local function _4_(level)
  return reset_level(level)
end
local function _5_(level, tt)
  local function _6_()
    if (not bg_music:isPlaying() and (level.state == "awaiting-launch")) then
      victory_music:stop()
      return bg_music:play()
    end
  end
  _6_()
  local function _7_()
    if (bg_music:isPlaying() and (level.state == "complete")) then
      victory_music:play()
      return bg_music:stop()
    end
  end
  _7_()
  do
    local t = (tt * level["speed-up"])
    local function _8_()
      if (level.state == "in-flight") then
        level["survival-score-offered"] = math.min(10000, (level["survival-score-offered"] + math.floor((tt * 1000))))
        level.duration = (level.duration + tt)
        ship["apply-planetary-forces"](level.ship, level.planets)
        return ship["update-forces"](level.ship, t)
      end
    end
    _8_()
    local function _9_()
      if (level.state == "awaiting-launch") then
        local function _9_()
          if love.mouse.isDown(1) then
            if not tracking_info then
              local p = find_mouse_intersect_planet(level.planets)
              if p then
                print("found planet:", p)
                love.mouse.setGrabbed(true)
                planet["mark-highlight"](p)
                tracking_info = {planet = p, x = love.mouse.getX(), y = love.mouse.getY()}
                return nil
              end
            end
          else
            if tracking_info then
              love.mouse.setGrabbed(false)
              planet["unmark-highlight"](tracking_info.planet)
              tracking_info = nil
              return nil
            end
          end
        end
        _9_()
        if tracking_info then
          local mx = love.mouse.getX()
          local my = love.mouse.getY()
          local dx = (tracking_info.x - mx)
          local dy = (tracking_info.y - my)
          planet["adjust-position"](tracking_info.planet, dx, dy)
          tracking_info["x"] = mx
          tracking_info["y"] = my
          return nil
        end
      end
    end
    _9_()
    for k, p in ipairs(level.planets) do
      planet.update(p, t)
    end
    ship.update(level.ship, t)
    vortex.update(level.vortex, t)
  end
  do
    local vortex_bounds = vortex["center-and-radius"](level.vortex)
    local ship_bounds = ship["center-and-radius"](level.ship)
    local function _8_()
      if (util["sphere-collision"](vortex_bounds, ship_bounds) and (level.state == "in-flight")) then
        return finish_level(level)
      end
    end
    _8_()
  end
  do
    local ship_center_and_radius = ship["center-and-radius"](level.ship)
    local function _8_(p)
      return planet.collide(p, ship_center_and_radius)
    end
    local coll_status = lume.map(level.planets, _8_)
    local function _9_(s)
      return (s == "full-collide")
    end
    local full_collide_3f = lume.first(lume.filter(coll_status, _9_))
    local function _10_(s)
      return (s == "resource-collide")
    end
    local resource_collides = #lume.filter(coll_status, _10_)
    level["resource-score"] = (level["resource-score"] + (50000 * resource_collides))
    if ((level.state == "in-flight") and full_collide_3f) then
      return trigger_game_over(level)
    end
  end
end
return {create = _0_, draw = _1_, keypressed = _2_, load = _3_, reset = _4_, update = _5_}
