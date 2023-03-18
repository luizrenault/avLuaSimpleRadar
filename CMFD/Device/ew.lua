dev:listen_command(ic_commands.Power)

local EW = {
    ON = get_param_handle("RWR_ON"),
    CH_F_MODE = get_param_handle("RWR_CH_F_MODE"),
    SEARCH = get_param_handle("RWR_SEARCH"),
    MODE_PRI = get_param_handle("RWR_MODE_PRI"),
    PROG = get_param_handle("RWR_PROG"),
    STR = get_param_handle("RWR_STR"),
    WARN_CH = get_param_handle("RWR_WARN_CH"),
    WARN_F = get_param_handle("RWR_WARN_F"),
    MAN_PROG = get_param_handle("RWR_MAN_PROG"),
    PFM = get_param_handle("RWR_PFM"),
    SIM = get_param_handle("RWR_SIM"),

}


local rwr ={
    dev = nil,
    on = 0,
    ch_f_mode = 0,
    mode_pri = 0,
    search = 0,
    prog = 1,
    warn_ch = 6,
    warn_f = 6,
    str = 1,
    pfm = 1,
    man_prog = 1,
    sim = 0,
}

    
function update_ew()
    debug_message_to_user("update_ew")
    
    -- Power and CH/F Mode
    rwr.on = rwr.dev and rwr.dev:get_power() and 1 or 0
    if rwr.on == 1 and get_cockpit_draw_argument_value(1790) == 1 then rwr.on = 2 end

    EW.ON:set(rwr.on)
    EW.CH_F_MODE:set(rwr.ch_f_mode)
    EW.PROG:set(rwr.prog)
    EW.SEARCH:set(rwr.search)
    EW.MODE_PRI:set(rwr.mode_pri)
    EW.WARN_CH:set(rwr.warn_ch+0.1)
    EW.WARN_F:set(rwr.warn_f+0.1)
    EW.STR:set(rwr.str)
    EW.PFM:set(rwr.pfm)
    EW.MAN_PROG:set(rwr.man_prog)
    EW.SIM:set(rwr.sim)
    
end

function SetCommandEw(command,value, CMFD)
    debug_message_to_user("CMFD EW: " ..  command .. "=" .. value)
    if value == 1 and CMFD["SelTop"]:get() == SUB_PAGE_ID.EW then 
        if command == device_commands.CMFD1OSS5 or command == device_commands.CMFD2OSS5 then
            rwr.str = (rwr.str + 1) % 6
            if rwr.str == 0 then rwr.str = 1 end
        elseif command == device_commands.CMFD1OSS6 or command == device_commands.CMFD2OSS6 then
            rwr.pfm = (rwr.pfm + 1) % 6
            if rwr.pfm == 0 then rwr.pfm = 1 end
        elseif command == device_commands.CMFD1OSS7 or command == device_commands.CMFD2OSS7 then
            -- EVENT MARK
        elseif command == device_commands.CMFD1OSS9 or command == device_commands.CMFD2OSS9 then
            if WPN_MASS:get() == WPN_MASS_IDS.SIM then 
                rwr.sim = (rwr.sim + 1) % 2
            end
        elseif command == device_commands.CMFD1OSS10 or command == device_commands.CMFD2OSS10 then
            -- CH/F WARN
            rwr.warn_ch = (rwr.warn_ch + 2) % 30
            if rwr.warn_ch == 0 then rwr.warn_ch = 2 end
            rwr.warn_f = (rwr.warn_f + 2) % 30
            if rwr.warn_f == 0 then rwr.warn_f = 2 end
        elseif command == device_commands.CMFD1OSS11 or command == device_commands.CMFD2OSS11 then
            rwr.man_prog = (rwr.man_prog + 1) % 11
            if rwr.man_prog == 0 then rwr.man_prog = 1 end
        elseif command == device_commands.CMFD1OSS24 or command == device_commands.CMFD2OSS24 then
            rwr.prog = (rwr.prog + 1) % 11
            if rwr.prog == 0 then rwr.prog = 1 end
        elseif command == device_commands.CMFD1OSS25 or command == device_commands.CMFD2OSS25 then
            rwr.ch_f_mode = (rwr.ch_f_mode + 1) % 3
        elseif command == device_commands.CMFD1OSS27 or command == device_commands.CMFD2OSS27 then
            rwr.search = (rwr.search + 1) % 2
        elseif command == device_commands.CMFD1OSS28 or command == device_commands.CMFD2OSS28 then
            rwr.mode_pri = (rwr.mode_pri + 1) % 2
        end

    elseif value == 1 and CMFD["FULL"]:get() == 0 and CMFD["SelLeft"]:get() == SUB_PAGE_ID.EW then
        if command == device_commands.CMFD1OSS23 or command == device_commands.CMFD2OSS23 then
            rwr.mode_pri = (rwr.mode_pri + 1) % 2
        elseif command == device_commands.CMFD1OSS22 or command == device_commands.CMFD2OSS22 then
            rwr.search = (rwr.search + 1) % 2
        elseif command == device_commands.CMFD1OSS21 or command == device_commands.CMFD2OSS21 then
            rwr.ch_f_mode = (rwr.ch_f_mode + 1) % 3
        end 
    elseif value == 1 and CMFD["FULL"]:get() == 0 and CMFD["SelRight"]:get() == SUB_PAGE_ID.EW then 
        if command == device_commands.CMFD1OSS12 or command == device_commands.CMFD2OSS12 then
            rwr.mode_pri = (rwr.mode_pri + 1) % 2
        elseif command == device_commands.CMFD1OSS13 or command == device_commands.CMFD2OSS13 then
            rwr.search = (rwr.search + 1) % 2
        elseif command == device_commands.CMFD1OSS14 or command == device_commands.CMFD2OSS14 then
            rwr.ch_f_mode = (rwr.ch_f_mode + 1) % 3
        end 
    end
end


function post_initialize_ew()
    debug_message_to_user("post_initialize_ew")
    rwr.dev = GetDevice(devices.RWR)

end

register_as_cmfd_item(SUB_PAGE_ID.EW, post_initialize_ew, update_ew, SetCommandEw)