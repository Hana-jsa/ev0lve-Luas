
-- region UI and UI helpers
local enable = gui.new_checkbox("Enable", "bg_enable", false)
local accent_clr = gui.new_colorpicker("\n", "bg_accent_clr", color.new(209, 147, 250))
local items = gui.new_combobox("windows", "bg_windows", true, "Spectators", "Hotkeys", "Watermark" )
local enable_hotkey_editor = gui.new_checkbox("Enable hotkey editor", "bg_hotkey_edit", false)
local hotkey_path_tab = gui.new_textbox("Hotkey path tab", "bg_hotkey_path_tab")
local hotkey_path_cfg = gui.new_textbox("Hotkey path cfg", "bg_hotkey_path_cfg")
local hotkey_label = gui.new_textbox("Hotkey label", "bg_hotkey_lbl")
local hotkey_push = gui.new_checkbox("Add hotkey", "bg_hotkey_push", false)
local hotkey_save = gui.new_checkbox("Save hotkeys to data", "bg_hotkeys_save", false)
local hotkey_load = gui.new_checkbox("Load hotkeys from data", "bg_hotkeys_load", false)

local function is_enabled(tbl, val) 
    for i=1, #tbl do
        if tbl[i] == val then return true end 
    end 

    return false 
end

local function cutname(name)
    changed = false
    ::continue:: 

    local text_w, text_h = renderer.get_text_size(name, fonts.default)
    if text_w > 195 then
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

local draggable = { };
local draggable_mt = {
    __index = draggable
};

function draggable:new(x, y, x2, y2, debug) 
    return setmetatable({
        x = x or 100,
        y = y or 100,
        x2 = x2 or 200,
        y2 = y2 or 200,

        dx = 0,
        dy = 0,
        dx2 = 0,
        dy2 = 0,

        active = false,

        debug = debug or false
    }, draggable_mt);
end

function draggable:drag()
    local is_active = input_handler.is_key_pressed(1);
    local is_in_bounds, mouse_position = (function(d) local mx, my = input_handler.get_cursor_pos(); return mx >= d.x and my >= d.y and mx <= d.x + d.x2 and my <= d.y + d.y2, {mx, my} end)(self);

    if not is_active then
        self.active = false;
    end

    if ( is_active and is_in_bounds ) or self.active then
        self.active = true;

        self.x = mouse_position[1] - self.dx;
        self.y = mouse_position[2] - self.dy;
    else
        self.dx = mouse_position[1] - self.x;
        self.dy = mouse_position[2] - self.y;
    end

    return self;
end

function draggable:get_pos()
    return self.x, self.y, self.x + self.x2, self.y + self.y2;
end
-- end region

-- tables and other globally defined things
renderer.new_font('bg_fontb', 'Segoe UI', 14, 700, fontflags.none)
local screen_x, screen_y = engine_client.get_screen_size()

local bg_renderer = {
    x = screen_x, 
    y = screen_y,
    font = fonts.bg_fontb,
}

local speclist_window = draggable:new(100, 100, 200, 20)
local keylist_window = draggable:new(50, 100, 200, 20)

-- default binds added by hana
local binds = {
    { 'rage', 'enable_fast_fire', "Double-tap" },
    { 'antiaim', 'hide_shot', "Hide shots" },
    { 'antiaim', 'fake_duck', "Fake duck" }
}
-- tables and other globally defined things

function watermark()
    if not enable:get_value() then 
    return end

    if not is_enabled(items:get_value(), "Watermark") then 
    return end

    local fps = info.game.fps
    local rtt = info.game.latency
    local srv_ip = info.game.server_ip
                                                       
    local water_text = string.format("| %sfps | %sms | %s", fps, rtt, srv_ip)
    local w, h = renderer.get_text_size(water_text, bg_renderer.font)
    local w2, h2 = renderer.get_text_size("bubblegum ", bg_renderer.font)
    
    local x = bg_renderer.x - w - w2 - 12 
    local y = 20

    local accent = accent_clr:get_value()

    renderer.rect_filled_fade(x, y, x + w + w2 + 3, y + 20, accent, color.new(0,0,0,0), false)

    renderer.text(x + 1, y + 4, color.new(230, 230, 230, accent.a) , "bubblegum ", bg_renderer.font)
    renderer.text(x + 1 + w2, y + 4, color.new(230, 230, 230, accent.a), water_text, bg_renderer.font)
end

_y = 0
function spectators()
    if not enable:get_value() then 
    return end

    if not is_enabled(items:get_value(), "Spectators") then 
    return end

    local accent = accent_clr:get_value()
    local w_s, h_s = renderer.get_text_size("spectators", bg_renderer.font)
    local x, y, x2, y2 = speclist_window:drag():get_pos()

    renderer.rect_filled_fade(x, y, x2, y + 20, accent, color.new(0,0,0,0), false)
    renderer.text(x + w_s + 15, y + 3, color.new(255,255,255,255) , "spectators", bg_renderer.font)

    specs = { } -- creating our spectator array 

    local me = engine_client.get_local_player()
    local me_ent = entity_list.get_entity(me)
  
    if not engine_client.is_ingame() then return end
  
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
  
    if #specs > 0 then 
        _y = y + 16
        for i, watcher in ipairs(specs) do
            if watcher ~= nil then
                watcher = cutname(watcher)
                renderer.text(x + 5, _y + 7, color.new(220, 220, 220), tostring(watcher), bg_renderer.font)
                _y = _y + 20
            end
        end
    end
end


function keybinds()
    if not enable:get_value() then 
    return end

    if not is_enabled(items:get_value(), "Hotkeys") then 
    return end

    local accent = accent_clr:get_value()
    local w_s, h_s = renderer.get_text_size("keybinds", bg_renderer.font)
    local x, y, x2, y2 = keylist_window:drag():get_pos()

    renderer.rect_filled_fade(x, y, x2, y2, accent, color.new(0,0,0,0), false)
    renderer.text(x + w_s * 1.70, y + 3, color.new(255,255,255,255) , "keybinds", bg_renderer.font)

    __y = y + 16
    for _, element in ipairs(binds) do
        if gui.get_checkbox(element[1], element[2]):get_value() then
            renderer.text(x + 5, __y + 7, color.new(220, 220, 220), element[3], bg_renderer.font)
            __y = __y + 20
        end    
    end
end

function on_paint()
    watermark()
    spectators()
    keybinds()
end

-- region hotkey editor 
hotkey_push:set_callback(function()
    if not enable:get_value() or not enable_hotkey_editor:get_value() then 
    return end

    local hoktey = { hotkey_path_tab:get_value(), hotkey_path_cfg:get_value(), hotkey_label:get_value() } -- make out new bind with the provided path + table and reset every time
    
    -- no infinite loops for me 
    if hotkey_push:get_value() then 
        table.insert(binds, hoktey) -- add it to the table
        print(string.format("Added bind %s to binds", hotkey_label:get_value()))
        hotkey_push:set_value(false) -- set to false cause button !
    end
end)

hotkey_load:set_callback(function()
    if not enable:get_value() or not enable_hotkey_editor:get_value() then 
     return end

    if hotkey_load:get_value() then 
           binds = database.load("binds_data") -- make our binds array be whatever is in the database
           print("Successfully loaded binds from database.ev0")
        hotkey_load:set_value(false)
    end
end)

hotkey_save:set_callback(function()
    if not enable:get_value() or not enable_hotkey_editor:get_value() then 
    return end

    if hotkey_save:get_value() then 
       database.save("binds_data", binds) -- save binds to database
       print("Successfully saved binds to database.ev0")
       hotkey_save:set_value(false)
    end
end)
-- end region