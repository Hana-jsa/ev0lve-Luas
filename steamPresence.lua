local steam_api = require("steam_api_170")
local enable = gui.new_checkbox('Enable Steam presence', "enable_steam", false)
local text = gui.new_textbox("Text to put", "presence_text")
local blank = '\u{3000}'

local function update()
    local presence_text = text:get_value()
    if enable then
        steam_api.ISteamFriends.SetRichPresence("steam_display", "#bcast_teamvsteammap")
        steam_api.ISteamFriends.SetRichPresence("team1", presence_text .. string.rep(blank, (113 - #presence_text)/2 ))
        steam_api.ISteamFriends.SetRichPresence("team2", string.rep(blank, 50))
        steam_api.ISteamFriends.SetRichPresence("map", "de_dust2")
        steam_api.ISteamFriends.SetRichPresence("game:mode", "competitive")
        steam_api.ISteamFriends.SetRichPresence("system:access", "private")
    end

end

local timer = utils.new_timer(
    5000,
    update
)

timer:start()

function on_shutdown()
    steam_api.ISteamFriends.ClearRichPresence()
end
