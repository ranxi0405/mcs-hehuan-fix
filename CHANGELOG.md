# 变更记录

## 2026-10-07

### 完成

- 定位冲突根因：合欢宗与东皇的功法数据库Mod 的 `skillJsonData` **文件名撞车**
- 本地化合欢宗 MOD，独立于 Steam Workshop
- 把本地合欢宗的 `skillJsonData` 从 `30000–30025` 迁移到 `83000–83025`
- 同步修改 `SkillSeidJsonData` 里的引用
- 禁用 Workshop 原版合欢宗（改名 `合欢宗MOD_workshop_backup`，不以 `mod` 开头）
- 在 Next 面板勾选本地 MOD 并应用
- 验证：游戏启动无报错，25 个技能 + 5 个物品正常加载

### 排除的错误方向

- ❌ MOD 的 JSON 数据错误（数据本身正确）
- ❌ Next 0.9.1 的 `CoverMainData → ResetYSDictionary` 覆盖逻辑
- ❌ Skill_ID 号段撞车（两边 Skill_ID 不同）
- ❌ 自由世界拓展系列（先怀疑后排除）
- ❌ 东皇 MOD 是冲突源（是，但机制是文件名撞车，不是 ID 撞车）

### 最终状态

| 项目 | 状态 |
|---|---|
| 本地合欢宗副本 | ✅ 独立运行，`83000–83025` |
| Workshop 原版合欢宗 | 已改名，不加载 |
| 东皇的功法数据库Mod | ✅ 正常加载，共存 |
| 自由世界拓展系列 | ✅ 正常加载 |
| 四条报错 | ✅ 消失 |
