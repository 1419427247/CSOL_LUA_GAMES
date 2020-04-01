--功能_投票踢人,作者@iPad水晶,QQ:1419427247
--  project.json
-------------------------------
--  {
--     "common":[
      
--      ],
--     "game": [
--       "VoteKick.lua"
--     ],
--     "ui": [
--       "VoteKick.lua"
--     ]
--  }
-------------------------------

local Signal_Kicked = 101;
local Signal_Y = 102;
local Signal_N = 103;


local StateVoteKick = {
    None = 0,
    Voting = 1,
    VotingEnds = 2,
}
if Game then
    Timer = (function()
        local Timer = {
            count = 0,
            array = {},
        };

        function Game.Rule:OnUpdate()
            Timer.count = Timer.count + 1;
            for i = #Timer.array,1,-1 do
                if Timer.array[i][2] >= Timer.count then
                    Timer.array[i][1]();
                    table.remove(Timer.array,i);
                end
            end
        end

        function Timer:schedule(func,delay)
            self.array[#self.array+1] = {func,self.count + delay};
        end

        return Timer;
    end)();

    local VoteKick = {
        PlayerNames = Game.SyncValue.Create("PlayerNames"),
        Kicked = Game.SyncValue.Create("Kicked"),
        State = Game.SyncValue.Create("State"),
        Yes = 0,
        No = 0,
    }

    function Game.Rule:OnRoundStart()
        State.value = StateVoteKick.None;
    end

    function Game.Rule:OnPlayerSignal(player,signal)
        if signal == Signal_Kicked and State.value == StateVoteKick.None then
            
        elseif signal == Signal_Y and State.value == StateVoteKick.Voting then

        elseif signal == Signal_N and State.value == StateVoteKick.Voting then
            
        end
    end
end

if UI then

    Graphics = (function()
        local Graphics = {
            id = 1,
            root = {},
            color = {255,255,255,255},
        };
    
        function Graphics:DrawRect(x,y,width,height)
            local box = UI.Box.Create();
            if box == nil then
                print("无法绘制矩形:已超过最大限制");
                return;
            end
            box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
            box:Show();
            self.root[#self.root + 1] = {self.id,{box}};
            self.id = self.id + 1;
            return self.id - 1;
        end
    
        function Graphics:DrawText(x,y,size,letterspacing,text)
            local str = {
                array = {},
                length = 0,
                charAt = function(self,index)
                    if index > 0 and index <= self.length then
                        return self.array[index];
                    end
                    print("数组下标越界");
                end,
            };
            local currentIndex = 1;
            while currentIndex <= #text do
                local cs = 1;
                local seperate = {0, 0xc0, 0xe0, 0xf0};
                for i = #seperate, 1, -1 do
                    if string.byte(text, currentIndex) >= seperate[i] then
                        cs = i;
                        break;
                    end
                end
                str.array[#str.array+1] = string.sub(text,currentIndex,currentIndex+cs-1);
                currentIndex = currentIndex + cs;
                str.length = str.length + 1;
            end
            self.root[#self.root + 1] = {self.id,{}};
            for i=1,str.length do
                local char = str:charAt(i)
                if Font[char] == nil then
                    char = '?';
                end
                for j = 1,#Font[char],4 do
                    local x1 = Font[char][j];
                    local y1 = Font[char][j+1];
                    local x2 = Font[char][j+2];
                    local y2 = Font[char][j+3];
    
                    local box = UI.Box.Create();
                    if box == nil then
                        print("无法绘制矩形:已超过最大限制");
                        return;
                    end
                    if i == 1 then
                        box:Set({x=x + x1*size,y=y + (12 - y2)*size,width=(x2 - x1)*size,height=(y2 - y1)*size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
                    else
                        box:Set({x=x + (i-1) * letterspacing + x1*size,y=y + (12 - y2)*size,width=(x2 - x1)*size,height=(y2 - y1)*size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
                    end
                    (self.root[#self.root][2])[#self.root[#self.root][2] + 1] = box;
                    box:Show();
                end
            end
            self.id = self.id + 1;
            return self.id - 1;
        end
    
        function Graphics:Remove(id)
            for i = 1,#self.root do
                if self.root[i][1] == id then
                    self.root[i] = nil;
                    collectgarbage("collect");
                    return;
                end
            end
        end
    
        function Graphics:Show(id)
            for i = 1,#self.root do
                if self.root[i][1] == id then
                    for j = 1,#self.root[i][2] do
                        self.root[i][2][j]:Show();
                    end
                    return;
                end
            end
        end
    
        function Graphics:Hide(id)
            for i = 1,#self.root do
                if self.root[i][1] == id then
                    for j = 1,#self.root[i][2] do
                        self.root[i][2][j]:Hide();
                    end
                    return;
                end
            end
        end
    
        function Graphics:GetTextSize(length,fontsize,letterspacing)
            if length == 0 then
                return 0,12 * fontsize;
            end
            local width = (length - 1) * letterspacing + 11 * fontsize;
            local height = 12 * fontsize;
            return width,height;
        end
    
        
        function Graphics:Clean()
            self.root = {};
            collectgarbage("collect");
        end
    
        return Graphics;
    end)();

    local SyncPlayerNames = UI.SyncValue.Create("PlayerNames");
    local SyncKicked = UI.SyncValue.Create("Kicked");
    local SyncState = UI.SyncValue.Create("State");

    function SyncPlayerNames:OnSync()

    end

    function SyncState:OnSync()

    end

    function UI.Event:OnKeyDown(inputs)
        if inputs[UI.KEY.O] then
            
        end
    end
end