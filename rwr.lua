dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."../../rwr_table.lua")


local dev=GetSelf()


device_timer_dt     = 0.2
MaxThreats          = 16
EmitterLiveTime     = 11
EmitterSoundTime    = 0.5
LaunchSoundDelay    = 15.0

RWR_detection_coeff = 0.85

-- RWR sensors: F-5E has four sensors - 2 on nose and 2 in tail
eyes ={}

eyes[1] =
{
    position      = {x = 6.7,y = -0.1,z =  0.35},
    orientation   = {azimuth  = math.rad(45),elevation = math.rad(0.0)},
    field_of_view = math.rad(120) 
}
eyes[2] =
{
    position      = {x = 6.7,y = -0.1,z = 0.35},
    orientation   = {azimuth  = math.rad(-45),elevation = math.rad(0.0)},
    field_of_view = math.rad(120) 
}
eyes[3] =
{
    position      = {x = -5.5,y = 0.15,z =  0.6},
    orientation   = {azimuth  = math.rad(135),elevation = math.rad(0.0)},
    field_of_view = math.rad(120) 
}
eyes[4] =
{
    position      = {x = -5.5,y = 0.15,z =  -0.6},
    orientation   = {azimuth  = math.rad(-135),elevation = math.rad(0.0)},
    field_of_view = math.rad(120) 
}

need_to_be_closed = false -- close lua state after initialization


-- local update_time_step = 0.02
-- make_default_activity(update_time_step) -- enables call to update

RWR = {
    ON = get_param_handle("RWR_ON"),
    BRIGHT = get_param_handle("RWR_BRIGHT"),
}

maxcontacts = MaxThreats
rwr = 	{}
for i = 1,maxcontacts do	
    local si = string.format("%02i",i)
	rwr[i] = 	{
					signal_h		= get_param_handle("RWR_CONTACT_" .. si .. "_SIGNAL"),
					power_h			= get_param_handle("RWR_CONTACT_" .. si .. "_POWER"),
					general_type_h	= get_param_handle("RWR_CONTACT_" .. si .. "_GENERAL_TYPE"),
					unit_type_h	    = get_param_handle("RWR_CONTACT_" .. si .. "_UNIT_TYPE"),
					type_h	        = get_param_handle("RWR_CONTACT_" .. si .. "_TYPE"),
					source_h	    = get_param_handle("RWR_CONTACT_" .. si .. "_SOURCE"),
					new_h	        = get_param_handle("RWR_CONTACT_" .. si .. "_NEW"),
					time_h	        = get_param_handle("RWR_CONTACT_" .. si .. "_TIME"),
				}
    rwr[i].type_h:set("??")
end


local rwr_power	= get_param_handle("RWR_POWER")
rwr_power:set(1)
power_bus_handle = "RWR_POWER"

rwr_threat_table = {}

function update()
    local time_temp = get_absolute_model_time()
    local rwr_threat_table_i = {}

    local max_signal = 0
    for i = 1,MaxThreats do
        local rwr_code = rwr_type_table[tostring(rwr[i].unit_type_h:get())]
        if rwr_code ~= nil and rwr_code ~= 0 then
            rwr[i].type_h:set("a".. tostring(rwr_code) .. "a")
        else 
            rwr[i].type_h:set("??")
            if rwr[i].unit_type_h:get() ~= 0 then
                print_message_to_user("Adicione ao rwr_db.lua: " .. rwr[i].unit_type_h:get())
            end
        end
        local new_threat_delay = 2
        local old_threat_delay = 2

        local signal_temp = rwr[i].signal_h:get()
        local signal_time_temp = rwr[i].time_h:get()
        local source_temp = string.format("%08x", rwr[i].source_h:get())
        

        if signal_temp > 0 then
            rwr_threat_table_i[source_temp] = time_temp
        end
        if signal_temp > 0 and not rwr_threat_table[source_temp]  then
            rwr_threat_table[source_temp] = time_temp
            rwrscan:play_once()
        end

        if signal_temp > max_signal then max_signal = signal_temp end

        if rwr_threat_table[source_temp] and (rwr_threat_table[source_temp] + new_threat_delay) > time_temp then
            rwr[i].new_h:set(1)
        else
            rwr[i].new_h:set(0)
        end
    end	

    for k,v in pairs(rwr_threat_table) do 
        if not rwr_threat_table_i[k] then rwr_threat_table[k] = nil end
    end

    if max_signal == 0 or max_signal == 1 then
        if rwrlaunch:is_playing() then rwrlaunch:stop() end
        if rwrtrack:is_playing() then rwrtrack:stop() end
    elseif max_signal == 2 then
        if rwrlaunch:is_playing() then rwrlaunch:stop() end
        if not rwrtrack:is_playing() then rwrtrack:play_continue() end
    elseif max_signal == 3 then
        if not rwrlaunch:is_playing() then rwrlaunch:play_continue() end
        if rwrtrack:is_playing() then rwrtrack:stop() end
    end

end

function post_initialize()
    sndhost = create_sound_host("COCKPIT_ARMS","HEADPHONES",0,0,0)
    rwrscan = sndhost:create_sound("Aircrafts/Cockpits/RWR/Scan")
    rwrtrack = sndhost:create_sound("Aircrafts/Cockpits/RWR/Track")
    rwrlaunch = sndhost:create_sound("Aircrafts/Cockpits/RWR/Launch")
    dev:performClickableAction(device_commands.RWR, 0)
    dev:performClickableAction(device_commands.RWR_VOLUME, 0.5)

end

function SetCommand(command,value)
    -- print_message_to_user("rwr: " .. tostring(command) .. "=" .. value)
    if command == device_commands.RWR and value >= 0 then
        dev:set_power(true)
    elseif command == device_commands.RWR and value < 0 then
        dev:set_power(false)
    elseif command == device_commands.RWR_VOLUME then
        value = value /10
        sndhost:update(nil, value, nil)
        rwrscan:update(nil, value, nil)
        rwrtrack:update(nil, value, nil)
        rwrlaunch:update(nil, value, nil)
    end

end
