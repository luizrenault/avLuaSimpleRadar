dofile(LockOn_Options.script_path.."Systems/rdr_api.lua")


local RDR = {
    POWER = get_param_handle("RDR_POWER"),
    MODE = get_param_handle("RDR_MODE"),
    OPR = get_param_handle("RDR_OPR"),
    CNTL = get_param_handle("RDR_CNTL"),
    INTC = get_param_handle("RDR_INTC"),
    HIS = get_param_handle("RDR_HIS"),
    WP = get_param_handle("RDR_WP"),
    MTR_AA = get_param_handle("RDR_MTR_AA"),
    MTR_AG = get_param_handle("RDR_MTR_AG"),
    ALT_TRK = get_param_handle("RDR_ALT_TRK"),
    FREQ = get_param_handle("RDR_FREQ"),
    RANGE = get_param_handle("RDR_RANGE"),
    HORIZ_PITCH = get_param_handle("RDR_HORIZ_PITCH"),
    HORIZ_ROLL = get_param_handle("RDR_HORIZ_ROLL"),
    HPT_HDG = get_param_handle("RDR_HPT_HDG"),
    HPT_REL_SPD = get_param_handle("RDR_HPT_REL_SPD"),
    HPT_DIR = get_param_handle("RDR_HPT_DIR"),
    HPT_DIR_LR = get_param_handle("RDR_HPT_DIR_LR"),
    HPT_AVAIL = get_param_handle("RDR_HPT_AVAIL"),
    HPT_TTT_MIN = get_param_handle("RDR_HPT_TTT_MIN"),
    HPT_TTT_SEC = get_param_handle("RDR_HPT_TTT_SEC"),
}

local rdr ={
    power = 1,
    mode = 0,
    opr = 1,
    cntl = 0,
    wp = 1,
    his = 1,
    mtr_aa = 1,
    mtr_ag = 0,
    alt_trk = 1,
    freq = 0,
    ranges = {5, 10, 20, 40, 80, 160},
    range = 5,
    vert = 0,
    horiz = 0,
    intc = 0,

    stt_az_last = 0,
    stt_el_last = 0,
    stt_range_last = 0,
    stt_time_last = 0,
    stt_count_last = 0,
    
    avionics_mode_last = 0,
}

    

function update_rdr()
    rdr.power = RDR.POWER:get()

    RDR.MODE:set(rdr.mode)
    RDR.OPR:set(rdr.opr)
    RDR.CNTL:set(rdr.cntl)
    RDR.INTC:set(rdr.intc)
    RDR.WP:set(rdr.wp)
    RDR.HIS:set(rdr.his)
    RDR.MTR_AA:set(rdr.mtr_aa)
    RDR.MTR_AG:set(rdr.mtr_ag)
    RDR.ALT_TRK:set(rdr.alt_trk)
    RDR.FREQ:set(rdr.freq)
    RDR.RANGE:set(rdr.ranges[rdr.range])

    RADAR.NORM_RANGE:set(rdr.ranges[rdr.range] * 1852)

    RDR.HORIZ_PITCH:set(math.min(math.max(sensor_data.getPitch(),math.rad(-45)), math.rad(45)))
    RDR.HORIZ_ROLL:set(sensor_data.getRoll())

    if RADAR.MODE:get() == 3 then
        RDR.HPT_HDG:set(round_to(math.deg(RADAR.STT_HDG:get()),1)%360)
        RDR.HPT_REL_SPD:set(RADAR.STT_REL_SPD:get() * 1.94)
        RDR.HPT_DIR_LR:set(RADAR.STT_AZIMUTH:get() >= 0 and "R" or "L")
        RDR.HPT_DIR:set(math.abs(math.deg(RADAR.STT_AZIMUTH:get())))
        local ttt = RADAR.STT_RANGE:get() / RADAR.STT_REL_SPD:get()
        ttt = math.max(math.min(ttt, 6039),0)
        RDR.HPT_TTT_MIN:set(math.floor(ttt/60))
        RDR.HPT_TTT_SEC:set(math.floor(ttt%60))
        RDR.HPT_AVAIL:set(1)
    else        
        RDR.HPT_AVAIL:set(0)
    end
    local amm = get_avionics_master_mode()
    if (amm == AVIONICS_MASTER_MODE_ID.DGFT_M or amm == AVIONICS_MASTER_MODE_ID.DGFT_S) and rdr.avionics_mode_last ~= amm then rdr.range = 2 end
   
    rdr.avionics_mode_last = amm
end

function SetCommandRdr(command,value, CMFD)
    debug_message_to_user("CMFD RDR: " ..  command .. "=" .. value)
    if value == 1 and CMFD["SelTop"]:get() == SUB_PAGE_ID.RDR and rdr.cntl == 0 then 
        if command == device_commands.CMFD1OSS2 or command == device_commands.CMFD2OSS2 then
            rdr.mode = (rdr.mode + 1) % 2
        elseif command == device_commands.CMFD1OSS5 or command == device_commands.CMFD2OSS5 then
            rdr.opr = (rdr.opr + 1) % 2
        elseif command == device_commands.CMFD1OSS6 or command == device_commands.CMFD2OSS6 then
            rdr.cntl = (rdr.cntl + 1) % 2
        elseif command == device_commands.CMFD1OSS8 or command == device_commands.CMFD2OSS8 then
        elseif command == device_commands.CMFD1OSS9 or command == device_commands.CMFD2OSS9 then
        elseif command == device_commands.CMFD1OSS10 or command == device_commands.CMFD2OSS10 then
            rdr.intc = (rdr.intc + 1) % 3
        elseif command == device_commands.CMFD1OSS24 or command == device_commands.CMFD2OSS24 then
        elseif command == device_commands.CMFD1OSS25 or command == device_commands.CMFD2OSS25 then
        elseif command == device_commands.CMFD1OSS26 or command == device_commands.CMFD2OSS26 then
        elseif command == device_commands.CMFD1OSS27 or command == device_commands.CMFD2OSS27 then
            rdr.range = math.max( 1, rdr.range - 1)
        elseif command == device_commands.CMFD1OSS28 or command == device_commands.CMFD2OSS28 then
            rdr.range = math.min( #rdr.ranges, rdr.range + 1)
        end
    elseif value == 1 and CMFD["SelTop"]:get() == SUB_PAGE_ID.RDR and rdr.cntl == 1 then 
        if command == device_commands.CMFD1OSS2 or command == device_commands.CMFD2OSS2 then
            rdr.mode = (rdr.mode + 1) % 2
        elseif command == device_commands.CMFD1OSS3 or command == device_commands.CMFD2OSS3 then
            rdr.wp = (rdr.wp + 1) % 4
            if rdr.wp == 0 then rdr.wp = 1 end
        elseif command == device_commands.CMFD1OSS4 or command == device_commands.CMFD2OSS4 then
            rdr.his = (rdr.his + 1) % 5
            if rdr.his == 0 then rdr.his = 1 end
            RADAR.HIT_HIST:set(rdr.his)
        elseif command == device_commands.CMFD1OSS5 or command == device_commands.CMFD2OSS5 then
            rdr.opr = (rdr.opr + 1) % 2
        elseif command == device_commands.CMFD1OSS6 or command == device_commands.CMFD2OSS6 then
            rdr.cntl = (rdr.cntl + 1) % 2
        elseif command == device_commands.CMFD1OSS8 or command == device_commands.CMFD2OSS8 then
        elseif command == device_commands.CMFD1OSS9 or command == device_commands.CMFD2OSS9 then
        elseif command == device_commands.CMFD1OSS10 or command == device_commands.CMFD2OSS10 then
        elseif command == device_commands.CMFD1OSS24 or command == device_commands.CMFD2OSS24 then
        elseif command == device_commands.CMFD1OSS25 or command == device_commands.CMFD2OSS25 then
            rdr.freq = (rdr.freq + 1) % 3
        elseif command == device_commands.CMFD1OSS26 or command == device_commands.CMFD2OSS26 then
            rdr.alt_trk = (rdr.alt_trk + 1) % 2
        elseif command == device_commands.CMFD1OSS27 or command == device_commands.CMFD2OSS27 then
            rdr.mtr_ag = (rdr.mtr_ag + 1) % 2
        elseif command == device_commands.CMFD1OSS28 or command == device_commands.CMFD2OSS28 then
            rdr.mtr_aa = (rdr.mtr_aa + 1) % 2
        end
    elseif value == 1 and CMFD["FULL"]:get() == 0 and CMFD["SelLeft"]:get() == SUB_PAGE_ID.RDR then
        if command == device_commands.CMFD1OSS23 or command == device_commands.CMFD2OSS23 then
        elseif command == device_commands.CMFD1OSS22 or command == device_commands.CMFD2OSS22 then
        elseif command == device_commands.CMFD1OSS21 or command == device_commands.CMFD2OSS21 then
        end 
    elseif value == 1 and CMFD["FULL"]:get() == 0 and CMFD["SelRight"]:get() == SUB_PAGE_ID.RDR then 
        if command == device_commands.CMFD1OSS12 or command == device_commands.CMFD2OSS12 then
        elseif command == device_commands.CMFD1OSS13 or command == device_commands.CMFD2OSS13 then
        elseif command == device_commands.CMFD1OSS14 or command == device_commands.CMFD2OSS14 then
        end 
    end
end


function post_initialize_rdr()
    debug_message_to_user("post_initialize_rdr")
    rdr.dev = GetDevice(devices.RDR)
end

register_as_cmfd_item(SUB_PAGE_ID.RDR, post_initialize_rdr, update_rdr, SetCommandRdr)