local function dump_functions(modules)
    local functions = {}
    for module_name, module in pairs(modules) do
        local funcs = {}
        for k, v in pairs(module) do
            if type(v) == "function" then
                table.insert(funcs, k)
            end
        end
        table.sort(funcs)
        print("Functions for module "..module_name..":")
        for i, name in ipairs(funcs) do
            print(name)
            table.insert(functions, {module=module_name, func=name})
        end
        print("\n")
    end
    return functions
end

local modules = {
    cvar = cvar,
    database = database,
    engine = engine,
    entities = entities,
    event_log = event_log,
    fs = fs,
    gui = gui,
    mat = mat,
    math = math,
    net = net,
    payments = payments,
    render = render,
    utils = utils,
    zip = zip
}

local functions = dump_functions(modules)
database.save("functions.db", functions)
