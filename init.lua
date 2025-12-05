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

-- 中央モニター: Terminal（左半分、Claudeと同じ高さ）
local function positionTerminal()
    local app = hs.application.get("Terminal")
    if not app then
        hs.alert.show("Terminal not found")
        return
    end

    -- フォーカスされているウィンドウを取得（最新のウィンドウ）
    local win = app:focusedWindow()
    if not win then
        -- フォーカスされているウィンドウがない場合はmainWindowを使用
        win = app:mainWindow()
    end

    if not win then
        hs.alert.show("Terminal window not found")
        return
    end

    local screen = getCenterScreen()
    local screenFrame = screen:frame()

    print("Terminal current: " .. hs.inspect(win:frame()))
    print("Center screen: " .. hs.inspect(screenFrame))

    -- 中央モニター（A271D）の左半分、Claudeと同じ高さ（Dock上に空白）
    local newFrame = hs.geometry.rect(
        screenFrame.x,  -- 中央モニターの左端（x=0）
        screenFrame.y,  -- 中央モニターの上端（y=31）
        screenFrame.w / 2,  -- 画面幅の半分
        screenFrame.h - config.dockGap  -- Claudeと同じ高さ（Dock上に空白）
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

-- Slackで検索を実行する関数
local function searchInSlack(keyword)
    local slack = hs.application.get("Slack")
    if not slack then
        hs.alert.show("Slackが起動していません")
        return
    end

    slack:activate()
    hs.timer.usleep(300000)

    -- Cmd+F でメッセージ検索窓を開く
    hs.eventtap.keyStroke({"cmd"}, "f")
    hs.timer.usleep(500000)

    -- キーワードを入力
    if keyword and keyword ~= "" then
        hs.eventtap.keyStrokes(keyword)
        hs.timer.usleep(300000)

        -- Enterで検索実行
        hs.eventtap.keyStroke({}, "return")
    end
end

-- ==========================================
-- メイン関数: 勉強用ワークフロー起動
-- ==========================================
function startStudyWorkflow(slackSearchKeyword)
    hs.notify.new({
        title = "勉強モード起動中",
        informativeText = "アプリケーションを起動しています..."
    }):send()
    
    -- 1. Terminal を起動
    local terminal = hs.application.get("Terminal")

    if not terminal then
        -- Terminalが起動していない場合
        hs.application.launchOrFocus("Terminal")
        hs.timer.usleep(1500000)  -- 起動待ち（1.5秒）
        terminal = hs.application.get("Terminal")
    else
        -- 既に起動している場合は新規ウィンドウ
        terminal:activate()
        hs.timer.usleep(500000)
        hs.eventtap.keyStroke({"cmd"}, "n")  -- 新規ウィンドウ
        hs.timer.usleep(1200000)  -- ウィンドウ作成待ち（1.2秒）
    end

    -- ウィンドウが確実に作成されフォーカスされるまで待機
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
    
    -- Slackの特定スレッドを開くか、キーワード検索
    if slackSearchKeyword and slackSearchKeyword ~= "" then
        -- キーワードが指定されている場合は検索
        searchInSlack(slackSearchKeyword)
    else
        -- キーワードがない場合は特定スレッドを開く
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
-- ホットキー設定
-- ==========================================
-- Cmd+Shift+S で通常起動（デフォルトスレッド）
hs.hotkey.bind({"cmd", "shift"}, "S", function()
    startStudyWorkflow()
end)

-- Cmd+Shift+P でSlack検索キーワード入力付き起動
hs.hotkey.bind({"cmd", "shift"}, "P", function()
    -- テキスト入力で選択肢を表示
    local button, choice = hs.dialog.textPrompt(
        "勉強モード起動",
        "起動モードを選択してください:\nA = 検索機能付き\nB = 通常起動",
        "",
        "OK",
        "キャンセル"
    )

    if button == "OK" then
        if choice == "A" or choice == "a" then
            -- 検索機能付き起動
            local button2, keyword = hs.dialog.textPrompt(
                "Slack検索キーワード入力",
                "Slack検索キーワードを入力してください:",
                "",
                "OK",
                "キャンセル"
            )

            if button2 == "OK" and keyword ~= "" then
                startStudyWorkflow(keyword)
            else
                startStudyWorkflow()
            end
        elseif choice == "B" or choice == "b" then
            -- 通常起動
            startStudyWorkflow()
        else
            hs.alert.show("無効な選択です。通常起動します。")
            startStudyWorkflow()
        end
    end
end)

-- ==========================================
-- メニューバーボタン
-- ==========================================
local menubar = hs.menubar.new()
if menubar then
    menubar:setTitle("📚")
    menubar:setTooltip("勉強モード起動")
    menubar:setMenu({
        { title = "勉強モード起動（通常）", fn = function() startStudyWorkflow() end },
        { title = "勉強モード起動（Slack検索）", fn = function()
            -- Hammerspoonのテキスト入力ダイアログを使用
            local button, keyword = hs.dialog.textPrompt(
                "Slack検索キーワード入力",
                "Slack検索キーワードを入力してください:",
                "",
                "OK",
                "キャンセル"
            )

            if button == "OK" and keyword ~= "" then
                startStudyWorkflow(keyword)
            else
                startStudyWorkflow()
            end
        end },
        { title = "-" },
        { title = "Hammerspoon再読み込み", fn = function() hs.reload() end }
    })
end

-- ==========================================
-- 起動メッセージ
-- ==========================================
hs.notify.new({
    title = "Hammerspoon 読み込み完了",
    informativeText = "Cmd+Shift+S: 通常起動\nCmd+Shift+P: Slack検索付き起動"
}):send()

hs.alert.show("Hammerspoon設定読み込み完了\nCmd+Shift+S: 通常 / Cmd+Shift+P: Slack検索")
