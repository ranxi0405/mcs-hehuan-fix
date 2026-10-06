# 觅长生 合欢宗 MOD 与东皇的功法数据库 Mod 冲突修复记录

**日期**：2026-10-07  
**游戏**：觅长生 1.0.042  
**框架**：Next 0.9.1  
**BepInEx**：5.4.17.0

---

## 一、问题现象

游戏启动时报错，阻止继续加载：
在检查JSON数据时出现如下错误，已阻止游戏继续加载:
物品表id为40000的神通书籍《魅惑》绑定的神通10003不存在，请检查配表
物品表id为40001的神通书籍《解欲》绑定的神通10002不存在，请检查配表
物品表id为40002的神通书籍《粹阳》绑定的神通10001不存在，请检查配表
物品表id为40011的神通书籍《大迷魂术》绑定的神通10004不存在，请检查配表

text

物品表和技能数据本身完全正确，`desc` 和 `Skill_ID` 一一对应，问题出在数据加载环节。

---

## 二、环境

| 项目 | 路径 |
|---|---|
| 游戏 | `D:\SteamLibrary\steamapps\common\觅长生\` |
| Next DLL | `D:\SteamLibrary\steamapps\workshop\content\1189490\2824845357\Plugins\Next.dll` |
| BepInEx | `D:\SteamLibrary\steamapps\workshop\content\1189490\2824349934\BepInEx\` |
| 合欢宗 MOD（Workshop）| `2937247049` |
| 东皇的功法数据库Mod（Workshop）| `2989247433` |

---

## 三、根因

**合欢宗 MOD 与东皇的功法数据库 Mod 的 `skillJsonData` 文件名完全撞车。**

### 撞车范围

| 文件名 | 合欢宗（2937247049）| 东皇（2989247433）|
|---|---|---|
| 30005.json | 粹阳1（Skill_ID=10001）| 金鹏变（Skill_ID=30001）|
| 30011.json | 解欲1（Skill_ID=10002）| 金翅飞羽（Skill_ID=30002）|
| 30016.json | 魅惑1（Skill_ID=10003）| 金罡光风暴（Skill_ID=30003）|
| 30021.json | 大迷魂术1（Skill_ID=10004）| 阴冥魂灵破2（Skill_ID=30004）|
| 30025.json | 大迷魂术5（Skill_ID=10004）| 小天雷劫1（Skill_ID=30005）|
| 30026–30034 | ❌ 无 | ✅ 东皇独有 |

### 冲突机制

1. Next 用文件名作为 `jsonData.skillJsonData` 的字典 key
2. 两个 MOD 都用 `30005.json` 等文件名，后加载的会**直接覆盖**先加载的
3. 东皇加载在合欢宗之后，合欢宗的 `Skill_ID = 10001–10004` 被覆盖丢失
4. `SkillDatebase.Dict` 中缺失 `10001–10004`
5. 游戏 `CheckData.CheckItem` 检查物品 `desc` 时发现神通不存在，报错

### 排查过程中排除的错误方向

- ❌ **不是** MOD 的 JSON 数据错误：`desc = 10001–10004`、`Skill_ID = 10000–10004` 全部正确
- ❌ **不是** Next 0.9.1 的 `CoverMainData → ResetYSDictionary` 覆盖逻辑问题
- ❌ **不是** Skill_ID 号段撞车：两边用的是不同的 Skill_ID
- ✅ **是** `skillJsonData` 的**文件名**撞车导致数据被覆盖

---

## 四、修复方案

**把本地合欢宗副本的文件名整体搬到 `83000–83025` 号段，避开东皇的 `30005–30025`。**

### 关键原则

- 只改**文件名**和**内部 `id` 字段**
- **`Skill_ID` 保持不变**（10000–10004）
- **物品 `desc` 保持不变**（10001–10004）
- **`StaticSkillJsonData.json` 的 `Skill_ID = 4001–4007` 不动**（那是静态功法体系）

### 号段映射

| 原文件名 | 新文件名 | 原内部 id | 新内部 id |
|---|---|---|---|
| 30000.json | 83000.json | 30000 | 83000 |
| 30001.json | 83001.json | 30001 | 83001 |
| ... | ... | ... | ... |
| 30025.json | 83025.json | 30025 | 83025 |

---

## 五、实施步骤

### 1. 复制合欢宗到本地独立副本

```bash
SRC="/d/SteamLibrary/steamapps/workshop/content/1189490/2937247049/plugins/Next/mod合欢宗MOD"
DST="/d/SteamLibrary/steamapps/common/觅长生/本地Mod测试/00001/plugins/Next/mod合欢宗MOD"

mkdir -p "/d/SteamLibrary/steamapps/common/觅长生/本地Mod测试/00001/plugins/Next"
rm -rf "$DST"
cp -r "$SRC" "$DST"
2. 改 skillJsonData 文件名 + 内部 id
bash
DST="/d/SteamLibrary/steamapps/common/觅长生/本地Mod测试/00001/plugins/Next/mod合欢宗MOD"
cd "$DST/Data/skillJsonData/"

for f in 30*.json; do
    base="${f%.json}"
    if [ "$base" -ge 30000 ] && [ "$base" -le 30025 ]; then
        new="83${base:2}"
        sed -i "s/\"id\": ${base}/\"id\": ${new}/" "$f"
        mv "$f" "${new}.json"
    fi
done
3. 改 SkillSeidJsonData 引用
bash
DST="/d/SteamLibrary/steamapps/common/觅长生/本地Mod测试/00001/plugins/Next/mod合欢宗MOD"
cd "$DST/Data/SkillSeidJsonData/"

for f in *.json; do
    for old in 30000 30001 30002 30003 30004 30005 30006 30007 30008 30009 \
               30011 30012 30013 30014 30015 30016 30017 30018 30019 30020 \
               30021 30022 30023 30024 30025; do
        new="83${old:2}"
        sed -i "s/\"${old}\"/\"${new}\"/g" "$f"
        sed -i "s/\"skillid\": ${old}/\"skillid\": ${new}/g" "$f"
    done
done
4. 禁用 Workshop 原版合欢宗
关键：Next 只识别以 mod 开头的目录，改名时必须去掉 mod 前缀，仅加 .disabled 后缀无效。

bash
SRC="/d/SteamLibrary/steamapps/workshop/content/1189490/2937247049/plugins/Next/mod合欢宗MOD"
mv "$SRC" "${SRC%mod合欢宗MOD}合欢宗MOD_workshop_backup"
5. 在 Next 面板启用本地 MOD
这一步是关键——如果之前清理过 nextModSetting.json 里的 00001.mod合欢宗MOD 条目，Next 会认为本地 MOD 未启用，只登记不加载数据。

操作：

游戏内按 F4 打开 Next 面板

展开 ??? [id:00001]

勾选 mod合欢宗MOD

点右下角"应用"

彻底关闭游戏

重新启动

6. 备份
bash
cd "/d/SteamLibrary/steamapps/common/觅长生"
tar -czf 本地合欢宗备份-2026-10-07.tar.gz 本地Mod测试/00001/plugins/Next/mod合欢宗MOD/
六、验证结果
重启游戏后，日志输出：

text
[Info : Next] Load mod : ...本地Mod测试\00001\plugins\Next\mod合欢宗MOD
[Info : Next]     Load skillJsonData/83000.json [83000]
[Info : Next]     Load skillJsonData/83001.json [83001]
...
[Info : Next]     Load skillJsonData/83025.json [83025]
[Info : Next]     Load ItemJsonData/39999.json [39999]
[Info : Next]     Load ItemJsonData/40000.json [40000]
[Info : Next]     Load ItemJsonData/40001.json [40001]
[Info : Next]     Load ItemJsonData/40002.json [40002]
[Info : Next]     Load ItemJsonData/40011.json [40011]
[Info : Console] 初始化任务4 数据粗略查错 完成 2026/10/7 2:23:52
无报错，游戏正常进入。

七、注意事项
不要做的事
❌ 不要把 desc = 10001–10004 改成 4001–4007（错误的数据体系混淆）

❌ 不要改 skillJsonData 的 Skill_ID（10000–10004 是正确值）

❌ 不要改 StaticSkillJsonData.json 的 Skill_ID = 4001–4007

❌ 不要只把 Workshop 目录改名加 .disabled 后缀（仍以 mod 开头会被加载）

❌ 不要在 Next 面板勾选本地 MOD 后忘记点"应用"

以后作者更新合欢宗时的流程
重新订阅 2937247049

把新版 Data/ 覆盖到本地副本

重新执行改名脚本（30000–30025 → 83000–83025）

把 Workshop 目录改名成不以 mod 开头

在 Next 面板确认本地 MOD 已勾选

启动验证

八、附录
相关文件路径
文件	路径
本地合欢宗	D:\...\觅长生\本地Mod测试\00001\plugins\Next\mod合欢宗MOD\
备份	D:\...\觅长生\本地合欢宗备份-2026-10-07.tar.gz
Next 配置	D:\...\觅长生\nextModSetting.json
BepInEx 日志	D:\...\workshop\content\1189490\2824349934\BepInEx\LogOutput.log
关键数据对照
text
物品表 40000《魅惑》     desc = 10003 → Skill_ID 10003（魅惑1–5）
物品表 40001《解欲》     desc = 10002 → Skill_ID 10002（解欲1–5）
物品表 40002《粹阳》     desc = 10001 → Skill_ID 10001（粹阳1–5）
物品表 40011《大迷魂术》 desc = 10004 → Skill_ID 10004（大迷魂术1–5）
物品表 39999《一包合欢宗功法》 CrateAvatarSeidJsonData/10.json → 展开为 40000–40011

静态功法（StaticSkillJsonData）：
  Skill_ID 4001 = 媚术
  Skill_ID 4002 = 轻歌
  Skill_ID 4003 = 曼舞
  Skill_ID 4004 = 媚身驱欲法
  Skill_ID 4005 = 迷心决
  Skill_ID 4006 = 天香之舞
  Skill_ID 4007 = 媚心御剑诀
两套体系不能混淆：Skill_ID 10000–10004（普通神通）≠ Skill_ID 4001–4007（静态功法）。

修复完成，问题关闭。
