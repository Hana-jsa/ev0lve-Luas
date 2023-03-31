local function dump_functions(obj, name)
    local funcs = {}
    local mt = getmetatable(obj)
    if not mt then
        return
    end
    for k, v in pairs(mt) do
        if type(v) == "function" then
            table.insert(funcs, k)
        end
    end
    table.sort(funcs)
    print("Methods for "..name..":")
    for i, fname in ipairs(funcs) do
        print("\t"..fname)
    end
    print("\n")
 end
 
 local button = gui.button("a", "scripts.elements_a", "Button")
 local checkbox = gui.checkbox("b", "scripts.elements_a", "Check")
 local combobox = gui.combobox("c", "scripts.elements_a", "Combobox",false, "Option 1", "Option 2", "Option 3")
 local color_picker = gui.color_picker("d", "scripts.elements_a", "ColorPicker", render.color('#fff'));
 local label = gui.label("e", "scripts.elements_a", "Label Text")
 local slider = gui.slider("g", "scripts.elements_a", "slider", 0, 100, "%.0f", 10)
 local textbox = gui.textbox("h", "scripts.elements_a")
 

 dump_functions(button, "button")
 dump_functions(checkbox, "checkbox")
 dump_functions(combobox, "combobox")
 dump_functions(color_picker, "color_picker")
 dump_functions(label, "label")
 dump_functions(slider, "slider")
 dump_functions(textbox, "textbox")
