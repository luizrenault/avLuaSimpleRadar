dofile(LockOn_Options.script_path		.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/rdr_api.lua")
dofile(LockOn_Options.script_path.."Systems/avionics_api.lua")

local update_time_step = 0.1
make_default_activity(update_time_step) -- enables call to update
sensor_data = get_base_data()

render_debug_info = false
link_to_target_responder = true
local max_contacts = 500

perfomance =
{
	tracking_azimuth			= {math.rad(-60.0), math.rad(60.0)},
	roll_compensation_limits	= {math.rad(-180.0), math.rad(180.0)},
	pitch_compensation_limits	= {math.rad(-45.0), math.rad(45.0)},
	scan_volume_azimuth			= math.rad(120),
	scan_beam					= math.rad(8),
	
	max_available_distance		= 160 * 1852,

	ground_clutter = 
	{
		sea 	     = {0.5, 0.5, 0.5},
		land 	     = {0.5, 0.5, 0.5},
		artificial   = {0.5, 0.5, 0.5},
		max_distance = 11110.0,
		rays_density = 0.15,
	}
}

need_to_be_closed = false -- lua_state  will be closed in post_initialize()

power_bus_handle = "RDR_ACTIVE"
dev 	    	= GetSelf()

local RDR = {
	ACTIVE = get_param_handle("RDR_ACTIVE"),
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
    VERT = get_param_handle("RDR_VERT"),
    HORIZ = get_param_handle("RDR_HORIZ"),
}


local rdr ={
    stt_az_last = 0,
    stt_el_last = 0,
    stt_range_last = 0,
    stt_time_last = 0,
    stt_count_last = 0,
	stt_pos_x_last = 0,
	stt_pos_y_last = 0,
	stt_pos_z_last = 0,
	boresight_contact_azimuth = 0,
	boresight_contact_range = 0,
	boresight_contact_time = 0,
	avionics_mode_last = 0,
}

RADAR.HIT_HIST:set(1)
RADAR.NORM_RANGE:set(perfomance.max_available_distance)
RADAR.NORM_AZIMUTH:set(perfomance.scan_volume_azimuth)
RADAR.SCAN_ZONE_ORIGIN_ELEVATION:set(math.rad(-2))

local iCommandPlane_LockOn_start	                = 509
local iCommandPlane_LockOn_finish	                = 510
local iCommandPlaneRadarOnOff	                    = 86
local iCommandPlaneRadarLeft	                    = 88
local iCommandPlaneRadarRight	                    = 89
local iCommandPlaneRadarUp	                        = 90
local iCommandPlaneRadarDown	                    = 91
local iCommandPlaneRadarCenter	                    = 92
local iCommandPlaneRadarUpRight	                	= 231
local iCommandPlaneRadarDownRight	                = 232
local iCommandPlaneRadarDownLeft	                = 233
local iCommandPlaneRadarUpLeft	                    = 234
local iCommandPlaneRadarStop	                    = 235
local iCommandPlaneRadarChangeMode	                = 285
local iCommandPlaneChangeRadarPRF					= 394
local iCommandPlaneRadarHorizontal	                = 2025
local iCommandPlaneRadarVertical	                = 2026
local iCommandPlaneRadarHorizontalAbs	            = 2027
local iCommandPlaneRadarVerticalAbs	            	= 2028
local iCommandPlaneSelecterHorizontal				= 2031
local iCommandPlaneSelecterVertical					= 2032
local iCommandPlaneSelecterHorizontalAbs			= 2033
local iCommandPlaneSelecterVerticalAbs				= 2034

local iCommandSelecterLeft							= 139
local iCommandSelecterRight							= 140
local iCommandSelecterUp							= 141
local iCommandSelecterDown							= 142

dev:listen_command(100)
		
dev:listen_command(iCommandSelecterLeft)		
dev:listen_command(iCommandSelecterRight)		
dev:listen_command(iCommandSelecterUp)			
dev:listen_command(iCommandSelecterDown)		

dev:listen_command(iCommandPlaneChangeRadarPRF)	
dev:listen_command(iCommandPlaneRadarChangeMode)

dev:listen_command(iCommandPlaneRadarOnOff)
dev:listen_command(iCommandPlaneRadarLeft)
dev:listen_command(iCommandPlaneRadarRight)
dev:listen_command(iCommandPlaneRadarUp)
dev:listen_command(iCommandPlaneRadarDown)
dev:listen_command(iCommandPlaneRadarCenter)
dev:listen_command(iCommandPlaneRadarUpRight)
dev:listen_command(iCommandPlaneRadarDownRight)
dev:listen_command(iCommandPlaneRadarDownLeft)
dev:listen_command(iCommandPlaneRadarUpLeft)
dev:listen_command(iCommandPlaneRadarStop)
dev:listen_command(iCommandPlaneRadarChangeMode)
dev:listen_command(iCommandPlaneRadarHorizontal)
dev:listen_command(iCommandPlaneRadarVertical)
dev:listen_command(iCommandPlaneRadarHorizontalAbs)
dev:listen_command(iCommandPlaneRadarVerticalAbs)

dev:listen_command(apq159_commands.ModeSelector)
dev:listen_command(device_commands.RDR_POWER)

dev:listen_command(apq159_commands.TDCAzimuth)
dev:listen_command(apq159_commands.TDCRange)

dev:listen_command(Keys.StickDesignate)
dev:listen_command(Keys.StickUndesignate)

local tdc_up_down = 0
local tdc_left_right = 0
local elev_min = math.min(perfomance.pitch_compensation_limits[1], perfomance.pitch_compensation_limits[2])
local elev_max = math.max(perfomance.pitch_compensation_limits[1], perfomance.pitch_compensation_limits[2])
local elev_mid = (elev_max + elev_min) / 2
local elev_span = elev_max - elev_min
local elev_step = elev_span * update_time_step /3

function SetCommand(command, value)
	-- print_message_to_user("RDR Cmd: " .. command .. " Val: " .. value)

	if command == apq159_commands.ModeSelector then
		if value == 1 then
			if RDR.POWER:get() == 1 and RDR.OPR:get() == 0 then RDR.OPR:set(1) end
			if RDR.POWER:get() == 0 then RDR.POWER:set(1) RDR.OPR:set(0) end
		elseif value == -1 then
			if RDR.POWER:get() == 1 and RDR.OPR:get() == 1 then RDR.OPR:set(0) end
			if RDR.POWER:get() == 1 and RDR.OPR:get() == 0 then RDR.POWER:set(0) RDR.OPR:set(0) end
		elseif value == 0 then
			RDR.POWER:set(0)
		elseif value == 0.1 then
			RDR.POWER:set(1)
			RDR.OPR:set(0)
		elseif value == 0.2 then
			RDR.POWER:set(1)
			RDR.OPR:set(1)
		end
	elseif command == device_commands.RDR_POWER then
		RDR.POWER:set(value)
	end
	if command == iCommandPlaneRadarUp then
		if value == 1 then dispatch_action(nil, iCommandPlaneRadarDown, 0)
			local elev = RADAR.SCAN_ZONE_ORIGIN_ELEVATION:get() + elev_step
			elev = math.min(elev, perfomance.pitch_compensation_limits[2])
			elev = math.max(elev, perfomance.pitch_compensation_limits[1])
			RADAR.SCAN_ZONE_ORIGIN_ELEVATION:set(elev)
		end
	elseif command == iCommandPlaneRadarDown then
		if value == -1 then dispatch_action(nil, iCommandPlaneRadarUp, 0) 
			local elev = RADAR.SCAN_ZONE_ORIGIN_ELEVATION:get() - elev_step
			elev = math.min(elev, perfomance.pitch_compensation_limits[2])
			elev = math.max(elev, perfomance.pitch_compensation_limits[1])
			RADAR.SCAN_ZONE_ORIGIN_ELEVATION:set(elev)
		end
	elseif command == iCommandPlaneRadarVerticalAbs then
		RADAR.SCAN_ZONE_ORIGIN_ELEVATION:set(value * elev_span / 2 + elev_mid)
	elseif command == iCommandPlaneRadarVertical then
		print_message_to_user("Radar Vertical " .. value)
	end


	if command == iCommandSelecterLeft then 
		if value == 0 then tdc_left_right = 0 else tdc_left_right = math.rad(-60)*update_time_step/3 end
	elseif command == iCommandSelecterRight then 
		if value == 0 then tdc_left_right = 0 else tdc_left_right = math.rad(60)*update_time_step/3 end
	elseif command == iCommandSelecterUp then 
		if value == 0 then tdc_up_down = 0 else tdc_up_down = RDR.RANGE:get()*1852*update_time_step/3 end
	elseif command == iCommandSelecterDown then 
		if value == 0 then tdc_up_down = 0 else tdc_up_down = -RDR.RANGE:get()*1852*update_time_step/3 end
	elseif command == apq159_commands.TDCAzimuth then
		tdc_left_right = math.rad(60)*update_time_step * value
	elseif command == apq159_commands.TDCRange then
		tdc_up_down = RDR.RANGE:get()*1852*update_time_step * value
	elseif command == Keys.StickDesignate then
		if value == 1 then dispatch_action(nil, iCommandPlane_LockOn_start, 1)
		else dispatch_action(nil, iCommandPlane_LockOn_finish, 1) end
	elseif command == Keys.StickUndesignate and RADAR.MODE:get() > 1 then
		RADAR.MODE:set(1)
	end
end

function post_initialize()
		local birth = LockOn_Options.init_conditions.birth_place
		if birth=="GROUND_HOT" or birth=="AIR_HOT" then
			dev:performClickableAction(device_commands.RDR_POWER, 1)
		elseif birth=="GROUND_COLD" then
			dev:performClickableAction(device_commands.RDR_POWER, 0)
		end
end

local last_print = 0
function update()
	local norm_azimuth = RADAR.NORM_AZIMUTH:get()
	local norm_range = RADAR.NORM_RANGE:get()
	local plane_roll = sensor_data.getRoll()

	RADAR.TDC_RANGE:set(math.max(math.min(RADAR.TDC_RANGE:get() + tdc_up_down, norm_range), 0))
	RADAR.TDC_AZIMUTH:set(math.max(math.min(RADAR.TDC_AZIMUTH:get() + tdc_left_right, norm_azimuth/2), -norm_azimuth/2))
	RADAR.TDC_RANGE_CARRET_SIZE:set(norm_range * 0.075)

    RADAR.TDC_AZIMUTH_NORM:set(RADAR.TDC_AZIMUTH:get()  / norm_azimuth)
    RADAR.TDC_RANGE_NORM:set(RADAR.TDC_RANGE:get() / norm_range)

    RADAR.TDC_ALT_UPPER:set( 3.28084 * (sensor_data:getBarometricAltitude() + math.tan(RADAR.SCAN_ZONE_ORIGIN_ELEVATION:get() + RADAR.SCAN_ZONE_VOLUME_ELEVATION:get()/2) * RADAR.TDC_RANGE:get()) / 1000 )
    RADAR.TDC_ALT_LOWER:set( 3.28084 * (sensor_data:getBarometricAltitude() + math.tan(RADAR.SCAN_ZONE_ORIGIN_ELEVATION:get() - RADAR.SCAN_ZONE_VOLUME_ELEVATION:get()/2) * RADAR.TDC_RANGE:get()) / 1000 )

	RADAR.STT_AZIMUTH_NORM:set((RADAR.STT_AZIMUTH:get() * math.cos(plane_roll) + RADAR.STT_ELEVATION:get() * math.sin(plane_roll))  / norm_azimuth)
    RADAR.STT_RANGE_NORM:set(RADAR.STT_RANGE:get() / norm_range)

	local elev_norm = RADAR.SCAN_ZONE_ORIGIN_ELEVATION:get()
	if elev_norm > 0 then 
		elev_norm = elev_norm / math.abs(math.max(perfomance.pitch_compensation_limits[1], perfomance.pitch_compensation_limits[2]))
	else
		elev_norm = elev_norm / math.abs(math.min(perfomance.pitch_compensation_limits[1], perfomance.pitch_compensation_limits[2]))
	end
	RADAR.SCAN_ZONE_ORIGIN_ELEVATION_NORM:set(elev_norm)

	local az_norm = RADAR.SCAN_ZONE_ORIGIN_AZIMUTH:get() / perfomance.scan_volume_azimuth / 2
	RADAR.SCAN_ZONE_ORIGIN_AZIMUTH_NORM:set(az_norm)

	if RDR.POWER:get() == 0 or RDR.OPR:get() == 0 or get_avionics_onground() then 
		RDR.ACTIVE:set(0)
		return
	else
		RDR.ACTIVE:set(1)
	end

	rdr.boresight_contact_range = 10 * 1852
	rdr.boresight_contact_time = 10

	local scan_time = 1.6 * RADAR.HIT_HIST:get()

	for i=1,max_contacts do
		local a = string.format("%02.0f", i)

		local time_h = get_param_handle("RADAR_CONTACT_"..a.."_TIME")
		local opa_h = get_param_handle("RADAR_CONTACT_"..a.."_OPACITY")

		local time_temp = time_h:get()
		if time_temp >= 0 and time_temp < scan_time then
			opa_h:set(1-(time_temp / scan_time))

			local range_h = get_param_handle("RADAR_CONTACT_"..a.."_RANGE")
			local range_norm_h = get_param_handle("RADAR_CONTACT_"..a.."_RANGE_NORM")
			range_norm_h:set(range_h:get() / RADAR.NORM_RANGE:get())
	
			local az_h = get_param_handle("RADAR_CONTACT_"..a.."_AZIMUTH")
			local az_norm_h = get_param_handle("RADAR_CONTACT_"..a.."_AZIMUTH_NORM")
			az_norm_h:set(az_h:get() / RADAR.NORM_AZIMUTH:get())

			local nctr_h = get_param_handle("RADAR_CONTACT_"..a.."_NCTR")

			if get_avionics_master_mode() == AVIONICS_MASTER_MODE_ID.DGFT_S or get_avionics_master_mode() == AVIONICS_MASTER_MODE_ID.DGFT_M then
				if RADAR.MODE:get() ~= 3 then
					if nctr_h:get() ~= "" and range_h:get() < rdr.boresight_contact_range and time_h:get()>0 and time_h:get() < rdr.boresight_contact_time and math.abs(az_h:get()) < perfomance.scan_beam / 2 then
						rdr.boresight_contact_azimuth = az_h:get()
						rdr.boresight_contact_range = range_h:get()
						rdr.boresight_contact_time = time_h:get()
					end
				end
			end
		else 
			opa_h:set(0)
		end

		if time_h:get() <= 0 then break end
	end

	-- STT Data

	rdr.stt_count_last = rdr.stt_count_last + 1
    if RADAR.MODE:get() == 3 and rdr.stt_count_last >= 10 then
        local stt_time = get_absolute_model_time() - rdr.stt_time_last
        if stt_time == 0 then stt_time = 0.00001 end

        local plane_pitch = sensor_data.getPitch()
		local plane_hdg = 2 * math.pi - sensor_data:getHeading()
        local stt_az = RADAR.STT_AZIMUTH:get() * math.cos(plane_roll) + RADAR.STT_ELEVATION:get() * math.sin(plane_roll) 
        local stt_el = (plane_pitch) - RADAR.STT_AZIMUTH:get() * math.sin(plane_roll) + RADAR.STT_ELEVATION:get() * math.cos(plane_roll)
        local stt_range = RADAR.STT_RANGE:get()

		local plane_pos_x, plane_pos_y, plane_pos_z = sensor_data.getSelfCoordinates()
		local stt_pos_y = plane_pos_y + math.tan(plane_pitch + RADAR.STT_ELEVATION:get()) * stt_range
		local stt_dir = plane_hdg + stt_az
		local stt_pos_x = plane_pos_x + stt_range * math.cos(stt_dir)
		local stt_pos_z = plane_pos_z + stt_range * math.sin(stt_dir)
		
        RADAR.STT_ALT:set(3.28084 *(stt_pos_y) / 1000 )

		local stt_vx, stt_vy, stt_vz
		stt_vx = (stt_pos_x - rdr.stt_pos_x_last) / stt_time		-- m/s
		stt_vy = (stt_pos_y - rdr.stt_pos_y_last) / stt_time		-- m/s
		stt_vz = (stt_pos_z - rdr.stt_pos_z_last) / stt_time		-- m/s

		RADAR.STT_VX:set(stt_vx)
		RADAR.STT_VY:set(stt_vy)
		RADAR.STT_VZ:set(stt_vz)

		local stt_hdg = math.atan2(stt_vz , stt_vx)
		RADAR.STT_HDG:set(stt_hdg)
		RADAR.STT_ANGLE:set(plane_hdg - stt_hdg)

        local stt_v = math.sqrt(stt_vx * stt_vx + stt_vz * stt_vz ) -- m/s
        RADAR.STT_SPD:set( stt_v * 1.94 )
		RADAR.STT_REL_SPD:set(-(stt_range - rdr.stt_range_last)/stt_time) -- m/s

		rdr.stt_pos_x_last = stt_pos_x
		rdr.stt_pos_y_last = stt_pos_y
		rdr.stt_pos_z_last = stt_pos_z
		rdr.stt_az_last = stt_az
        rdr.stt_el_last = stt_el
        rdr.stt_range_last = stt_range
        rdr.stt_time_last = get_absolute_model_time()
        rdr.stt_count_last = 0
    end

	-- Radar boresight mode in dogfight
	if (get_avionics_master_mode() == AVIONICS_MASTER_MODE_ID.DGFT_S or get_avionics_master_mode() == AVIONICS_MASTER_MODE_ID.DGFT_M) and RADAR.MODE:get() ~= 3 and rdr.boresight_contact_time ~= 10 then
		RADAR.TDC_AZIMUTH:set(rdr.boresight_contact_azimuth)
		RADAR.TDC_RANGE:set(rdr.boresight_contact_range)
		-- print_message_to_user(string.format("Target Az/Rng/Time: %2.1f/%2.1f/%2.1f", rdr.boresight_contact_azimuth, rdr.boresight_contact_range, rdr.boresight_contact_time))
		dispatch_action(nil, 509, 1)
	end

	rdr.avionics_mode_last = get_avionics_master_mode()
end
