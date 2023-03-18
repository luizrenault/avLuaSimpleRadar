dofile(LockOn_Options.script_path .. "CMFD/CMFD_defs.lua")
dofile(LockOn_Options.script_path .. "Indicator/Indicator_defs.lua")
dofile(LockOn_Options.script_path .. "CMFD/CMFD_pageID_defs.lua")

local page_root = create_page_root()
page_root.element_params = {"CMFD"..CMFDNu.."Format"}
page_root.controllers = {{"parameter_compare_with_number",0,SUB_PAGE_ID.RDR}}

local object

-- RDR OFF
object = addStrokeText(nil, "RDR OFF", CMFD_STRINGDEFS_DEF_X2, "CenterCenter", GetMainCenter(), nil, nil, {"%05.0f"}, CMFD_FONT_R)
object.element_params = {default_element_params, "RDR_POWER"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}

-- RDR BIT
object = addStrokeText(nil, "RDR BIT", CMFD_STRINGDEFS_DEF_X2, "CenterCenter", GetMainCenter(), nil, nil, {"%05.0f"}, CMFD_FONT_Y)
object.element_params = {default_element_params, "RADAR_MODE"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 4}}


-- RDR ON
local RDR_On = addPlaceholder(nil, nil)
RDR_On.element_params = {"RDR_POWER", "RADAR_MODE"}
RDR_On.controllers = {{"parameter_compare_with_number", 0, 1}, {"parameter_compare_with_number", 1, 4, -1}}
default_parent = RDR_On.name

object = addOSSMultipleOptions(2, {"RWS", "TWS"}, "RDR_MODE")
object = addOSSMultipleOptions(5, {"STBY", "OPR"}, "RDR_OPR")
object = addOSSStrokeBox(5,1,nil,nil,nil,nil,4)
object.element_params = {default_element_params, "RDR_OPR"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}

object = addOSSText(6, "CNTL")

local RDR_Base = addPlaceholder()
RDR_Base.element_params = {"RDR_CNTL"}
RDR_Base.controllers = {{"parameter_compare_with_number", 0, 0}}

default_parent = RDR_Base.name

-- Range
object = addOSSMidText(27.5," 60",nil, nil, nil, {"%3.0f"})
object.element_params = {default_element_params, "RDR_RANGE"}
object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}}

object = addOSSMultipleOptions(10, {"A\nL\nL", "R\nE\nA\nR", "O\nF\nF"}, "RDR_INTC")


-- CNTL Page
local RDR_Cntl = addPlaceholder(nil, {0,0}, RDR_On.name)
RDR_Cntl.element_params = {"RDR_CNTL"}
RDR_Cntl.controllers = {{"parameter_compare_with_number", 0, 1}}
default_parent = RDR_Cntl.name

object = addOSSStrokeBox(6, 1, nil, nil, nil, nil, 4)

object = addOSSText(3, "WP")
object = addOSSText(3, "\n0", nil, nil, nil, {"\n%1.0f"})
object.element_params = {default_element_params, "RDR_WP"}
object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}}

object = addOSSText(4, "TGT\nHIS")
object = addOSSText(4, "\n\n0", nil, nil, nil, {"\n\n%1.0f"})
object.element_params = {default_element_params, "RDR_HIS"}
object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}}

object = addOSSMultipleOptions(28, {"MTR\nAA\nLO", "MTR\nAA\nHI"}, "RDR_MTR_AA")
object = addOSSMultipleOptions(27, {"MTR\nAG\nLO", "MTR\nAG\nHI"}, "RDR_MTR_AG")
object = addOSSMultipleOptions(26, {"ALT\nTRK\nOFF", "ALT\nTRK\nON"}, "RDR_ALT_TRK")
object = addOSSMultipleOptions(25, {"FXD", "RND", "ADP"}, "RDR_FREQ")
object = addOSSText(24, "LVL 1\n1,3,4\nA")
object = addOSSArrow(10,1)
object = addOSSMidText(10.5, "SYM\nINT")
object = addOSSArrow(11,0)
object = addOSSText(9, "CHN\n23")
object = addOSSText(8, "BCN\nDLY\n21.1")
object = addOSSText(7, "BCN\nCOD\n11")

------------------------------------------
local Grid_base = addPlaceholder(nil, {0, GetMainCenter()[2]-0.025}, RDR_On.name)
default_parent = Grid_base.name
save_default_material = default_material
default_material = CMFD_MATERIAL_CYAN

local grid_w = 1.7
local grid_h = 1.45

-- Left Scale
local function addLeftScale(pos, size, small_tick_size, large_tick_size, carret_size)
    local LeftScale_base = addPlaceholder(nil, pos)
    local object
    object = addStrokeLine(nil, large_tick_size, {0,0}, 90, LeftScale_base.name)
    for i=1, 3 do
        object = addStrokeLine(nil, small_tick_size, {0,size / 4 / 3 * i}, 90, LeftScale_base.name)
        object = addStrokeLine(nil, small_tick_size, {0,-size / 4 / 3 * i}, 90, LeftScale_base.name)
    end
    object = addPlaceholder(nil, nil, LeftScale_base.name)
    object.element_params = {"SCAN_ZONE_ORIGIN_ELEVATION_NORM"}
    object.controllers = {{"move_up_down_using_parameter", 0, size/4 * GetScale()}}
    object = addStrokeLine(nil, large_tick_size/2, {0,0}, 90, object.name)
    object = addStrokeLine(nil, large_tick_size/2, {0,-large_tick_size/4}, 0, object.parent_element)
    return LeftScale_base
end
object = addLeftScale({-0.8, 0}, grid_h, 0.02, 0.06)

-- Top Bottom Scale
local function addBottomScale(pos, size, small_tick_size, large_tick_size, carret_size)
    local Scale_base = addPlaceholder(nil, pos)
    local object
    object = addStrokeLine(nil, large_tick_size, {0, -grid_h/2}, 0, Scale_base.name)
    object = addStrokeLine(nil, large_tick_size, {0, grid_h/2}, 180, Scale_base.name)
    for i=1, 2 do
        object = addStrokeLine(nil, small_tick_size, {size / 4 / 2 * i, -grid_h/2}, 0, Scale_base.name)
        object = addStrokeLine(nil, small_tick_size, {-size / 4 / 2 * i, -grid_h/2}, 0, Scale_base.name)

        object = addStrokeLine(nil, small_tick_size, {size / 4 / 2 * i, grid_h/2}, 180, Scale_base.name)
        object = addStrokeLine(nil, small_tick_size, {-size / 4 / 2 * i, grid_h/2}, 180, Scale_base.name)
    end
    object = addPlaceholder(nil, {0, -grid_h/2 + large_tick_size/4}, Scale_base.name)
    object.element_params = {"SCAN_ZONE_ORIGIN_AZIMUTH_NORM"}
    object.controllers = {{"move_left_right_using_parameter", 0, size/4 * GetScale()}}
    object = addStrokeLine(nil, large_tick_size/2, {0,0}, 0, object.name)
    object = addStrokeLine(nil, large_tick_size/2, {-large_tick_size/4, large_tick_size/2}, -90, object.parent_element)
    return Scale_base
end
object = addBottomScale({0, 0 }, grid_w, 0.02, 0.06)

default_material = CMFD_MATERIAL_BLUE

-- Horizon
local function addHorizon(pos, size, tick_size, gap_size)
    local Horizon_base = addPlaceholder(nil, pos)
    Horizon_base.element_params = {"RDR_HORIZ_PITCH", "RDR_HORIZ_ROLL"}
    Horizon_base.controllers = {{"move_up_down_using_parameter", 0, -grid_h / math.rad(45) * GetScale() / 2 }, {"rotate_using_parameter", 1, 1}}

    local object 
    object = addStrokeLine(nil, (size-gap_size)/2, {-gap_size/2,0}, 90, Horizon_base.name)
    object = addStrokeLine(nil, (size-gap_size)/2, {gap_size/2,0}, -90, Horizon_base.name)
    object = addStrokeLine(nil, tick_size, {-size/2,0}, 180, Horizon_base.name)
    object = addStrokeLine(nil, tick_size, {size/2,0}, 180, Horizon_base.name)
    return Horizon_base
end
object = addHorizon({0,0}, 1, 0.03, 0.2)


-- Flight Level
object = addStrokeText(nil, "20", CMFD_STRINGDEFS_DEF_X08, "CenterBottom", {0.35, -0.75 + 0.06}, nil, nil, {"%02.0f"})
object.element_params = {default_element_params, "HUD_ALT_K"}
object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}}

-- Heading
object = addStrokeText(nil, " 130`", CMFD_STRINGDEFS_DEF_X08, "CenterBottom", {0, -0.75 + 0.06}, nil, nil, {"% 03.0f`"})
object.element_params = {default_element_params, "HUD_HDG"}
object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}}

object = addStrokeText(nil, "300", CMFD_STRINGDEFS_DEF_X08, "CenterBottom", {-0.35, -0.75 + 0.06}, nil, nil, {"%03.0f"})
object.element_params = {default_element_params, "HUD_IAS"}
object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}}

default_material = save_default_material


-------------------------------
-- Hits
local hit_w = 0.02
local hit_h = 0.02
local lr_scale = grid_w * GetScale() --/ math.rad(120) 
local ud_scale = grid_h * GetScale() --/ 20 / 1852

for i=1,140 do
    local Hit_base = addPlaceholder(nil, {0, -grid_h/2})
    local a = string.format("%02.0f", i)
    Hit_base.element_params = {
        "RADAR_CONTACT_"..a.."_AZIMUTH_NORM",
        "RADAR_CONTACT_"..a.."_RANGE_NORM",
        "RADAR_CONTACT_"..a.."_TIME",
    }
    Hit_base.controllers = {
        {"move_left_right_using_parameter", 0, lr_scale},
        {"move_up_down_using_parameter", 1, ud_scale},
        {"parameter_compare_with_number", 2, 0, 1}
        -- {"parameter_in_range", 2, 0, 1}
    }
    local object
    object = addFillBox(nil, hit_w, hit_h, "CenterCenter", {0,0}, Hit_base.name, nil, CMFD_MATERIAL_WHITE)
    object.element_params = {default_element_params, "RADAR_CONTACT_"..a.."_OPACITY",}
    object.controllers = {default_controllers[1], {"opacity_using_parameter", 1}}
end

-- Cursor
function addRadarCursor(rel_size)
    local size_w = rel_size * grid_w
    local size_h = rel_size * grid_h
    local base = addPlaceholder(nil, {0, -grid_h/2})
    base.element_params = {
        "RADAR_TDC_AZIMUTH_NORM",
        "RADAR_TDC_RANGE_NORM",
    }
    base.controllers = {
        {"move_left_right_using_parameter", 0, lr_scale},
        {"move_up_down_using_parameter", 1, ud_scale},
    }
    local object
    object = addStrokeLine(nil, size_h, {size_w/2, -size_h/2}, 0, base.name, nil, nil, nil, nil, CMFD_MATERIAL_WHITE)
    object = addStrokeLine(nil, size_h, {-size_w/2, -size_h/2}, 0, base.name, nil, nil, nil, nil, CMFD_MATERIAL_WHITE)
    object = addStrokeText(nil, "HA", CMFD_STRINGDEFS_DEF_X06, "LeftCenter", {size_w/1.5, size_h/2}, base.name, nil, {"%02.0f"}, CMFD_FONT_W)
    object.element_params = {default_element_params, "RADAR_TDC_ALT_UPPER",}
    object.controllers = {default_controllers[1], {"text_using_parameter", 1,0}}
    

    object = addStrokeText(nil, "LA", CMFD_STRINGDEFS_DEF_X06, "LeftCenter", {size_w/1.5, -size_h/2}, base.name, nil, {"%02.0f"}, CMFD_FONT_W)
    object.element_params = {default_element_params, "RADAR_TDC_ALT_LOWER",}
    object.controllers = {default_controllers[1], {"text_using_parameter", 1,0}}
    return base
end
object = addRadarCursor(0.05)

-- STT
function addSTT(radius)
    local base = addPlaceholder(nil, {0, -grid_h/2})
    base.element_params = {
        "RADAR_STT_AZIMUTH_NORM",
        "RADAR_STT_RANGE_NORM",
        "RADAR_MODE"
    }
    base.controllers = {
        {"move_left_right_using_parameter", 0, lr_scale},
        {"move_up_down_using_parameter", 1, ud_scale},
        {"parameter_compare_with_number", 2, 3}
    }
    local object
    object = addStrokeCircle(nil, radius, {0,0}, base.name, nil, nil, nil, nil, nil, CMFD_MATERIAL_WHITE)
    object.thickness = 0.1
    object.element_params = {default_element_params, "RADAR_STT_ANGLE"}
    object.controllers = {default_controllers[1], {"rotate_using_parameter", 1, 1}}
    object = addStrokeLine(nil, radius, {0,radius}, 0, object.name, nil, nil, nil, nil, CMFD_MATERIAL_WHITE)
    object.thickness = 0.1
    object = addStrokeLine(nil, radius, {0,0}, 0, object.parent_element, nil, nil, nil, nil, CMFD_MATERIAL_WHITE)
    object.thickness = 0.1
    object.vertices = {{0, radius}, {-radius * 0.707, -radius *0.707}, {radius * 0.707, -radius *0.707}}
    object.indices = {0,1, 1,2, 2,0}


    object = addStrokeText(nil, "HA", CMFD_STRINGDEFS_DEF_X06, "CenterTop", {0, -radius*1.2 }, base.name, nil, {"%02.0f\n","%02.00f"}, CMFD_FONT_W)
    object.element_params = {default_element_params, "RADAR_STT_ALT", "RADAR_STT_SPD"}
    object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}, {"text_using_parameter", 2, 1}}


    -- HPT Bulls Eye information
    object = addStrokeText(nil, "135`\n10 ", CMFD_STRINGDEFS_DEF_X08, "RightCenter", {-0.65, -0.7}, nil, nil, {"%03.0f'\n%02.0f"})
    object.element_params = {default_element_params, "RDR_HPT_BULLS_AZ", "RDR_HPT_BULLS_DIST", "RDR_HPT_AVAIL"}
    object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}, {"text_using_parameter", 2, 1}, {"parameter_compare_with_number", 3, 1}}

    -- HPT Data Block
    object = addStrokeText(nil, "135`\n450\n11L", CMFD_STRINGDEFS_DEF_X08, "LeftBottom", {0.65, -0.75 + 0.06}, nil, nil, {"%03.0f`\n", "%03.0f\n", "%02.0f", "%s"})
    object.element_params = {default_element_params, "RDR_HPT_HDG", "RDR_HPT_REL_SPD", "RDR_HPT_DIR", "RDR_HPT_DIR_LR", "RDR_HPT_AVAIL"}
    object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}, {"text_using_parameter", 2, 1}, {"text_using_parameter", 3, 2}, {"text_using_parameter", 4, 3}, {"parameter_compare_with_number", 5, 1}}

    -- HPT Time to Target
    object = addStrokeText(nil, "00:00", CMFD_STRINGDEFS_DEF_X08, "RightCenter", {-0.65, 0.68}, nil, nil, {"%02.0f:", "%02.0f"})
    object.element_params = {default_element_params, "RDR_HPT_TTT_MIN", "RDR_HPT_TTT_SEC", "RDR_HPT_AVAIL"}
    object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}, {"text_using_parameter", 2, 1}, {"parameter_compare_with_number", 3, 1}}

    return base
end
object = addSTT(0.025)

object = addDLZ({0.8,0}, 0.03, 0.5, nil, CMFD_STRINGDEFS_DEF_X08, false)