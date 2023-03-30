--menu gif

local gif = render.create_texture('ev0lve/scripts/menu.gif');
function on_paint()
    local w,h = render.get_texture_size(gif);
    local x1,y1,x2,y2 = gui.get_menu_rect()

    render.set_texture(gif);
    render.set_loop(gif, true)
    render.rect_filled(x1, y1 ,x1 - w, y1 + h, render.color('#fff'));
    render.set_texture(nil);
end