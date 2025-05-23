--[[ Preload all images, sounds and fonts from the asset directory ]]

local gfx <const> = playdate.graphics

assets = {}
local image_data = {}
local font_data = {}

function assets.getImage(resource_name)
    resource_name = "assets/image/" .. resource_name
    if image_data[resource_name] == nil then
        image_data[resource_name] = gfx.image.new(resource_name)
    end
    return image_data[resource_name]
end

function assets.getImageTable(resource_name)
    resource_name = "assets/image/" .. resource_name
    if image_data[resource_name] == nil then
        image_data[resource_name] = gfx.imagetable.new(resource_name)
    end
    return image_data[resource_name]
end

function assets.getFont(resource_name)
    resource_name = "assets/font/" .. resource_name
    if (font_data[resource_name] == nil) then
        font_data[resource_name] = gfx.font.new(resource_name) -- DEMO
    end
    return font_data[resource_name]
end