local color = gui.new_colorpicker('\nAutopeek color', "autopeek_color", color.new(161, 110, 255))
local enable = gui.new_checkbox('Enable autopeek', 'enable_autopeek', false)
--local type = gui.new_combobox('Autopeek type', 'autopeek_type', false, 'Static', 'Dynamic')
local options = gui.new_combobox('Autopeek Additives', 'autopeek_additives', true, 'Freestanding', 'Doubletap', 'Change mindmg.')
local mindmg = gui.new_slider("Autopeek mindmg.", "autopeek_dmg", 0, 0, 100, 1)
local dt_ref = gui.get_checkbox('rage', 'enable_fast_fire')
local yaw_ref = gui.get_combobox('antiaim', 'yaw')
local mindmg_ref = gui.get_slider('rage', 'min_dmg')

local min_dmg_pistol = 0
local min_dmg_hpistol = 0
local min_dmg_awp = 0
local min_dmg_ssg = 0
local min_dmg_auto = 0
local yaw_cache = ""
local start = true
local overrided = false

enable:set_tooltip('Enable the scripts autopeek (bind this to a key)')
--type:set_tooltip('Set type of autopeek')
options:set_tooltip('Things that should be done with autopeek')
mindmg:set_tooltip('mindmg that should be used when autopeeking')

--- peek states
local peek_state = {
    idle = 0,
    peek = 1,
    retreat = 2
}

--- object for storing autopeek values
local autopeek = {
    stage = peek_state.idle,
    position = {
        retreat = vec3.new(0, 0, 0),
        target = null
    },
    peeking = false,
    should_retreat = false
}

--- contains function so i can properly use multidropdowns
local function contains( array, value )
    for i = 1, #array do
        if array[i] == value then
            return true;
        end
    end
    return false;
end

--- stolen stuff from itas mindmg. override 
function get_values()
    gui.set_weapon_group('rage', 1)
    min_dmg_pistol = gui.get_slider('rage', 'min_dmg'):get_value()
    gui.set_weapon_group('rage', 2)
    min_dmg_hpistol = gui.get_slider('rage', 'min_dmg'):get_value()
    gui.set_weapon_group('rage', 4)
    min_dmg_awp = gui.get_slider('rage', 'min_dmg'):get_value()
    gui.set_weapon_group('rage', 5)
    min_dmg_ssg = gui.get_slider('rage', 'min_dmg'):get_value()
    gui.set_weapon_group('rage', 6)
    min_dmg_auto = gui.get_slider('rage', 'min_dmg'):get_value()
    yaw_cache = yaw_ref:get_value()
    start = false
end

function set_values()
    gui.set_weapon_group('rage', 1)
    mindmg_ref:set_value(mindmg:get_value())
    gui.set_weapon_group('rage', 2)
    mindmg_ref:set_value(mindmg:get_value())
    gui.set_weapon_group('rage', 4)
    mindmg_ref:set_value(mindmg:get_value())
    gui.set_weapon_group('rage', 5)
    mindmg_ref:set_value(mindmg:get_value())
    gui.set_weapon_group('rage', 6)
    mindmg_ref:set_value(mindmg:get_value())
    overrided = true
end

function reset_values()
    gui.set_weapon_group('rage', 1)
    mindmg_ref:set_value(min_dmg_pistol)
    gui.set_weapon_group('rage', 2)
    mindmg_ref:set_value(min_dmg_hpistol)
    gui.set_weapon_group('rage', 4)
    mindmg_ref:set_value(min_dmg_awp)
    gui.set_weapon_group('rage', 5)
    mindmg_ref:set_value(min_dmg_ssg)
    gui.set_weapon_group('rage', 6)
    mindmg_ref:set_value(min_dmg_auto)
    yaw_ref:set_value(yaw_cache)
    overrided = false
end
--- stolen stuff from itas mindmg. override 

function deg2rad(deg)
    return deg * math.pi / 180
end

function distance2d(x,y)
    return math.sqrt( ( y.x - x.x )^2 + ( y.y - x.x )^2 )
end

function on_setup_command(cmd)
    --- I'd rather do all this shit in seperate functions but i can't call user_cmd/cmd things in anything else other than directly in here so kinda fucks with everything
    if not enable:get_value() then
        autopeek.stage = peek_state.idle
        autopeek.position.retreat = null;
        autopeek.should_retreat = false;
        if overrided == true then 
            reset_values()
        end
        --- if not enable reset all this shit so that it doesn't fuck with stuff
        return;
    end

    local local_player = engine_client.get_local_player()
    local local_player_ent = entity_list.get_entity(local_player)
    local origin = local_player_ent:get_prop_vec3("m_vecOrigin")

    if not autopeek.position.retreat then
        autopeek.stage = peek_state.peek
        autopeek.position.retreat = origin
    else
        if distance2d(origin, autopeek.position.retreat) > 350 then
            autopeek.stage = peek_state.idle
            autopeek.position.retreat = null
        end
    end
    --- well thats the first stage done registering that we want to use autopeek

    --- this is where additives will be called etc things that should be changed/turned on when we're autopeeking
    local additives = options:get_value()

    if contains(additives, "Freestanding") then
        yaw_ref:set_value("Freestanding")
    end

    if contains(additives, "Doubletap") then
        dt_ref:set_value(true) 
    end

    if contains(additives, "Change mindmg.") then
        set_values()
    end
    --- end of additives would like to do my early stop but i don't have a Trace.Bullet type function so i can't do it to the same affect 

    --- updating peek states here
    if autopeek.stage == peek_state.idle then
        return; 
    end
    --- if we're in peek we should enter this stage
    if autopeek.stage == peek_state.retreat then
        if autopeek.should_retreat then
            local view_angles = cmd.viewangles
            local yaw = deg2rad(view_angles.y)
            local pos = autopeek.position.retreat
        
            local forward = {
                origin.x - pos.x,
                origin.y - pos.y,
                origin.z - pos.z
            }
        
            local calculated_velocity = {
                forward[1] * math.cos(yaw) + forward[2] * math.sin(yaw),
                forward[2] * math.cos(yaw) + forward[1] * math.sin(yaw)
            }
        
            cmd.forwardmove = -calculated_velocity[1] * 20
            cmd.sidemove = calculated_velocity[2] * 20
        
            cmd:set_button(buttons.forward)
        else
            autopeek.stage = peek_state.peek
        end
    end
end

function on_paint()
    local info = engine_client.get_player_info(engine_client.get_local_player())
    if not enable:get_value() and not info and not autopeek.position.retreat then
        return;
    end

    if autopeek.position.retreat ~= nil then 
        local pos = autopeek.position.retreat

        local x,y = renderer.world_to_screen(pos)
        local clr = color:get_value()

        renderer.circle(x, y, 30, clr, 1.0, true)
    end
    
end

-- stole this from panzers script
function on_weapon_fire(ev)
    local info = engine_client.get_player_info(engine_client.get_local_player())
    if not info then
        return
    end

    if info.user_id == ev:get_int('userid') and enable:get_value() then
        autopeek.should_retreat = true;
        autopeek.stage = peek_state.retreat
    end
end

get_values()