local vengine_client = ffi.cast(ffi.typeof('void***'), utils.find_interface('engine.dll', 'VEngineClient014'))
local get_net_channel_info = ffi.cast("void*(__thiscall*)(void*)", vengine_client[0][78])
local is_ingame = ffi.cast("bool(__thiscall*)(void*)", vengine_client[0][26])

-- declare types
local nc_17 = ffi.typeof("int(__thiscall*)(void*, int)")
local nc_18 = ffi.typeof("bool(__thiscall*)(void*, int, int)");
local nc_bool = ffi.typeof("bool(__thiscall*)(void*)");
local nc_float = ffi.typeof("float(__thiscall*)(void*, int)");
-- if i don't do this i just crash

local LC_ALPHA = 1

local ping_color = function(ping_value)
    if ping_value < 40 then return { 255, 255, 255 } end
    if ping_value < 100 then return { 255, 125, 95 } end

    return { 255, 60, 80 }
end

local get_net_channel = function(INetChannelInfo)
    if INetChannelInfo == nil then
        return
    end

    local seqNr_out = ffi.cast(nc_17, INetChannelInfo[0][17])(INetChannelInfo, 1)

    return {
        seqNr_out = seqNr_out,

        is_loopback = ffi.cast(nc_bool, INetChannelInfo[0][6])(INetChannelInfo),
        is_timing_out = ffi.cast(nc_bool, INetChannelInfo[0][7])(INetChannelInfo),

        latency = {
            crn = function(flow) return ffi.cast(nc_float, INetChannelInfo[0][9])(INetChannelInfo, flow) end,
            average = function(flow) return ffi.cast(nc_float, INetChannelInfo[0][10])(INetChannelInfo, flow) end,
        },

        loss = ffi.cast(nc_float, INetChannelInfo[0][11])(INetChannelInfo, 1),
        choke = ffi.cast(nc_float, INetChannelInfo[0][12])(INetChannelInfo, 1),
        got_bytes = ffi.cast(nc_float, INetChannelInfo[0][13])(INetChannelInfo, 1),
        sent_bytes = ffi.cast(nc_float, INetChannelInfo[0][13])(INetChannelInfo, 0),
        is_valid_packet = ffi.cast(nc_18, INetChannelInfo[0][18])(INetChannelInfo, 1, seqNr_out-1),
    }
end

local get_net_framerate = function(INetChannelInfo)
    if INetChannelInfo == nil then
        return 0, 0
    end

    local server_var = 0
    local server_framerate = 0

    ffi_cast(net_fr_to, INetChannelInfo[0][25])(INetChannelInfo, pflFrameTime, pflFrameTimeStdDeviation, pflFrameStartTimeStdDeviation)

    if pflFrameTime ~= nil and pflFrameTimeStdDeviation ~= nil and pflFrameStartTimeStdDeviation ~= nil then
        if pflFrameTime[0] > 0 then
            server_var = pflFrameStartTimeStdDeviation[0] * 1000
            server_framerate = pflFrameTime[0] * 1000
        end
    end

    return server_framerate, server_var
end

-- paint callback
function on_paint()
         local me = engine_client.get_local_player()
         if not me or not is_ingame(vengine_client) then
            return
         end

         local net_chan_info = ffi.cast("void***", get_net_channel_info(vengine_client))
         local net_chan = get_net_channel(net_chan_info)
         local server_framerate, server_var = get_net_framerate(INetChannelInfo)
         local alpha = math.min(math.floor(math.sin((global_vars.realtime %3) * 4) * 125 + 200), 255)
         local outgoing, incoming = net_chan.latency.crn(0), net_chan.latency.crn(1)

         local x, y = engine_client.get_screen_size()
         x, y = x / 2 + 1, y - 155

         local net_state = 0
         local net_data_text = {
             [0] = 'clock syncing',
             [1] = 'packet choke',
             [2] = 'packet loss',
             [3] = 'lost connection'
         }

        if net_chan.choke > 0.00 then net_state = 1 end
        if net_chan.loss > 0.00 then net_state = 2 end

        if net_chan.is_timing_out then
            net_state = 3
            net_chan.loss = 1
            LC_ALPHA = LC_ALPHA-global_vars.frametime
            LC_ALPHA = LC_ALPHA < 0.05 and 0.05 or LC_ALPHA
        else
            LC_ALPHA = LC_ALPHA+(global_vars.frametime*2)
            LC_ALPHA = LC_ALPHA > 1 and 1 or LC_ALPHA
        end

        local right_text = net_state ~= 0 and
        string.format('%.1f%% (%.1f%%)', net_chan.loss*100, net_chan.choke*100) or
        string.format('%.1fms', server_var/2)

       local ccor_text = net_data_text[net_state]
       local ccor_width = renderer.get_text_size(ccor_text, fonts.default)

       local sp_x = x - ccor_width - 25
       local sp_y = y
       local cn = 1

       renderer.text(sp_x, sp_y, color.new(255, 255, 255, (net_state ~= 0 and 255 or alpha)), ccor_text, fonts.verdana12)
       renderer.text(x + 20, sp_y, color.new(255, 255, 255), string.format('+- %s', right_text), fonts.verdana12)

       local bytes_in_text = string.format('in: %.2fk/s    ', net_chan.got_bytes/1024)
       local bi_width = renderer.get_text_size(bytes_in_text, fonts.verdana12)

       local tickrate = info.game.tickrate
       local lerp_time = 1 * (1000 / tickrate)

       local lerp_color = { 255, 255, 255 }

       if lerp_time/1000 < 2/1 then
            lerp_color = { 255, 125, 9 }
       end

       renderer.text(sp_x, sp_y + 20*cn, color.new(255,255,255, LC_ALPHA*255), bytes_in_text, fonts.verdana12)
       renderer.text(sp_x + bi_width, sp_y + 20*cn, color.new(lerp_color[1], lerp_color[2], lerp_color[3], LC_ALPHA*255), string.format('lerp: %.1fms', lerp_time), fonts.verdana12); cn = cn+1
       renderer.text(sp_x, sp_y + 20*cn, color.new(255,255,255, LC_ALPHA*255), string.format('out: %.2fk/s', net_chan.sent_bytes/1024), fonts.verdana12); cn=cn+1;

       renderer.text(sp_x, sp_y + 20*cn, color.new(255,255,255,LC_ALPHA*255), string.format('sv: %.2f +- %.2fms    var: %.3f ms', server_framerate, server_var, server_var), fonts.verdana12)cn=cn+1

       local outgoing, incoming = net_chan.latency.crn(0), net_chan.latency.crn(1)
       local ping, avg_ping = outgoing*1000, net_chan.latency.average(0)*1000

       local latency_interval = (outgoing+incoming) / global_vars.interval_per_tick
       local additional_latency = math.min(latency_interval*1000, 1) * 100

       local pc = ping_color(avg_ping)

       local nd_text = string.format('delay: %dms (+- %dms)    ', avg_ping, math.abs(avg_ping-ping))
       local nd_width = renderer.get_text_size(nd_text, fonts.verdana12)

       local incoming_latency = math.max(0, (incoming-outgoing)*1000)

       local fl_pre_text = incoming_latency > 1 and string.format(': %dms', incoming_latency) or ''
       local fl_text = string.format('datagram%s', fl_pre_text)
       local fl_color = 255/100*additional_latency

       renderer.text(sp_x, sp_y + 20*cn, color.new(pc[1],pc[2], pc[3], LC_ALPHA*255), nd_text, fonts.verdana12)
end
