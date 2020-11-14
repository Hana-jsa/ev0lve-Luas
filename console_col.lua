local helper = require("helper_167")

local matsys = helper.find_interface("materialsystem.dll", "VMaterialSystem080")
local engine_client = ffi.cast(ffi.typeof('void***'), utils.find_interface('engine.dll', 'VEngineClient014'))

local first_material = matsys:get_vfunc(86, "int(__thiscall*)(void*)")
local next_material = matsys:get_vfunc(87, "int(__thiscall*)(void*, int)")
local invalid_material = matsys:get_vfunc(88, "int(__thiscall*)(void*)")
local find_material = matsys:get_vfunc(89, "void*(__thiscall*)(void*, int)")

local console_is_visible = ffi.cast(ffi.typeof('bool(__thiscall*)(void*)'), engine_client[0][11])
local console_col = gui.new_colorpicker("console color", "cons_col", color.new(255,255,255,255))
local materials = {'vgui_white','vgui/hud/800corner1', 'vgui/hud/800corner2', 'vgui/hud/800corner3', 'vgui/hud/800corner4'}

function on_paint()
    local clr = console_col:get_value()
    local i = first_material()

    if gui.is_menu_open() then 
        while i ~= invalid_material() do 
            local mat = helper.get_class(find_material(i))
            local get_name = mat:get_vfunc(0, "const char*(__thiscall*)(void*)")
            name = get_name()
        
            for _, mats in ipairs(materials) do
                if ffi.string(name) == mats then
                    local get_group = mat:get_vfunc(1, "const char*(__thiscall*)(void*)")
                    local alpha_modulate = mat:get_vfunc(27, "void(__thiscall*)(void*, float)")
                    local color_modulate = mat:get_vfunc(28, "void(__thiscall*)(void*, float, float, float)")

                    alpha_modulate(clr.a / 255)
                    color_modulate(clr.r / 255, clr.g / 255, clr.b / 255)
                    --print("found "..ffi.string(name).." "..i)
                end
            end
            i = next_material(i)
        end
    end
end