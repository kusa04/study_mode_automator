# 勉強用ワークフロー - Hammerspoon完全自動化セットアップ

## 🎯 このガイドでできること

ボタン1つで以下を自動実行：
- **中央モニター（A271D）**: Terminal（左上半分）+ Claude（右側、Dock上5cm空け）
- **左モニター（HP E232）**: Chrome（左半分）+ Slack作業スレ（右半分）
- Focus To-Do ポップアップを自動で開く

## 📋 必要なもの

- ✅ Hammerspoon（無料）
- ✅ すでにインストール済み: Terminal, Claude, Google Chrome, Slack

---

## 🚀 セットアップ手順

### ステップ1: Hammerspoonをインストール

#### 方法A: 公式サイトから（推奨）

1. https://www.hammerspoon.org にアクセス
2. **Download** をクリック
3. ダウンロードした `.dmg` を開いて **Hammerspoon.app** を **アプリケーション**フォルダにドラッグ
4. アプリケーションフォルダから **Hammerspoon** を起動

#### 方法B: Homebrewから

```bash
brew install --cask hammerspoon
```

### ステップ2: 権限設定

1. Hammerspoon起動時に **アクセシビリティ権限** を求められるので「許可」
2. **システム設定** → **プライバシーとセキュリティ** → **アクセシビリティ**
3. **Hammerspoon** がオンになっていることを確認

### ステップ3: 設定ファイルを配置

#### 3-1. Hammerspoon設定フォルダを開く

メニューバーのHammerspoonアイコン（🔨）をクリック → **Open Config** を選択

これで `~/.hammerspoon/` フォルダが開きます。

#### 3-2. 設定ファイルをコピー

1. ダウンロードした `init.lua` ファイルを `~/.hammerspoon/` フォルダに配置
   - すでに `init.lua` がある場合は**バックアップを取ってから上書き**
   
**または**、ターミナルからコピー：

```bash
# ダウンロードフォルダから設定フォルダにコピー
cp ~/Downloads/init.lua ~/.hammerspoon/init.lua
```

### ステップ4: 設定を読み込む

1. メニューバーのHammerspoonアイコンをクリック
2. **Reload Config** を選択

画面に「Hammerspoon設定読み込み完了」と表示されればOK！

---

## 🎮 使い方

### 方法1: キーボードショートカット（推奨）

```
Cmd + Shift + S
```

を押すだけで、すべてのアプリが自動起動・配置されます！

### 方法2: メニューバーから

メニューバーの **📚** アイコンをクリック → **勉強モード起動** を選択

### 方法3: Hammerspoonコンソールから

1. メニューバーのHammerspoonアイコン → **Console**
2. 以下を入力して Enter:

```lua
startStudyWorkflow()
```

---

## ⚙️ カスタマイズ

### Slackスレッドを変更

`init.lua` の6行目を編集：

```lua
slackThreadURL = "あなたのSlackスレッドURL",
```

### Dock上の空白を調整

7行目を編集：

```lua
dockGap = 189,  -- 5cm（約189ピクセル）
```

### ショートカットキーを変更

149行目を編集：

```lua
hs.hotkey.bind({"cmd", "shift"}, "S", function()
```

例: `Cmd+Option+S` にする場合：

```lua
hs.hotkey.bind({"cmd", "alt"}, "S", function()
```

### モニター名を調整

もしモニターが正しく認識されない場合、4-5行目を編集：

```lua
leftMonitorName = "HP E232",
centerMonitorName = "A271D",
```

---

## 🐛 トラブルシューティング

### エラー: ウィンドウが配置されない

**原因**: モニター名が正しく認識されていない

**解決法**:

1. Hammerspoon Console を開く（メニューバー → Console）
2. 以下を入力して Enter:

```lua
hs.screen.allScreens()
```

3. 表示されたモニター名を確認
4. `init.lua` の `leftMonitorName` と `centerMonitorName` を修正
5. Reload Config

### キーボードショートカットが効かない

**原因**: Hammerspoonにアクセシビリティ権限がない

**解決法**:
- **システム設定** → **プライバシーとセキュリティ** → **アクセシビリティ**
- Hammerspoon がオンになっているか確認

### アプリが起動しない

**原因**: アプリ名が正しくない

**解決法**:

1. Console で確認:

```lua
hs.application.runningApplications()
```

2. 正しいアプリ名を確認して `init.lua` を修正

### Focus To-Doが開かない

**原因**: ショートカットキーが `Cmd+P` でない

**解決法**:
- Chrome拡張機能のショートカット設定を確認: `chrome://extensions/shortcuts`
- `Cmd+P` に設定されているか確認

---

## 🎯 さらなる便利機能（オプション）

### デスクトップアイコンで起動

1. **Automator** を開く
2. **新規書類** → **アプリケーション**
3. 「AppleScriptを実行」を追加
4. 以下を貼り付け:

```applescript
do shell script "/usr/local/bin/hs -c 'startStudyWorkflow()'"
```

5. 「勉強モード起動」として保存

### Alfred / Raycast から起動

Alfred または Raycast に以下のスクリプトを登録:

```bash
/usr/local/bin/hs -c 'startStudyWorkflow()'
```

### 複数のワークフローを作成

`init.lua` に追加:

```lua
function startCodingWorkflow()
    -- コーディング用の配置
end

hs.hotkey.bind({"cmd", "shift"}, "C", startCodingWorkflow)
```

---

## 📝 注意事項

- 初回実行時はアプリの起動に時間がかかります（2回目以降は高速）
- Focus To-Doのポップアップは位置を手動調整してください
- すべてのアプリを事前に1度起動しておくとスムーズです

## 💡 ヒント

- Hammerspoonは非常に強力なツールです
- Luaの知識があれば、さらに複雑な自動化も可能
- 公式ドキュメント: https://www.hammerspoon.org/docs/

---

## 🎉 完了！

これで完全自動化のセットアップが完了です。

**Cmd+Shift+S** を押して、勉強モードを起動してください！

何か問題があれば、Hammerspoon Console でエラーログを確認できます。
