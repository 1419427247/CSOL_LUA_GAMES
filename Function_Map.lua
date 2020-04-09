--功能_地图,作者@iPad水晶,QQ:1419427247
--  project.json
-------------------------------
--  {
--     "common":[
      
--      ],
--     "game": [
--       "Function_Map.lua"
--     ],
--     "ui": [
--       "Function_Map.lua"
--     ]
--  }
-------------------------------
if Game ~= nil then

    function Game.Rule:OnUpdate()
        
    end
    local Points = Game.SyncValue:Create("Points");
    local PointList = {};
    function Point(bool,id)
        PointList[#PointList + 1] = {Game.GetScriptCaller().position.x,Game.GetScriptCaller().position.y};
        print(#PointList);
    end

    function Game.Rule:OnUpdate()
        for i = 1,#PointList do
            print(PointList[i]);
        end
    end
end