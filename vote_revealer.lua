--[[
    Name: Vote revealer
    Author: Hana
    Description reveals peoples votes in game
--]]

local enable = gui.new_checkbox("Enable vote reveal", "enable_vote_reveal", false)

local find_element = ffi.cast("unsigned long(__thiscall*)(void*, const char*)", utils.find_pattern("client.dll", "55 8B EC 53 8B 5D 08 56 57 8B F9 33 F6 39 77 28"))
local c_hud_chat = find_element(ffi.cast("unsigned long**", ffi.cast("uintptr_t", utils.find_pattern("client.dll", "B9 ? ? ? ? E8 ? ? ? ? 8B 5D 08")) + 1)[0], "CHudChat")
local ffi_chatprint = ffi.cast("void(__cdecl*)(int, int, int, const char*, ...)", ffi.cast("void***", c_hud_chat)[0][27]) or error("Couldn't create ChatPrint");

local function chat_print(text)
    ffi_chatprint(c_hud_chat, 0, 0, string.format("%s ", text))
end

local vote_options = { }

function on_vote_options(ev) 
    for _ = 0, 5 do 
        vote_options[_] = ev:get_string("option"..(_ + 1)) 
    end
end

function on_vote_cast(ev) 
    local option = ev:get_int("vote_option")
    local entid = ev:get_uint64("entityid")

    local entname = engine_client.get_player_info(entid).name
    local string = " "..entname.." has voted "..vote_options[option]

    if enable:get_value() then
        chat_print("\x01 \x01[\x03ev0lve\x01] \x10"..entname.." \x01voted\x01: ".. (vote_options[option] == "No" and "\x02" or "\x04")..vote_options[option].." ")
    end
end