local js = require("panorama_183")
local enable = gui.new_checkbox('Unlock Inventory In MM', "inventory_unlock", false)

enable:set_callback(function()
    value = enable:get_value()
    if value == true then
        js.eval([[
           LoadoutAPI.IsLoadoutAllowed = function() {
               return true;
           }
        ]])
    else
        js.eval([[
           LoadoutAPI.IsLoadoutAllowed = function() {
               return false;
           }
        ]])
    end
end)

function on_paint()
    if not engine_client.is_ingame() then
        js.eval([[
           LoadoutAPI.IsLoadoutAllowed = function() {
               return true;
           }
        ]])
    end
end
