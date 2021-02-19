local function RegenerateMapShroud()
    local grid = Ext.GetAiGrid()
    local scale = grid.GridScale / 0.125
    local minX, maxX = grid.OffsetX, grid.OffsetX + grid.Width - scale
    local minZ, maxZ = grid.OffsetZ, grid.OffsetZ + grid.Height - scale
    local x, z

    for x=minX,maxX,grid.GridScale do
        for z=minZ,maxZ,grid.GridScale do
            Ext.UpdateShroud(x, z, "Shroud", 0)
        end
    end
	print("Changed shroud")
end

local function ShroudManager(call, message)
	--print("Received message: "..call.." "..message)
	if message == "Regenerate" then RegenerateMapShroud() end
end

Ext.RegisterNetListener("UGM_Shroud_Manager", ShroudManager)