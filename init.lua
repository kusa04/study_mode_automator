-- Hammerspoon 勉強用ワークフロー設定
-- ~/.hammerspoon/init.lua に配置

-- ==========================================
-- 設定: モニター解像度とURL
-- ==========================================
local config = {
    slackThreadURL = "https://freee.slack.com/archives/D09PL27BS1J/p1763737135532199",
    dockGap = 189,  -- Dockの上5cm（約189ピクセル）
    leftMonitorName = "HP E232",  -- 左モニター
    centerMonitorName = "A271D",  -- 中央モニター（Laptop）
}

-- ==========================================
-- ヘルパー関数: モニター取得
-- ==========================================
local function getScreenByName(name)
    local screens = hs.screen.allScreens()
    for _, screen in ipairs(screens) do
        if string.find(screen:name(), name) then
            return screen
        end
    end
    return nil
end

local function getLeftScreen()
    -- 左モニターを取得（HP E232）
    local leftScreen = getScreenByName("HP E232")
    if leftScreen then
        return leftScreen
    end
    -- 見つからない場合は、最も左の画面を取得
    local screens = hs.screen.allScreens()
    table.sort(screens, function(a, b)
        return a:frame().x < b:frame().x
    end)
    return screens[1]
end

local function getCenterScreen()
    -- 中央モニターを取得（A271D / Laptop）
    local centerScreen = getScreenByName("A271D")
    if centerScreen then
        return centerScreen
    end
    -- 見つからない場合は、プライマリ画面
    return hs.screen.primaryScreen()
end

-- ==========================================
-- ウィンドウ配置関数
-- ==========================================

-- 中央モニター: Terminal（デフォルトサイズで左側に配置）
local function positionTerminal()
    local app = hs.application.get("Terminal")
    if not app then 
        hs.alert.show("Terminal not found")
        return 
    end
    
    local win = app:mainWindow()
    if not win then 
        hs.alert.show("Terminal window not found")
        return 
    end
    
    local screen = getCenterScreen()
    local screenFrame = screen:frame()
    
    -- 現在のウィンドウサイズを取得
    local currentFrame = win:frame()
    
    print("Terminal current: " .. hs.inspect(currentFrame))
    print("Center screen: " .. hs.inspect(screenFrame))
    
    -- サイズはそのまま、位置だけを中央モニター（A271D）の左上に移動
    local newFrame = hs.geometry.rect(
        screenFrame.x,  -- 中央モニターの左端（x=0）
        screenFrame.y,  -- 中央モニターの上端（y=31）
        currentFrame.w,  -- 現在の幅を維持
        currentFrame.h   -- 現在の高さを維持
    )
    
    print("Terminal target: " .. hs.inspect(newFrame))
    
    win:setFrame(newFrame, 0)
    
    local afterFrame = win:frame()
    print("Terminal after: " .. hs.inspect(afterFrame))
    
    hs.alert.show("✓ Terminal配置完了")
end

-- 中央モニター: Claude（右側、Dock上5cm空け）
local function positionClaude()
    local app = hs.application.get("Claude")
    if not app then return end
    
    local win = app:mainWindow()
    if not win then return end
    
    local screen = getCenterScreen()
    local screenFrame = screen:frame()
    
    -- 中央モニター（A271D）の右半分、Dock上に空白
    local frame = hs.geometry.rect(
        screenFrame.x + screenFrame.w / 2,  -- 右半分の開始位置
        screenFrame.y,
        screenFrame.w / 2,
        screenFrame.h - config.dockGap
    )
    
    win:setFrame(frame)
end

-- 左モニター: Chrome（左半分）
local function positionChrome()
    local app = hs.application.get("Google Chrome")
    if not app then return end
    
    -- 最新のウィンドウを取得
    local windows = app:allWindows()
    local win = windows[1]
    if not win then return end
    
    local screen = getLeftScreen()
    local screenFrame = screen:frame()
    
    -- 左モニター（HP E232）の左半分に配置
    local frame = hs.geometry.rect(
        screenFrame.x,  -- 左モニターの左端（-1920）
        screenFrame.y,  -- 左モニターの上端（-35）
        screenFrame.w / 2,
        screenFrame.h
    )
    
    win:setFrame(frame)
end

-- 左モニター: Slack（右半分）
local function positionSlack()
    local app = hs.application.get("Slack")
    if not app then return end
    
    local win = app:mainWindow()
    if not win then return end
    
    local screen = getLeftScreen()
    local screenFrame = screen:frame()
    
    -- 左モニター（HP E232）の右半分に配置
    local frame = hs.geometry.rect(
        screenFrame.x + screenFrame.w / 2,  -- 右半分の開始位置
        screenFrame.y,
        screenFrame.w / 2,
        screenFrame.h
    )
    
    win:setFrame(frame)
end

-- Focus To-Doポップアップを左モニターの左半分に配置
local function positionFocusToDo()
    -- Focus To-Doポップアップは拡張機能のウィンドウとして開かれる
    -- Chromeのすべてのウィンドウをチェック
    local chrome = hs.application.get("Google Chrome")
    if not chrome then return end
    
    local windows = chrome:allWindows()
    for _, win in ipairs(windows) do
        local title = win:title()
        -- Focus To-Doのポップアップを探す
        if string.find(title, "Focus") or string.find(title, "To-Do") or string.find(title, "Pomodoro") then
            local screen = getLeftScreen()
            local screenFrame = screen:frame()
            
            -- 左モニター（HP E232）の左半分に配置
            local frame = hs.geometry.rect(
                screenFrame.x,  -- 左モニターの左端
                screenFrame.y,  -- 左モニターの上端
                screenFrame.w / 2,
                screenFrame.h
            )
            
            win:setFrame(frame)
            return
        end
    end
end

-- ==========================================
-- メイン関数: 勉強用ワークフロー起動
-- ==========================================
function startStudyWorkflow()
    hs.notify.new({
        title = "勉強モード起動中",
        informativeText = "アプリケーションを起動しています..."
    }):send()
    
    -- 1. Terminal を起動
    local terminal = hs.application.get("Terminal")
    
    if not terminal then
        -- Terminalが起動していない場合
        hs.application.launchOrFocus("Terminal")
        hs.timer.usleep(1000000)  -- 起動待ち
        terminal = hs.application.get("Terminal")
    else
        -- 既に起動している場合は新規ウィンドウ
        terminal:activate()
        hs.timer.usleep(500000)
        hs.eventtap.keyStroke({"cmd"}, "n")  -- 新規ウィンドウ
        hs.timer.usleep(800000)
    end
    
    -- ウィンドウが作成されるまで待機
    hs.timer.usleep(500000)
    positionTerminal()
    hs.timer.usleep(500000)
    
    -- 2. Claude を起動
    hs.application.launchOrFocus("Claude")
    hs.timer.usleep(1000000)  -- 1秒待機
    positionClaude()
    hs.timer.usleep(500000)
    
    -- 3. Google Chrome を起動（左モニター）
    local chrome = hs.application.get("Google Chrome")
    local isNewWindow = false
    
    if not chrome then
        -- Chromeが起動していない場合は起動
        hs.application.launchOrFocus("Google Chrome")
        hs.timer.usleep(1500000)
        isNewWindow = true
    else
        -- 既に起動している場合は新規ウィンドウを作成
        chrome:activate()
        hs.timer.usleep(500000)
        hs.eventtap.keyStroke({"cmd"}, "n")  -- 新規ウィンドウ
        hs.timer.usleep(1000000)
        isNewWindow = true
    end
    
    -- 左モニターに移動してから配置
    if isNewWindow then
        positionChrome()
        hs.timer.usleep(500000)
    end
    
    -- 4. Slack を起動
    hs.application.launchOrFocus("Slack")
    hs.timer.usleep(1500000)  -- 1.5秒待機
    
    positionSlack()
    hs.timer.usleep(500000)
    
    -- Slackの特定スレッドを開く
    local slack = hs.application.get("Slack")
    if slack then
        slack:activate()
        hs.timer.usleep(500000)
        -- Cmd+K でクイック切り替え
        hs.eventtap.keyStroke({"cmd"}, "k")
        hs.timer.usleep(500000)
        -- URLをペーストして開く（代替方法）
        hs.urlevent.openURL(config.slackThreadURL)
        hs.timer.usleep(1000000)
    end
    
    -- 5. Focus To-Do を開く（Chrome → 左モニター）
    local chrome = hs.application.get("Google Chrome")
    if chrome then
        chrome:activate()
        hs.timer.usleep(500000)
        
        -- Cmd+P でFocus To-Doを開く
        hs.eventtap.keyStroke({"cmd"}, "p")
        hs.timer.usleep(1500000)  -- ポップアップが開くまで待機
        
        -- Focus To-Doを左モニターに配置
        positionFocusToDo()
        hs.timer.usleep(500000)
        
        -- Chromeのメインウィンドウ（Focus To-Doではないウィンドウ）を最小化
        local windows = chrome:allWindows()
        for _, win in ipairs(windows) do
            local title = win:title()
            -- Focus To-Doのポップアップ以外のウィンドウを最小化
            if not (string.find(title, "Focus") or string.find(title, "To-Do") or string.find(title, "Pomodoro")) then
                win:minimize()
            end
        end
        
        hs.alert.show("Focus To-Do起動完了")
    end
    
    -- 完了通知
    hs.notify.new({
        title = "勉強モード起動完了！",
        informativeText = "Focus To-Doのポップアップを手動で配置してください。",
        soundName = "Glass"
    }):send()
end

-- ==========================================
-- ホットキー設定（オプション）
-- ==========================================
-- Cmd+Shift+S で起動
hs.hotkey.bind({"cmd", "shift"}, "S", function()
    startStudyWorkflow()
end)

-- ==========================================
-- メニューバーボタン（オプション）
-- ==========================================
local menubar = hs.menubar.new()
if menubar then
    menubar:setTitle("📚")
    menubar:setTooltip("勉強モード起動")
    menubar:setMenu({
        { title = "勉強モード起動", fn = startStudyWorkflow },
        { title = "-" },
        { title = "Hammerspoon再読み込み", fn = function() hs.reload() end }
    })
end

-- ==========================================
-- 起動メッセージ
-- ==========================================
hs.notify.new({
    title = "Hammerspoon 読み込み完了",
    informativeText = "Cmd+Shift+S で勉強モードを起動できます"
}):send()

hs.alert.show("Hammerspoon設定読み込み完了\nCmd+Shift+S で起動")
