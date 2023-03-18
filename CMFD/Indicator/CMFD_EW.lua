dofile(LockOn_Options.script_path .. "CMFD/CMFD_defs.lua")
dofile(LockOn_Options.script_path .. "Indicator/Indicator_defs.lua")
dofile(LockOn_Options.script_path .. "CMFD/CMFD_pageID_defs.lua")
dofile(LockOn_Options.script_path .. "CMFD/CMFD_SMS_ID_defs.lua")
dofile(LockOn_Options.script_path .. "Systems/weapon_system_api.lua")


local page_root = create_page_root()
page_root.element_params = {"CMFD"..CMFDNu.."Format"}
page_root.controllers = {{"parameter_compare_with_number",0,SUB_PAGE_ID.EW}}

local object

local rwr_on_object = addPlaceholder(nil, nil)
rwr_on_object.element_params = {"RWR_ON"}
rwr_on_object.controllers = {{"parameter_compare_with_number", 0, 0, 1}}

-- OSSs
object = addOSSText(28, "ALL", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_MODE_PRI"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}
object = addOSSText(28, "PRI", rwr_on_object.name)
object = encapsulateObject(object)
object.element_params = {default_element_params, "RWR_MODE_PRI"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 1}}

object = addOSSText(27, "SRCH", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_SEARCH"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}

object = addOSSText(27, "TRCK", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_SEARCH"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 1}}

object = addOSSText(25, "CH/F\nMAN", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_CH_F_MODE"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}
object = addOSSText(25, "CH/F\nSEMI", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_CH_F_MODE"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 1}}
object = addOSSText(25, "CH/F\nAUTO", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_CH_F_MODE"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 2}}


object = addOSSText(24, "PROG\n0", rwr_on_object.name, nil, nil, {"PROG\n%02.0f"})
object.element_params = {default_element_params, "RWR_PROG"}
object.controllers = {default_controllers[1],  {"text_using_parameter", 1, 0}}


object = addOSSText(5, "STR\n0", rwr_on_object.name, nil, nil, {"STR\n%0.0f"})
object.element_params = {default_element_params, "RWR_STR"}
object.controllers = {default_controllers[1],  {"text_using_parameter", 1, 0}}

object = addOSSText(6, "PFM\n0", rwr_on_object.name, nil, nil, {"PFM\n%0.0f"})
object.element_params = {default_element_params, "RWR_PFM"}
object.controllers = {default_controllers[1],  {"text_using_parameter", 1, 0}}

object = addOSSText(7, "EVENT\nMARK", rwr_on_object.name)

object = addOSSText(9, "SIM", rwr_on_object.name, nil, nil)
object.element_params = {default_element_params, "WPN_MASS"}
object.controllers = {default_controllers[1],  {"parameter_compare_with_number", 1, WPN_MASS_IDS.SIM}}

object = addOSSStrokeBox(9, 1, rwr_on_object.name, nil, nil, nil, 3)
object.element_params = {default_element_params, "WPN_MASS", "RWR_SIM"}
object.controllers = {default_controllers[1],  {"parameter_compare_with_number", 1, WPN_MASS_IDS.SIM}, {"parameter_compare_with_number", 2, 1}}


object = addOSSText(10, "CH/F\nWARN\n00/00", rwr_on_object.name, nil, nil, {"CH/F\nWARN\n%02.0f/", "%02.0f"})
object.element_params = {default_element_params, "RWR_WARN_CH", "RWR_WARN_F"}
object.controllers = {default_controllers[1],  {"text_using_parameter", 1, 0},{"text_using_parameter", 2, 1}}

object = addOSSText(11, "MAN\nPROG\n0", rwr_on_object.name, nil, nil, {"MAN\nPROG\n%02.0f"})
object.element_params = {default_element_params, "RWR_MAN_PROG"}
object.controllers = {default_controllers[1],  {"text_using_parameter", 1, 0}}

-- Grid

function addScreen(parent)
    save_parent = default_parent
    default_parent = parent

    local object = addStrokeText(nil, "RWR OFF", CMFD_STRINGDEFS_DEF_X2, "CenterCenter", {0, 0}, nil, nil, {"%05.0f"}, CMFD_FONT_Y)
    object = encapsulateObject(object)
    object.element_params = {"RWR_ON"}
    object.controllers = {{"parameter_compare_with_number", 0, 0}}

    object = addStrokeSymbol(nil, {"f5em_stroke_symbols", "rwr-reticle"}, "CenterCenter", {0, 0}, nil, nil, 0.012, CMFD_MATERIAL_CYAN)
    object = encapsulateObject(object)
    object.element_params = {"RWR_ON"}
    object.controllers = {{"parameter_in_range", 0, 0.5, 2.5}}

    default_parent = object.name

    ---------------------- Threats
    MaxThreats          = 16

    for i=1,MaxThreats do
        local place = addPlaceholder(nil, {0,0})
        if i <= 5 then 
            place.element_params = {
                "RWR_CONTACT_" .. string.format("%02i", i) .. "_SIGNAL", 
                "RWR_CONTACT_" .. string.format("%02i", i) .. "_AZIMUTH", 
                "RWR_SEARCH",
            }
            place.controllers = {
                {"parameter_in_range", 0, 0.5, 10},
                {"rotate_using_parameter", 1, 1},
                {"compare_parameters", 0, 2, 1},
            }
        else
            place.element_params = {
                "RWR_CONTACT_" .. string.format("%02i", i) .. "_SIGNAL", 
                "RWR_CONTACT_" .. string.format("%02i", i) .. "_AZIMUTH",
                "RWR_MODE_PRI",
                "RWR_SEARCH",
            }
            place.controllers = {
                {"parameter_in_range", 0, 0.5, 10},
                {"rotate_using_parameter", 1, 1},
                {"parameter_compare_with_number", 2, 0},
                {"compare_parameters", 0, 3, 1},
            }
        end

        place = addPlaceholder(nil, {0,0.6}, place.name)
        place.element_params = {
            "RWR_CONTACT_" .. string.format("%02i", i) .. "_POWER", 
            "RWR_CONTACT_" .. string.format("%02i", i) .. "_AZIMUTH", 
        }
        place.controllers = {
            {"move_up_down_using_parameter", 0, -GetScale()*0.4},
            {"rotate_using_parameter", 1, -1},
        }
        object = addStrokeText(nil, "??", CMFD_STRINGDEFS_DEF_X1, "CenterCenter", {0, 0}, place.name, nil, {"%s"}, CMFD_FONT_R)
        object.element_params = {default_element_params, "RWR_CONTACT_" .. string.format("%02i", i) .. "_TYPE"}
        object.controllers = {default_controllers[1], {"text_using_parameter", 1}}

        if i==1 then
            object = addStrokeSymbol(nil, {"f5em_stroke_symbols", "rwr-threat"}, "CenterCenter", {0, 0}, place.name, nil, 0.01, CMFD_MATERIAL_RED)
            object = encapsulateObject(object)
            object.element_params = {"RWR_CONTACT_" .. string.format("%02i", i) .. "_NEW"}
            object.controllers = {{"parameter_compare_with_number", 0, 0}}
    
        end

        object = addStrokeSymbol(nil, {"f5em_stroke_symbols", "rwr-track"}, "CenterBottom", {0, 0}, place.name, nil, 0.01, CMFD_MATERIAL_RED)
        object = encapsulateObject(object)
        object.element_params = {"RWR_CONTACT_" .. string.format("%02i", i) .. "_SIGNAL"}
        object.controllers = {{"parameter_compare_with_number", 0, 2}}

        object = addStrokeSymbol(nil, {"f5em_stroke_symbols", "rwr-msl"}, "CenterCenter", {0, 0}, place.name, nil, 0.01, CMFD_MATERIAL_RED)
        object = encapsulateObject(object)
        object.element_params = {"RWR_CONTACT_" .. string.format("%02i", i) .. "_SIGNAL"}
        object.controllers = {{"parameter_compare_with_number", 0, 3}, {"blinking"}}

        object = addStrokeSymbol(nil, {"f5em_stroke_symbols", "rwr-new"}, "CenterCenter", {0, 0}, place.name, nil, 0.01, CMFD_MATERIAL_RED)
        object = encapsulateObject(object)
        object.element_params = {"RWR_CONTACT_" .. string.format("%02i", i) .. "_NEW"}
        object.controllers = {{"parameter_compare_with_number", 0, 1}}
    end


    -- Other Objects
    -- Chaff
    object = addStrokeText(nil, "CH", CMFD_STRINGDEFS_DEF_X15, "CenterCenter", {-0.5, -0.55}, nil, nil)
    object = addStrokeBox(nil, 0.25, 0.1, "CenterCenter", {-0.5, -0.675})

    -- Less than warn count
    object = addStrokeText(nil, "30", CMFD_STRINGDEFS_DEF_X15, "CenterCenter", {-0.5, -0.675}, nil, nil, {"%0.0f"}, CMFD_FONT_Y)
    object.element_params = {default_element_params, "WPN_CHAFF_COUNT", "RWR_WARN_CH"}
    object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}, {"change_color_when_parameter_equal_to_number", 1, 0, 1, 0, 1}, {"compare_parameters", 1, 2, -1}}

    -- More than warn count
    object = addStrokeText(nil, "30", CMFD_STRINGDEFS_DEF_X15, "CenterCenter", {-0.5, -0.675}, nil, nil, {"%0.0f"})
    object.element_params = {default_element_params, "WPN_CHAFF_COUNT", "RWR_WARN_CH"}
    object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}, {"compare_parameters", 1, 2, 1}}

    -- Flare
    object = addStrokeText(nil, "F", CMFD_STRINGDEFS_DEF_X15, "CenterCenter", {0.5, -0.55}, nil, nil)
    object = addStrokeBox(nil, 0.25, 0.1, "CenterCenter", {0.5, -0.675})

    -- Less than warn count
    object = addStrokeText(nil, "15", CMFD_STRINGDEFS_DEF_X15, "CenterCenter", {0.5, -0.675}, nil, nil, {"%0.0f"}, CMFD_FONT_Y)
    object.element_params = {default_element_params, "WPN_FLARE_COUNT", "RWR_WARN_F"}
    object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}, {"change_color_when_parameter_equal_to_number", 1, 0, 1, 0, 1}, {"compare_parameters", 1, 2, -1}}

    -- More than warn count
    object = addStrokeText(nil, "15", CMFD_STRINGDEFS_DEF_X15, "CenterCenter", {0.5, -0.675}, nil, nil, {"%0.0f"})
    object.element_params = {default_element_params, "WPN_FLARE_COUNT", "RWR_WARN_F"}
    object.controllers = {default_controllers[1], {"text_using_parameter", 1, 0}, {"compare_parameters", 1, 2, 1}}

    object = addStrokeText(nil, "CH/F - OFF", CMFD_STRINGDEFS_DEF_X15, "CenterCenter", {0, -0.675}, nil, nil, {"%s"})
    object.element_params = {default_element_params, "RWR_ON"}
    object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 1}}

    object = addStrokeText(nil, "CH/F - SAFE", CMFD_STRINGDEFS_DEF_X15, "CenterCenter", {0, -0.675}, nil, nil, {"%s"}, CMFD_FONT_Y)
    object.element_params = {default_element_params, "RWR_ON", "BASE_SENSOR_WOW_LEFT_GEAR"}
    object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 2}, {"parameter_compare_with_number", 2, 1}}

    object = addStrokeText(nil, "CH/F - SIM", CMFD_STRINGDEFS_DEF_X15, "CenterCenter", {0, -0.675}, nil, nil, {"%s"}, CMFD_FONT_W)
    object.element_params = {default_element_params, "RWR_ON", "RWR_SIM", "BASE_SENSOR_WOW_LEFT_GEAR", "WPN_MASS"}
    object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 2}, {"parameter_compare_with_number", 2, 1}, {"parameter_compare_with_number", 3, 0}, {"parameter_compare_with_number", 4, WPN_MASS_IDS.SIM}}

    default_parent = save_parent
end

local area_width = 1
local area_height = aspect + 0.3

local top_base = addPlaceholder(nil, {0, area_height / 2 - 0.3}, page_root.name)
addScreen(top_base.name)

page_root = create_page_root()
page_root.element_params = {"CMFD"..CMFDNu.."Format"}
page_root.controllers = {{"parameter_compare_with_number", 0, SUB_PAGE_ID.MENU2, 1}}

-- Left Sec

local origin = addPlaceholder(nil, {0,0})
origin.element_params = {"CMFD"..CMFDNu.."FULL", "CMFD"..CMFDNu.."SelLeft"}
origin.controllers = {{"parameter_compare_with_number",0,0}, {"parameter_compare_with_number",1,SUB_PAGE_ID.EW}}

local rwr_on_object = addPlaceholder(nil, nil, origin.name)
rwr_on_object.element_params = {"RWR_ON"}
rwr_on_object.controllers = {{"parameter_compare_with_number", 0, 0, 1}}

object = addOSSText(23, "A\nL\nL", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_MODE_PRI"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}
object = addOSSText(23, "P\nR\nI", rwr_on_object.name)
object = encapsulateObject(object)
object.element_params = {default_element_params, "RWR_MODE_PRI"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 1}}

object = addOSSText(22, "T\nR\nC\nK", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_SEARCH"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}
object = addOSSText(22, "S\nR\nC\nH", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_SEARCH"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 1}}

object = addOSSText(21, "M\nA\nN", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_CH_F_MODE"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}
object = addOSSText(21, "S\nE\nM\nI", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_CH_F_MODE"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 1}}
object = addOSSText(21, "A\nU\nT\nO", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_CH_F_MODE"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 2}}


object = addPlaceholder(nil, {-0.5, -((aspect-0.45)/2 + 0.3)}, origin.name)
object.controllers = {{"scale", 0.6, 0.6, 0.6}}

addScreen(object.name)

object = addStrokeText(nil, "STR\n0", CMFD_STRINGDEFS_DEF_X08, "CenterCenter", {0.55,0.55},object.name,nil, {"STR\n%0.0f"})
object.element_params = {default_element_params, "RWR_STR", "RWR_ON"}
object.controllers = {default_controllers[1],  {"text_using_parameter", 1, 0}, {"parameter_compare_with_number", 2, 0, 1} , {"scale", 1.667, 1.667}}


-- Right Sec
origin = addPlaceholder(nil, {0, 0})
origin.element_params = {"CMFD"..CMFDNu.."FULL", "CMFD"..CMFDNu.."SelRight"}
origin.controllers = {{"parameter_compare_with_number",0,0}, {"parameter_compare_with_number",1,SUB_PAGE_ID.EW}}

rwr_on_object = addPlaceholder(nil, nil, origin.name)
rwr_on_object.element_params = {"RWR_ON"}
rwr_on_object.controllers = {{"parameter_compare_with_number", 0, 0, 1}}

object = addOSSText(12, "A\nL\nL", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_MODE_PRI"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}

object = addOSSText(12, "P\nR\nI", rwr_on_object.name)
object = encapsulateObject(object)
object.element_params = {default_element_params, "RWR_MODE_PRI"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 1}}

object = addOSSText(13, "S\nR\nC\nH", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_SEARCH"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}

object = addOSSText(13, "T\nR\nC\nK", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_SEARCH"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 1}}

object = addOSSText(14, "M\nA\nN", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_CH_F_MODE"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 0}}
object = addOSSText(14, "S\nE\nM\nI", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_CH_F_MODE"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 1}}
object = addOSSText(14, "A\nU\nT\nO", rwr_on_object.name)
object.element_params = {default_element_params, "RWR_CH_F_MODE"}
object.controllers = {default_controllers[1], {"parameter_compare_with_number", 1, 2}}

object = addPlaceholder(nil, {0.5, -((aspect-0.45)/2 + 0.3)}, origin.name)
object.controllers = {{"scale", 0.6, 0.6, 0.6}}

addScreen(object.name)

object = addStrokeText(nil, "STR\n0", CMFD_STRINGDEFS_DEF_X08, "CenterCenter", {0.55,0.55},object.name,nil, {"STR\n%0.0f"})
object.element_params = {default_element_params, "RWR_STR", "RWR_ON"}
object.controllers = {default_controllers[1],  {"text_using_parameter", 1, 0}, {"parameter_compare_with_number", 2, 0, 1} , {"scale", 1.667, 1.667}}
