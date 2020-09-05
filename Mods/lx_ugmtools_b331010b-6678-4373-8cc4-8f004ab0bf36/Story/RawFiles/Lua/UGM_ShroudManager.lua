local function RegenerateMapShroud()
    for x=0,1000,1 do
        for y=0,1000,1 do
            Ext.UpdateShroud(x, y, "Shroud", 0)
        end
	end
	print("Changed shroud")
end

local function ShroudManager(call, message)
	--print("Received message: "..call.." "..message)
	if message == "Regenerate" then RegenerateMapShroud() end
end

Ext.RegisterNetListener("UGM_Shroud_Manager", ShroudManager)