--功能_显示玩家地速,静止时不显示地速,作者@iPad水晶,QQ:1419427247
--  project.json
-------------------------------
--  {
--     "common":[
      
--      ],
--     "game": [
--       "Function_ShowSpeed.lua"
--     ],
--     "ui": [
--       "Function_ShowSpeed.lua"
--     ]
--  }
-------------------------------

if Game then
    --所有玩家都存储在这个表里
    local Players = {};

    --向移动中的玩家发送他的地速信息
    function Game.Rule:OnUpdate()
        for name, player in pairs(Players) do
            if player.velocity.x ~= 0 and player.velocity.y ~= 0 then
                player:Signal(math.floor(math.sqrt(player.velocity.x * player.velocity.x + player.velocity.y * player.velocity.y)));
            end
        end
    end

    function Game.Rule:OnPlayerConnect(player)
        Players[player.name] = player;
    end

    function Game.Rule:OnPlayerDisconnect(player)
        Players[player.name] = nil;
    end

end
if UI then
    --创建一个Text，用来显示地速
    LabelSpeed = UI.Text.Create();
    LabelSpeed:Set(
        {
            text = '0',
            font = 'medium',
            align = 'center',
            x = 0,
            y = UI.ScreenSize().height / 9 * 8,
            width = UI.ScreenSize().width,
            height = 40,
            r = 250,
            g = 10,
            b = 10,
            a = 250
        }
    );
    
    local count = 0;
    
    function UI.Event:OnSignal(signal)
        count = 0;
        LabelSpeed:Show();
        LabelSpeed:Set({text = "" .. (signal)});
    end

    function UI.Event:OnUpdate()
        count = count + 1;
        if count == 50 then
            LabelSpeed:Hide();
            count = 0;
        end
    end
end