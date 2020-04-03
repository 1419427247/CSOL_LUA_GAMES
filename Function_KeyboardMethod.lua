--功能_键盘方法,按K键自杀,按J加100血,按空格高跳,按SHIFT冲刺,作者@iPad水晶,QQ:1419427247
--  project.json
-------------------------------
--  {
--     "common":[
      
--      ],
--     "game": [
--       "Function_KeyboardMethod.lua"
--     ],
--     "ui": [
--       "Function_KeyboardMethod.lua"
--     ]
--  }
-------------------------------
--信号_自杀
local Signal_Suicide = 1;
--信号_恢复100生命
local Signal_Restore = 2;
--信号_高跳
local Signal_SuperJump = 3;
--信号_冲呀
local Signal_Rush = 4;
if Game~= nil then
    --当玩家使用UI.Signal时调用的事件回调
    function Game.Rule:OnPlayerSignal(player,signal);
        if signal == Signal_Suicide then
            print("你死了/(ㄒ_ㄒ)/~~");
            player:Kill();
        elseif signal == Signal_Restore then
            print("你恢复啦");
            if player.health + 100 > player.maxhealth then
                player.health = player.maxhealth;
            else
                player.health = player.health + 100;
            end
        elseif signal == Signal_SuperJump then
            print("你跳起来啦");
            player.velocity = {
                x = player.velocity.x,
                y = player.velocity.y,
                z = 800,
            };
        elseif signal == Signal_Rush then
            print("你在冲啊");
            player.velocity = {
                x = player.velocity.x * 20,
                y = player.velocity.y * 20,
                z = player.velocity.z,
            };
        end

    end
end

if UI ~= nil then
    --玩家按下某个键时调用的事件回调,inputs是一个数组,用于存储发生KeyDown事件的键
    function UI.Event:OnKeyDown(inputs)

        if inputs[UI.KEY.K] == true then
            print("你按下了K");
            UI.Signal(Signal_Suicide);
        end

        if inputs[UI.KEY.J] == true then
            print("你按下了J");
            UI.Signal(Signal_Restore);
        end

        if inputs[UI.KEY.SPACE] == true then
            print("你按下了空格");
            UI.Signal(Signal_SuperJump);
        end

        if inputs[UI.KEY.SHIFT] == true then
            print("你按下了SHIFT");
            UI.Signal(Signal_Rush);
        end
    end
end