local menu_color = gui.get_colorpicker('misc', 'menu_color')

-- functions and stuff
local function cutname(name)
    changed = false
    ::continue:: 

    local text_w, text_h = renderer.get_text_size(name, fonts.default)
    if text_w > 165 then
        name = name:sub(1, name:len() - 1)
        local text_w, text_h = renderer.get_text_size(name, fonts.default)
        changed = true
        goto continue
    end

    if changed then
        name = name .. "..."
    end

    return name -- return the new name thats partially cut if too long *snip snip*
end
-- no more functions

-- globally scoped variables 

local menu_color = gui.get_colorpicker('misc', 'menu_color')
local specs = {}    
local _y = 0 

-- no more

local spec_drg = gui.new_draggable(200, 200, color.new(29, 29, 29, 200), false)
local spec_drw = gui.new_drawable()
spec_drw:attach(spec_drg)

function spec_drw:update()
  self.size_x = 200
  self.size_y = 35

  specs = { } -- creating our spectator array 

  local me = engine_client.get_local_player()
  local me_ent = entity_list.get_entity(me)


  for i, ent in ipairs(entity_list.get_all('CCSPlayer')) do
      if ent:index() ~= me then
          if ent:get_prop_int('m_iHealth') <= 0 then
              local spec = entity_list.get_entity_from_handle(ent:get_prop_int('m_hObserverTarget'))
              if spec:index() > 0 and spec:index() == me and ent:is_dormant() == false then 
                  specs[#specs+1] = ent:get_player_info().name 
              end
          end
      end
  end

  -- this could just be in the above loop but for how i test (bot matches) that wouldn't work since i was manaually pushing entries to the array
  for j = 0, #specs do 
    self.size_y = self.size_y + 20
  end
end

function spec_drw:paint(x, y)
	local menu_color = menu_color:get_value()
    
    renderer.rect_filled (x + 1, y + 1, x + 199, y + 38, color.new(32, 32, 32))
    renderer.line(x + 1, y + 38, x + 199, y + 38, color.new(21, 21, 21))
    renderer.line(x + 1, y + 37, x + 199, y + 37,  color.new(40, 40, 40))
    renderer.logo (x + 100, y + 19, menu_color)

    if #specs > 0 then 
        _y = y + 16 -- our y to render text is increased here 

        for i, watcher in ipairs(specs) do
            if watcher ~= nil then
                watcher = cutname(watcher)
                renderer.text(x + 12, _y + 35, color.new(220, 220, 220), tostring(watcher), fonts.default)
                _y = _y + 20
            end
        end
    end
end

function on_paint()
    local me = entity_list[engine_client.get_local_player()]
    if not me:index() then return end
    if not engine_client.is_ingame() then return end


    spec_drg:draw()
end