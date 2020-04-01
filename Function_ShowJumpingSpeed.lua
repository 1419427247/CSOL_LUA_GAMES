--功能_显示跳跃时地度,作者@iPad水晶,QQ:1419427247
--  project.json
-------------------------------
--  {
--     "common":[
      
--      ],
--     "game": [
--       "Function_ShowJumpingSpeed.lua"
--     ],
--     "ui": [
--       "Function_ShowJumpingSpeed.lua"
--     ]
--  }
-------------------------------
local SIGNAL_NONE = 0;
local SIGNAL_SPEED = 1;
if Game then
    local Players = {};
    function Game.Rule:OnUpdate()
        for name, player in pairs(Players) do
            if player.velocity.z - player.user.HistoricalSpeedZ > 200 then
                player:Signal(SIGNAL_SPEED);
                player:Signal(math.floor(math.sqrt(player.velocity.x * player.velocity.x + player.velocity.y * player.velocity.y)));
            end
            player.user.HistoricalSpeedZ = player.velocity.z;
        end
    end
    
    function Game.Rule:OnPlayerConnect(player)
        Players[player.name] = player;
        player.user.HistoricalSpeedZ = 0;
    end

    function Game.Rule:OnPlayerDisconnect(player)
        Players[player.name] = nil;
    end
end
if UI then
    LabelJumpspeed = UI.Text.Create();
    LabelJumpspeed:Set(
        {
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
    local FTime = 0;
    local state = SIGNAL_NONE;
    function UI.Event:OnSignal(signal)
        if state == SIGNAL_NONE then
            state = signal;
        else
            if state == SIGNAL_SPEED then
                LabelJumpspeed:Set({text = ""..(signal)})
                state = SIGNAL_NONE
            else
                state = SIGNAL_NONE
            end
        end
        LabelJumpspeed:Show();
        FTime = UI.GetTime();
    end
    function UI.Event:OnUpdate(time)
        if LabelJumpspeed:IsVisible() == true then
            if UI.GetTime() - FTime > 2 then
                LabelJumpspeed:Hide();
            end
        end
    end
end



