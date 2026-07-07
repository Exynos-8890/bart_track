# Bart Track

Bart Track 是一个 macOS 桌面小组件，用来查看 BART 车站的实时到站倒计时。它最初按 Daly City 通勤场景设计：你从家走到车站需要一段时间，小组件只显示你理论上赶得上的车。

当前版本支持：

- 选择任意 BART 出发站，默认 `Daly City`。
- 设置步行到车站的时间，默认 `8` 分钟，范围 `0...60`。
- 选择是否只显示可赶上的车，默认开启。
- 主 App 默认隐藏 Dock 图标；可以在设置里重新打开。
- 点击小组件里的 `LIVE BART` 按钮会打开 BART 官方 Daly City 实时出发页面。
- 在 small / medium / large / extra large Widget 尺寸下显示不同密度的信息。
- 显示数据更新时间；如果 WidgetKit 没有及时刷新，会显示 `OLD` / `STALE`。
- 写入 debug log，方便排查为什么信息变旧。

## 显示逻辑

小组件里的数字表示 **车还有多少分钟到站**，不是你多久后出门。

默认配置是：

```json
{
  "showsOnlyCatchableDepartures": true,
  "showsDockIcon": false,
  "openURLString": "https://www.bart.gov/schedules/eta/DALY",
  "station": "DALY",
  "walkingMinutes": 8
}
```

含义是：

- `station: "DALY"`：从 Daly City 站出发。
- `walkingMinutes: 8`：你需要 8 分钟走到车站。
- `showsOnlyCatchableDepartures: true`：只显示到站时间大于 8 分钟的车。
- `showsDockIcon: false`：主 App 运行时不显示 Dock 图标。
- `openURLString`：点击小组件里 `LIVE BART` 按钮时打开的网页，默认是 BART 官方 Daly City 实时出发页。

例如某辆车 `7m` 后到站，步行时间是 `8`，它会被隐藏，因为你大概率赶不上。某辆车 `10m` 后到站，它会显示。

如果你把 `walkingMinutes` 改成 `0`，基本就相当于显示所有未来到站的车，但 `Leaving` / `0m` 这种已经到站的车仍然不会被当作可赶上的车。

## Widget 尺寸

当前展示密度：

- Small / `1x1`：每个方向最多显示 3 班可赶上的车，左右两列分别显示 north / south。
- Medium / `1x2`：每个方向最多显示 4 班可赶上的车。
- Large / `2x2` 和 Extra Large：每个方向最多显示 8 班可赶上的车。

每个车次只显示分钟数和线路颜色，不显示终点站、站台、catchable count 等占空间的信息。

## 推荐使用方式：App 里修改设置

安装后打开：

```bash
open ~/Applications/BartTrack.app
```

App 窗口里可以修改：

- `Station`：出发站。
- `Walking time`：从你当前位置走到车站需要几分钟。
- `Show only later trains`：是否只显示大于步行时间的车。
- `Show Dock icon`：是否让主 App 出现在 Dock 栏。
- `Open URL`：点击桌面小组件里 `LIVE BART` 按钮时打开的网页。

修改后 App 会自动保存配置，并调用 `WidgetCenter.shared.reloadAllTimelines()` 请求系统刷新小组件。

注意：macOS WidgetKit 不保证一定按我们的请求立即刷新。它可能根据系统状态延迟刷新，所以偶尔看到 `OLD` 不一定代表 BART API 出错。

你可以 quit 掉 Bart Track 主 App。小组件的自动刷新由 macOS WidgetKit 启动 Widget extension 完成，不依赖主 App 常驻。主 App 只负责设置界面、写配置、手动请求刷新和显示 debug log。

## 手动修改配置文件

配置文件路径是：

```text
~/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack/settings.json
```

可以用命令打开目录：

```bash
open "$HOME/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack"
```

也可以直接用编辑器打开：

```bash
open -e "$HOME/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack/settings.json"
```

配置文件示例：

```json
{
  "showsOnlyCatchableDepartures": true,
  "showsDockIcon": false,
  "openURLString": "https://www.bart.gov/schedules/eta/DALY",
  "station": "DALY",
  "walkingMinutes": 8
}
```

字段说明：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `station` | string | BART 车站缩写，例如 Daly City 是 `DALY`。 |
| `walkingMinutes` | number | 走到车站需要几分钟；会被限制在 `0...60`。 |
| `showsOnlyCatchableDepartures` | boolean | `true` 只显示到站时间大于步行时间的车；`false` 显示原始时间顺序里的车。 |
| `showsDockIcon` | boolean | `false` 隐藏主 App 的 Dock 图标；`true` 显示 Dock 图标。 |
| `openURLString` | string | 点击小组件里 `LIVE BART` 按钮时打开的 URL，例如 `https://www.bart.gov/schedules/eta/DALY`。 |

手动改完配置后，建议打开 Bart Track App 点一次 `Reload Widget`，或者重新打开 App：

```bash
open ~/Applications/BartTrack.app
```

## 常用配置例子

只看 Daly City，步行 8 分钟，只显示能赶上的车：

```json
{
  "showsOnlyCatchableDepartures": true,
  "showsDockIcon": false,
  "openURLString": "https://www.bart.gov/schedules/eta/DALY",
  "station": "DALY",
  "walkingMinutes": 8
}
```

从 24th St. Mission 出发，步行 5 分钟：

```json
{
  "showsOnlyCatchableDepartures": true,
  "showsDockIcon": false,
  "openURLString": "https://www.bart.gov/schedules/eta/24TH",
  "station": "24TH",
  "walkingMinutes": 5
}
```

从 Embarcadero 出发，显示所有未来车次：

```json
{
  "showsOnlyCatchableDepartures": false,
  "showsDockIcon": false,
  "openURLString": "https://www.bart.gov/schedules/eta/EMBR",
  "station": "EMBR",
  "walkingMinutes": 0
}
```

## BART 站点缩写表

`station` 必须使用 BART 官方站点缩写。

| 缩写 | 站点 |
| --- | --- |
| `12TH` | 12th St. Oakland City Center |
| `16TH` | 16th St. Mission |
| `19TH` | 19th St. Oakland |
| `24TH` | 24th St. Mission |
| `ANTC` | Antioch |
| `ASHB` | Ashby |
| `BALB` | Balboa Park |
| `BAYF` | Bay Fair |
| `BERY` | Berryessa/North San Jose |
| `CAST` | Castro Valley |
| `CIVC` | Civic Center/UN Plaza |
| `COLS` | Coliseum |
| `COLM` | Colma |
| `CONC` | Concord |
| `DALY` | Daly City |
| `DBRK` | Downtown Berkeley |
| `DUBL` | Dublin/Pleasanton |
| `DELN` | El Cerrito del Norte |
| `PLZA` | El Cerrito Plaza |
| `EMBR` | Embarcadero |
| `FRMT` | Fremont |
| `FTVL` | Fruitvale |
| `GLEN` | Glen Park |
| `HAYW` | Hayward |
| `LAFY` | Lafayette |
| `LAKE` | Lake Merritt |
| `MCAR` | MacArthur |
| `MLBR` | Millbrae |
| `MLPT` | Milpitas |
| `MONT` | Montgomery St. |
| `NBRK` | North Berkeley |
| `NCON` | North Concord/Martinez |
| `OAKL` | Oakland International Airport |
| `ORIN` | Orinda |
| `PITT` | Pittsburg/Bay Point |
| `PCTR` | Pittsburg Center |
| `PHIL` | Pleasant Hill/Contra Costa Centre |
| `POWL` | Powell St. |
| `RICH` | Richmond |
| `ROCK` | Rockridge |
| `SBRN` | San Bruno |
| `SFIA` | San Francisco International Airport |
| `SANL` | San Leandro |
| `SHAY` | South Hayward |
| `SSAN` | South San Francisco |
| `UCTY` | Union City |
| `WCRK` | Walnut Creek |
| `WARM` | Warm Springs/South Fremont |
| `WDUB` | West Dublin/Pleasanton |
| `WOAK` | West Oakland |

## 安装

### 1. 构建并测试

```bash
swift test
```

```bash
xcodebuild \
  -project BartTrack.xcodeproj \
  -scheme BartTrack \
  -configuration Debug \
  -derivedDataPath .build/XcodeDerivedData \
  CODE_SIGNING_ALLOWED=YES \
  CODE_SIGN_IDENTITY=- \
  build
```

### 2. 卸载旧版本

仓库里有复用脚本：

```bash
bash scripts/uninstall-barttrack.sh
```

这个脚本会：

- 停掉 `BartTrack.app` 和 Widget extension 进程。
- 从 `pluginkit` 里注销旧 extension。
- 删除 `~/Applications/BartTrack.app`。
- 验证旧进程和旧注册是否还存在。

### 3. 安装新版本

```bash
mkdir -p "$HOME/Applications"
```

```bash
ditto \
  .build/XcodeDerivedData/Build/Products/Debug/BartTrack.app \
  "$HOME/Applications/BartTrack.app"
```

### 4. 注册 Widget extension

```bash
pluginkit -a "$HOME/Applications/BartTrack.app/Contents/PlugIns/BartTrackWidgetExtension.appex"
```

验证注册状态：

```bash
pluginkit -m -A -D -v -i com.local.BartTrack.WidgetExtension
```

正常情况下会看到类似：

```text
com.local.BartTrack.WidgetExtension(1.0) ... ~/Applications/BartTrack.app/Contents/PlugIns/BartTrackWidgetExtension.appex
```

### 5. 打开 App

```bash
open "$HOME/Applications/BartTrack.app"
```

打开后 App 会写入默认配置，并请求 Widget 刷新。

## 添加到桌面小组件

安装并打开 App 后：

1. 在 macOS 桌面空白处右键。
2. 选择 `Edit Widgets...` / `编辑小组件...`。
3. 搜索 `Daly City BART` 或 `Bart Track`。
4. 选择尺寸，例如 small / medium / large。
5. 拖到桌面或通知中心。

说明：当前 Widget 在系统选择器里的名字仍然是 `Daly City BART`，即使你把出发站改成别的站。实际数据会按配置文件里的 `station` 读取。

## 卸载

```bash
bash scripts/uninstall-barttrack.sh
```

这个脚本不会删除配置文件和 debug log。如果你想清理配置，可以删除：

```bash
rm -rf "$HOME/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack"
```

注意：这个命令会删掉 `settings.json` 和 `debug.log`。

## 数据来源

当前使用 BART Legacy ETD JSON endpoint：

```text
https://api.bart.gov/api/etd.aspx?cmd=etd&orig=DALY&key=MW9S-E7SL-26DU-VV8V&json=y
```

实际请求时 `orig` 会替换成你的 `station` 配置，例如：

```text
https://api.bart.gov/api/etd.aspx?cmd=etd&orig=EMBR&key=...&json=y
```

代码里把请求、解码和展示分开：

- `Sources/BartTrackCore`：BART 请求、ETD 解码、配置、debug log。
- `Sources/BartTrackWidgetUI`：小组件 UI 和布局规则。
- `Sources/BartTrackWidgetKit`：WidgetKit timeline provider 和刷新策略。
- `Xcode/BartTrackApp`：主 App 设置界面。

以后如果要换成 GTFS / GTFS-RT，可以优先替换 Core 里的数据源，不需要重写 Widget UI。

## 为什么会显示 OLD / STALE

Widget 顶部会显示最后一次数据生成时间。如果数据过期，会显示：

- small 尺寸：`OLD`
- medium / large 尺寸：`STALE HH:mm`

当前 timeline 策略：

- 请求系统大约 30 秒后刷新一次。
- 同时放入一个 90 秒后的 stale entry。
- 如果 macOS WidgetKit 在 90 秒内没有再次调用 provider，就会显示 `OLD` / `STALE`。

这不一定是 BART API 错。macOS 可以根据系统策略延迟 Widget 刷新。

## Debug Log

debug log 路径：

```text
~/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack/debug.log
```

查看最近日志：

```bash
tail -n 80 "$HOME/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack/debug.log"
```

日志前缀是：

```text
[BARTTRACK-DEBUG]
```

常见事件：

| 事件 | 含义 |
| --- | --- |
| `timeline.start` | WidgetKit 调用了 provider，开始生成新 timeline。 |
| `service.request.start` | 开始请求 BART API。 |
| `service.request.success` | BART API 请求成功，并解码出 north/south 车次。 |
| `service.request.failure` | BART API 请求或解码失败。 |
| `timeline.loaded` | 成功生成 fresh entry。 |
| `timeline.complete` | provider 把 timeline 返回给 WidgetKit。 |

排查 OLD 的方法：

1. 看到 OLD 后打开 App，看 Debug Log 区域。
2. 如果出现 `service.request.failure`，说明 BART 请求失败或网络有问题。
3. 如果没有 failure，但 `timeline.start` 中间断了超过 90 秒，说明 macOS WidgetKit 没有及时调用 provider。
4. 如果 `timeline.start` 很频繁但 UI 仍然 OLD，说明可能是系统缓存或 Widget 视图没有更新，需要重新添加 Widget 或重启 Widget 相关进程。

## 开发命令

运行测试：

```bash
swift test
```

生成 Widget 预览图：

```bash
swift run BartTrackSnapshot widget-preview.png
```

打开 Xcode 工程：

```bash
open BartTrack.xcodeproj
```

查看 Git 历史：

```bash
git log --oneline
```

回滚最近一次提交：

```bash
git revert HEAD
```

回滚指定提交：

```bash
git revert <commit-sha>
```
