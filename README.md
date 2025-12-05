# 勉強用ワークフロー自動化プロジェクト

## 📋 プロジェクト概要

このプロジェクトは、ボタン1つまたはショートカットキーで勉強専用のアプリケーションを起動し、3画面環境で適切な位置に自動配置するワークフローを実現するものです。

### 最終的な成果物

- **Hammerspoon設定ファイル** (`init.lua`)
- 2つの起動モード：
  1. 通常起動（Cmd+Shift+S）: デフォルトのSlackスレッドを開く
  2. Slack検索付き起動（Cmd+Shift+P）: ユーザー入力で任意のキーワードをSlack検索

---

## 🖥️ システム環境

### ハードウェア構成
- **3画面構成**:
  - 左モニター: HP E232 (1920×1080)
  - 中央モニター: A271D / Laptop (1920×1080) - メインディスプレイ
  - 右: なし（当初の要件から変更）

### ソフトウェア環境
- **OS**: macOS Tahoe 26.1
- **必要なアプリケーション**:
  - Terminal（標準）
  - Claude アプリ
  - Google Chrome + Focus To-Do拡張機能
  - Slack デスクトップアプリ
  - Rectangle（当初使用予定だったが最終的には不使用）
  - **Hammerspoon**（最終的な自動化ツール）

---

## 📖 開発の時系列記録

### Phase 1: 要件定義と初期調査（開始）

#### 初期要件
- **目的**: ボタンまたはショートカットキーワンアクションで勉強用アプリを起動・配置
- **画面配置**:
  - 中央モニター: Claude（右）+ Terminal（左）
  - 左モニター: Chrome（Focus To-Doポップアップ、左）+ Slack作業スレ（右）
- **使用ツール**: Rectangleを使って画面分割

#### 追加情報の収集
- OS: macOS確認
- インストール済み: Claude, Rectangle, Slack（主にアプリ版）
- Focus To-Do: Chrome拡張機能、ポップアップ形式
- モニター解像度: 左1920×1080、正面1920×1080
- 起動方法: デスクトップアイコン/ランチャー優先

#### モニター配置の明確化
当初「中央モニター」と表現されていたのが実際にはA271D（ノートPC）であることが判明：
- **左**: HP E232
- **中央**: A271D（Laptop）
- 右モニターは存在しない（2画面構成）

---

### Phase 2: AppleScriptでの初期実装試行

#### 実装方針
AppleScriptとRectangleのショートカットキーを組み合わせた自動化スクリプトを作成。

#### 作成したファイル
1. **study_workflow.applescript** - メインスクリプト
2. **SETUP_GUIDE.md** - セットアップ手順

#### 技術的アプローチ
- `System Events`を使ったキーストローク操作
- Rectangleのショートカット（Cmd+Option+←/→）でウィンドウ配置
- `open location`でSlackスレッドを開く
- `keystroke "p" using {command down}`でFocus To-Do起動

#### 直面した問題：権限エラー

**エラー1**: "Linuxシステムの仕組み_勉強モード起動にはキー操作の送信は許可されません（1002）"

**原因**: macOS Tahoeの厳しいセキュリティ制限
- アクセシビリティ権限だけでは不十分
- `System Events`を使ったキーストローク操作がブロックされる

**試みた対策**:
1. アクセシビリティ権限の付与
2. 入力監視権限の付与
3. スクリプトエディタからAutomatorへの変更

---

### Phase 3: Automatorでの再実装試行

#### アプローチ変更の理由
スクリプトエディタで作成したアプリがmacOS Tahoeで厳しく制限されるため、macOSネイティブのAutomatorを使用。

#### 実装内容
1. **study_workflow_automator.applescript** - Automator用スクリプト
2. **AUTOMATOR_SETUP_GUIDE.md** - Automator版セットアップガイド

#### 技術的改善
- `keystroke`の代わりに`key code`を使用
  - `key code 123` = 左矢印（←）
  - `key code 124` = 右矢印（→）
  - `key code 35` = P キー
- 待機時間の最適化
- 座標の明示的な指定

#### 問題の継続
それでも同じ権限エラーが発生：
```
System Eventsでエラーが起きました: Linuxシステムの仕組み_勉強モード起動にはキー操作の送信は許可されません。
```

**結論**: `System Events`を使った方法はmacOS Tahoe では動作不可能

---

### Phase 4: Hammerspoon への移行（ブレイクスルー）

#### 決断
Rectangle CLIの有無を確認したところ、CLIが存在しないことが判明。
→ **Hammerspoon**の導入を決定

#### Hammerspoon選択の理由
- macOS Tahoeの厳しいセキュリティ制限を回避可能
- Luaスクリプトで直接ウィンドウ管理
- Rectangle不要
- より柔軟なカスタマイズが可能
- 無料・オープンソース

#### 作成したファイル
1. **HAMMERSPOON_INSTALL.md** - インストールガイド
2. **init.lua** - Hammerspoon設定ファイル（メイン成果物）
3. **HAMMERSPOON_COMPLETE_GUIDE.md** - 完全セットアップガイド

---

### Phase 5: Hammerspoon実装の詳細

#### 基本構造

```lua
-- 設定
config = {
    slackThreadURL = "https://freee.slack.com/archives/...",
    dockGap = 189,  -- 5cm
    leftMonitorName = "HP E232",
    centerMonitorName = "A271D",
}

-- モニター取得関数
getLeftScreen()
getCenterScreen()

-- ウィンドウ配置関数
positionTerminal()
positionClaude()
positionChrome()
positionSlack()
positionFocusToDo()

-- メイン関数
startStudyWorkflow()
```

#### 初期実装の動作確認
✅ アプリの起動成功
✅ 基本的な配置動作

---

### Phase 6: 詳細な調整と問題解決

#### 問題1: Terminalのサイズが変更されない

**現象**: Terminalがデフォルトサイズのまま

**試みた対策**:
1. Claudeと同じ高さ（Dock上5cm空け）に設定
2. 待機時間の調整
3. `setFrame`の複数回実行
4. デバッグ出力の追加

**最終的な解決策**: 
サイズ変更を諦め、**位置のみを変更**する方針に変更。
デフォルトサイズのまま中央モニター左側に配置。

```lua
local currentFrame = win:frame()
local newFrame = hs.geometry.rect(
    screenFrame.x,
    screenFrame.y,
    currentFrame.w,  -- 現在の幅を維持
    currentFrame.h   -- 現在の高さを維持
)
```

#### 問題2: Terminalが左モニターに配置される

**原因**: モニター座標の認識ミス

**デバッグ方法**:
```lua
local screens = hs.screen.allScreens()
for i, screen in ipairs(screens) do
    print(i .. ": " .. screen:name() .. " - " .. hs.inspect(screen:frame()))
end
```

**結果**:
```
1: A271D - { x=0.0, y=31.0, w=1920.0, h=958.0 }
2: HP E232 - { x=-1920.0, y=-35.0, w=1920.0, h=1049.0 }
```

**解決策**: 
`hs.geometry.rect()`を使って正確な座標を指定
```lua
local frame = hs.geometry.rect(
    screenFrame.x,  -- 0（中央）or -1920（左）
    screenFrame.y,
    screenFrame.w / 2,
    screenFrame.h
)
```

#### 問題3: Focus To-Doのポップアップ配置

**要件変更**:
- ポップアップは左モニターの左半分に配置
- ポップアップを開いたChromeウィンドウは最小化

**実装**:
1. Chromeを左モニターで起動
2. Cmd+Pでポップアップを開く
3. ポップアップのタイトルを検索して配置
4. メインのChromeウィンドウのみ最小化

```lua
-- Focus To-Doポップアップ以外のChromeウィンドウを最小化
for _, win in ipairs(windows) do
    local title = win:title()
    if not (string.find(title, "Focus") or string.find(title, "To-Do")) then
        win:minimize()
    end
end
```

**トラブルシューティング**: 
一度Focus To-Doポップアップ自体が最小化される問題が発生。
→ タイトル検索のロジックを改善して解決。

#### 問題4: Slackで検索窓が開いてしまう

**現象**: Slack起動時に検索窓（Cmd+K）が表示される

**原因**: スレッドを開くために使用していた`Cmd+K`ショートカット

**解決策**: 
`Cmd+K`を削除し、`hs.urlevent.openURL()`のみでスレッドを開く

```lua
-- 修正前
hs.eventtap.keyStroke({"cmd"}, "k")
hs.urlevent.openURL(config.slackThreadURL)

-- 修正後
hs.urlevent.openURL(config.slackThreadURL)
```

---

### Phase 7: 機能拡張 - Slack検索機能の追加

#### 要件
ユーザー入力でSlack検索キーワードを受け取って検索したい

#### 技術調査
Hammerspoonには以下の入力受付方法がある：
- `hs.dialog.textPrompt()` - テキスト入力ダイアログ
- `hs.dialog.blockAlert()` - 選択ダイアログ
- `hs.osascript.applescript()` - AppleScript経由

#### 実装

**新規関数**:
```lua
function searchInSlack(keyword)
    local slack = hs.application.get("Slack")
    slack:activate()
    
    -- Cmd+K で検索窓を開く
    hs.eventtap.keyStroke({"cmd"}, "k")
    
    -- キーワードを入力
    hs.eventtap.keyStrokes(keyword)
    
    -- Enterで検索実行
    hs.eventtap.keyStroke({}, "return")
end
```

**メイン関数の修正**:
```lua
function startStudyWorkflow(slackSearchKeyword)
    -- ...
    if slackSearchKeyword and slackSearchKeyword ~= "" then
        searchInSlack(slackSearchKeyword)
    else
        hs.urlevent.openURL(config.slackThreadURL)
    end
end
```

#### ショートカットキーの苦難

**試行1: Cmd+Shift+F**
- **問題**: macOSのシステムショートカットとバッティング
- **症状**: 何も反応しない

**試行2: Cmd+Shift+K → L（2段階）**
```lua
local kPressed = false

hs.hotkey.bind({"cmd", "shift"}, "K", function()
    kPressed = true
    -- 2秒後にリセット
end)

hs.hotkey.bind({}, "L", function()
    if kPressed then
        -- 検索モード起動
    end
end)
```
- **問題**: ユーザーから変更要望

**試行3: Option+Cmd+[**
```lua
hs.hotkey.bind({"alt", "cmd"}, "[", function()
```
- **問題**: 認識されない
- **対策**: キーコード使用
```lua
hs.hotkey.bind({"alt", "cmd"}, 33, function()  -- 33 = [
```
- **問題**: それでも認識されない
- **原因**: macOSシステムショートカットとバッティング

**デバッグ**:
```lua
hs.hotkey.bind({}, "[", function()
    hs.alert.show("[キーが押されました")
end)
-- → 動作確認OK
```

Consoleでの確認:
```
04:56:00 hotkey: Disabled previous hotkey ⌘⌥[
04:56:00 hotkey: Enabled hotkey ⌘⌥[
```
→ Hammerspoonでは認識されているが、macOSが優先してブロック

**最終決定: Cmd+Shift+P**
```lua
hs.hotkey.bind({"cmd", "shift"}, "P", function()
    -- Slack検索モード
end)
```
✅ 動作確認OK

#### ダイアログの実装

**方法1**: `hs.dialog.textPrompt`（動作せず）

**方法2**: `hs.dialog.blockAlert` + AppleScript
```lua
local button = hs.dialog.blockAlert(
    "勉強モード起動",
    "Slack検索キーワードを入力しますか？",
    "通常起動",
    "検索付き起動"
)

if button == "検索付き起動" then
    local script = [[
        set keyword to text returned of (display dialog "Slack検索キーワードを入力してください:" default answer "" buttons {"キャンセル", "OK"} default button "OK")
        return keyword
    ]]
    
    local success, keyword = hs.osascript.applescript(script)
    
    if success and keyword ~= "" then
        startStudyWorkflow(keyword)
    end
end
```

---

## 🎯 最終的な仕様

### アプリケーション配置

#### 中央モニター（A271D - 1920×1080）
```
┌──────────────┬──────────────┐
│   Terminal   │    Claude    │
│   (左半分)    │   (右半分)    │
│              │              │
│ Dock上5cm    │ Dock上5cm    │
│   空ける     │   空ける     │
│              │              │
└──────────────┴──────────────┘
```

#### 左モニター（HP E232 - 1920×1080）
```
┌──────────────┬──────────────┐
│  Focus To-Do │    Slack     │
│  (ポップ     │ (作業スレ or │
│   アップ)    │   検索結果)  │
│              │              │
│   左半分     │   右半分     │
└──────────────┴──────────────┘
```

### 起動モード

#### モード1: 通常起動
**ショートカット**: `Cmd + Shift + S`
**動作**:
1. Terminal起動 → 中央左に配置
2. Claude起動 → 中央右に配置
3. Chrome起動 → 左モニター左に配置
4. Slack起動 → 左モニター右に配置、デフォルトスレッドを開く
5. Focus To-Do起動 → Cmd+Pでポップアップ
6. Chromeメインウィンドウを最小化

#### モード2: Slack検索付き起動
**ショートカット**: `Cmd + Shift + P`
**動作**:
1. ダイアログ1: 起動モード選択
   - 「A」または「a」入力 → 検索機能付き起動
   - 「B」または「b」入力 → 通常起動
2. 「A」選択時:
   - ダイアログ2: キーワード入力
   - Slack検索を実行（Cmd+F → キーワード入力 → Enter）
3. 「B」選択時: 通常起動と同じ

### メニューバー
📚 アイコンをクリック:
- 勉強モード起動（通常）
- 勉強モード起動（Slack検索）
- Hammerspoon再読み込み

---

## 📁 ファイル構成

### 最終成果物
```
.
├── init.lua                          # Hammerspoon設定ファイル（メイン）
├── HAMMERSPOON_COMPLETE_GUIDE.md     # 完全セットアップガイド
├── HAMMERSPOON_INSTALL.md            # インストール手順
└── README.md                         # このファイル
```

### 開発過程で作成（最終的には不使用）
```
├── study_workflow.applescript        # 初期AppleScript版
├── study_workflow_automator.applescript  # Automator版
├── SETUP_GUIDE.md                    # AppleScript版ガイド
└── AUTOMATOR_SETUP_GUIDE.md          # Automator版ガイド
```

---

## 🔧 技術的なポイント

### モニター座標の取得
```lua
local screens = hs.screen.allScreens()
-- A271D: x=0, y=31 (メニューバー分のオフセット)
-- HP E232: x=-1920, y=-35 (左モニターは負の座標)
```

### ウィンドウ配置の確実性
```lua
-- hs.geometry.rect()を使用
local frame = hs.geometry.rect(x, y, width, height)
win:setFrame(frame, 0)  -- 0 = アニメーションなし
```

### アプリケーション起動の待機時間
```lua
hs.timer.usleep(1000000)  -- 1秒 = 1,000,000マイクロ秒
```

### ウィンドウの識別
```lua
-- タイトルで識別
local title = win:title()
if string.find(title, "Focus") or string.find(title, "To-Do") then
    -- Focus To-Doウィンドウ
end
```

### キーストローク
```lua
-- 修飾キー付き
hs.eventtap.keyStroke({"cmd"}, "k")

-- テキスト入力
hs.eventtap.keyStrokes("検索キーワード")

-- キーコード使用
hs.eventtap.keyStroke({}, "return")  -- Enter
```

---

## 🚨 遭遇した技術的課題と解決策

### 1. macOS Tahoeのセキュリティ制限
**課題**: `System Events`を使ったキーストローク操作が完全にブロック
**解決**: Hammerspoonに移行（異なるアプローチで権限問題を回避）

### 2. Terminalのサイズ変更不可
**課題**: `setFrame()`でサイズを指定しても変更されない
**解決**: サイズ変更を諦め、位置変更のみに限定

### 3. モニター座標の認識
**課題**: 左モニターが負の座標であることを考慮する必要
**解決**: `hs.screen.allScreens()`で実際の座標を確認し、明示的に指定

### 4. Focus To-Doポップアップの扱い
**課題**: ポップアップウィンドウとメインウィンドウの区別
**解決**: タイトル検索でポップアップを識別、メインウィンドウのみ最小化

### 5. ショートカットキーのバッティング
**課題**: macOSシステムショートカットが優先される
**解決**: 複数の組み合わせを試し、バッティングしないキーを選択

### 6. ダイアログの互換性
**課題**: `hs.dialog.textPrompt`が動作しない環境
**解決**: AppleScriptベースのダイアログに変更

---

## 📊 開発統計

- **開発期間**: 約4時間
- **試行したアプローチ**: 3つ（AppleScript → Automator → Hammerspoon）
- **作成したスクリプトファイル**: 7つ
- **ドキュメントファイル**: 6つ
- **遭遇したエラー**: 10以上
- **ショートカットキー変更回数**: 5回
- **最終的なコード行数**: 約250行（init.lua）

---

## 🎓 学んだ教訓

1. **macOS Tahoeの制限を早期に把握すべき**
   - 最初からHammerspoonを選択していれば開発時間を短縮できた

2. **実環境での動作確認が重要**
   - モニター座標などは実際に取得しないと正確には分からない

3. **柔軟な要件調整**
   - Terminalのサイズ変更など、技術的制約があれば要件を調整

4. **段階的な実装とテスト**
   - 一度に全機能を実装するのではなく、段階的にテストしながら進める

5. **ユーザーフィードバックの重要性**
   - 実際に動かしてもらうことで、想定外の問題が発覚

---

## 🔮 今後の拡張可能性

### 機能拡張案
1. **複数のワークフローパターン**
   - コーディング用、会議用など、異なる配置パターン
   - ショートカットキーで切り替え

2. **時間帯による自動起動**
   - 特定の時間に自動実行
   - カレンダー連携

3. **アプリ状態の保存・復元**
   - 前回のウィンドウ位置を記憶
   - 作業途中の状態を保存

4. **Focus To-Doとの連携強化**
   - タイマー自動スタート
   - タスク情報の表示

5. **統計情報の記録**
   - 起動回数
   - 使用時間の記録

### 技術的改善案
1. **エラーハンドリングの強化**
   - アプリが起動していない場合のフォールバック
   - リトライロジック

2. **設定ファイルの外部化**
   - JSON/TOMLで設定を管理
   - GUI設定画面

3. **ログ機能の追加**
   - デバッグ情報の記録
   - 問題発生時の追跡

---

## 🙏 謝辞

このプロジェクトの開発過程で参考にした技術・ツール：

- **Hammerspoon**: 強力なmacOS自動化フレームワーク
- **Lua**: シンプルで強力なスクリプト言語
- **AppleScript**: macOSネイティブの自動化
- **Rectangle**: ウィンドウマネージャー（当初の構想で使用）

---

## 🛠️ Phase 8: UI/UX改善と最終調整（2025-12-06）

### 問題1: ダイアログ表示位置とキー入力の問題

**現象**:
- 検索付き起動時のダイアログが左画面ではなく、Claudeアプリの上に表示される
- ダイアログで入力した文字がClaudeに送信されてしまう

**原因**:
AppleScriptの`display dialog`はシステムレベルでダイアログを表示するため、現在アクティブなウィンドウ（Claude）の上に重なって表示され、キーストロークイベントが意図せずClaudeに送信されていた。

**解決策**:
[init.lua:351-358](init.lua#L351-L358), [init.lua:380-387](init.lua#L380-L387)でAppleScriptの`display dialog`を`hs.dialog.textPrompt`に変更

```lua
-- 変更前（AppleScript使用）
local script = [[
    set keyword to text returned of (display dialog "..." default answer "")
    return keyword
]]
local success, keyword = hs.osascript.applescript(script)

-- 変更後（Hammerspoon独自UI）
local button, keyword = hs.dialog.textPrompt(
    "Slack検索キーワード入力",
    "Slack検索キーワードを入力してください:",
    "",
    "OK",
    "キャンセル"
)
```

**効果**:
- ダイアログが他のアプリケーションに影響を与えない
- キーストロークイベントが適切に処理される
- よりシンプルで保守性の高いコード

### 問題2: Slack検索窓の誤認識

**現象**:
検索機能で`Cmd+K`を使用したところ、Slackのメッセージ検索窓ではなく、クイックスイッチャー（チャンネル切り替え）が開く

**原因**:
Slackのショートカットキーの認識違い
- `Cmd+K`: クイックスイッチャー（チャンネル・DM切り替え）
- `Cmd+F`: メッセージ検索窓

**解決策**:
[init.lua:204-205](init.lua#L204-L205)で`Cmd+K`を`Cmd+F`に変更

```lua
-- 変更前
hs.eventtap.keyStroke({"cmd"}, "k")

-- 変更後
hs.eventtap.keyStroke({"cmd"}, "f")
```

### 問題3: ターミナル配置位置の不安定性

**現象**:
ターミナルウィンドウの配置位置が実行ごとに異なる、または意図した位置に配置されない

**原因分析**:
1. `app:mainWindow()`が新規作成されたウィンドウを正しく取得できていない
2. ウィンドウ作成後の待機時間が不十分（800ms）
3. タイミング問題：ウィンドウ作成とフォーカスが完了する前に配置処理が実行

**解決策1**: ウィンドウ取得方法の改善 ([init.lua:63-68](init.lua#L63-L68))

```lua
-- 変更前
local win = app:mainWindow()

-- 変更後
local win = app:focusedWindow()  -- 最新のフォーカスされたウィンドウを優先
if not win then
    win = app:mainWindow()  -- フォールバック
end
```

**解決策2**: 待機時間の調整 ([init.lua:239-246](init.lua#L239-L246))

```lua
-- 変更前
hs.timer.usleep(1000000)  -- 初回起動: 1.0秒
hs.timer.usleep(800000)   -- 新規ウィンドウ: 0.8秒

-- 変更後
hs.timer.usleep(1500000)  -- 初回起動: 1.5秒
hs.timer.usleep(1200000)  -- 新規ウィンドウ: 1.2秒
```

**効果**:
- 新規作成されたターミナルウィンドウを確実に取得
- より安定した配置動作

### 問題4: ターミナルとClaudeの配置調整

**要件変更**:
ターミナルを中央モニターの左半分に配置し、Claudeと境界線がピッタリ合うように、かつ高さも同じにする

**実装**: [init.lua:55-97](init.lua#L55-L97)

```lua
-- 変更前（デフォルトサイズ維持、位置のみ変更）
local newFrame = hs.geometry.rect(
    screenFrame.x,
    screenFrame.y,
    currentFrame.w,  -- 現在の幅を維持
    currentFrame.h   -- 現在の高さを維持
)

-- 変更後（左半分、Claudeと同じ高さ）
local newFrame = hs.geometry.rect(
    screenFrame.x,              -- 中央モニターの左端
    screenFrame.y,              -- 中央モニターの上端
    screenFrame.w / 2,          -- 画面幅の半分
    screenFrame.h - config.dockGap  -- Claudeと同じ高さ（Dock上に空白）
)
```

**配置結果**:
```
┌─────────────────┬─────────────────┐
│   Terminal      │     Claude      │
│   (左半分)       │     (右半分)     │
│                 │                 │
│   画面上端から   │   画面上端から   │
│   Dock上189px   │   Dock上189px   │
│   まで          │   まで          │
├─────────────────┴─────────────────┤
│         Dock (189px)              │
└───────────────────────────────────┘
```

### 問題5: 起動モード選択UIの改善

**要件変更**:
`Cmd+Shift+P`の後の選択肢をキーボード入力式に変更
- A = 検索機能付き
- B = 通常起動

**変更前**: [init.lua:343-348](init.lua#L343-L348)
```lua
local button, result = hs.dialog.blockAlert(
    "勉強モード起動",
    "Slack検索キーワードを入力しますか？",
    "通常起動",
    "検索付き起動"
)
```

**変更後**: [init.lua:341-376](init.lua#L341-L376)
```lua
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
    elseif choice == "B" or choice == "b" then
        -- 通常起動
    else
        -- 無効な選択は通常起動
    end
end
```

**改善点**:
- キーボードのみで操作可能（A/B入力 → Enter）
- 大文字・小文字どちらでも対応
- より直感的で高速な操作が可能

---

## 📝 更新履歴

### v1.1.0 (2025-12-06)
- ダイアログUIを`hs.dialog.textPrompt`に統一
- Slack検索のショートカットを`Cmd+F`に修正
- ターミナル配置の安定性を改善（`focusedWindow()`の使用、待機時間の調整）
- ターミナルを中央モニターの左半分に配置（Claudeと境界線が一致）
- 起動モード選択をキーボード入力式（A/B選択）に変更

### v1.0.0 (2025-12-06)
- 初版リリース
- 通常起動モード実装
- Slack検索付き起動モード実装
- Hammerspoon完全移行
- 全機能動作確認完了

---

## 📧 連絡先・サポート

問題が発生した場合：
1. Hammerspoon Consoleでエラーログを確認
2. `hs.screen.allScreens()`でモニター情報を確認
3. アプリ名やモニター名が正しいか確認

---

**Project Status**: ✅ Complete
**Last Updated**: 2025-12-06
**Version**: 1.1.0
