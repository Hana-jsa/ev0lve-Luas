--menu gif

local gif = render.create_texture('ev0lve/scripts/menu.gif');
local enable = gui.checkbox('enableGif', 'scripts.elements_a', 'Enable')
local attached = gui.checkbox('AttachUI', 'scripts.elements_a', 'Attach to the ui')
local always_vis = gui.checkbox('alwaysVis', 'scripts.elements_a', 'Visible outside of ui')

local draggable = {};
local draggable_mt = {
    __index = draggable
}

function draggable:new(x,y,x2,y2,debug)
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
 

    local is_active = input.is_mouse_down(0) and gui.is_menu_open()
    local is_in_bounds, mouse_position = (function(d) local mx, my = input.get_cursor_pos(); return mx >= d.x and my >= d.y and mx <= d.x + d.x2 and my <= d.y + d.y2, {mx,my}end)(self);

    if not is_active then 
        self.active = false
    end

    if (is_active and is_in_bounds) or self.active then 
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
    return self.x, self.y, self.x + self.x2, self.y + self.y2
end

g_w,g_h = render.get_texture_size(gif);

local gif_window = draggable:new(400, -20, g_w, g_h)

function gif_render()
    if not enable:get_value() then
    return end

    local x,y,x2,y2 = gif_window:drag():get_pos();
    
    if attached:get_value() then 
        if always_vis then 
            x = gui.is_menu_open() and gui.get_menu_rect() or gif_window:drag():get_pos();
            y =  (gui.is_menu_open() and select(2, gui.get_menu_rect())) or select(2, gif_window:drag():get_pos());
            x2 = x - g_w;
            y2 = y + g_h
        else if not gui.is_menu_open() then
            return end
        end
    end


    render.set_texture(gif);
    render.set_loop(gif, true);
    render.rect_filled(x, y, x2, y2, render.color('#fff'));
    render.set_texture(nil);
end

function on_paint()
    gif_render();
end
