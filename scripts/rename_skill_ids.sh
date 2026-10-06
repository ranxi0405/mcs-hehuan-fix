#!/bin/bash
# 合欢宗 MOD skillJsonData 文件名迁移脚本
# 把 30000-30025 迁移到 83000-83025，避开东皇的功法数据库Mod
#
# 用法：
#   1. 先把合欢宗复制到 DST 目录
#   2. 执行本脚本
#   3. 在 Next 面板勾选本地 MOD + 应用
#   4. 重启游戏

set -e

DST="${1:-/d/SteamLibrary/steamapps/common/觅长生/本地Mod测试/00001/plugins/Next/mod合欢宗MOD}"

if [ ! -d "$DST/Data/skillJsonData" ]; then
    echo "错误：$DST/Data/skillJsonData 不存在"
    exit 1
fi

echo "=== 1. 改 skillJsonData 文件名 + 内部 id ==="
cd "$DST/Data/skillJsonData/"
for f in 30*.json; do
    [ -f "$f" ] || continue
    base="${f%.json}"
    if [ "$base" -ge 30000 ] && [ "$base" -le 30025 ]; then
        new="83${base:2}"
        sed -i "s/\"id\": ${base}/\"id\": ${new}/" "$f"
        mv "$f" "${new}.json"
        echo "  $f -> ${new}.json"
    fi
done

echo ""
echo "=== 2. 改 SkillSeidJsonData 引用 ==="
cd "$DST/Data/SkillSeidJsonData/"
for f in *.json; do
    [ -f "$f" ] || continue
    for old in 30000 30001 30002 30003 30004 30005 30006 30007 30008 30009 \
               30011 30012 30013 30014 30015 30016 30017 30018 30019 30020 \
               30021 30022 30023 30024 30025; do
        new="83${old:2}"
        sed -i "s/\"${old}\"/\"${new}\"/g" "$f"
        sed -i "s/\"skillid\": ${old}/\"skillid\": ${new}/g" "$f"
    done
    echo "  $f 已更新"
done

echo ""
echo "=== 3. 验证 ==="
echo "skillJsonData 文件："
ls "$DST/Data/skillJsonData/" | head -10
echo "..."
echo ""
echo "检查是否还有 300xx 残留（应为空）："
grep -rn '"skillid":\s*300[0-2][0-9]' "$DST/Data/" 2>/dev/null || echo "  无残留"

echo ""
echo "完成。请在 Next 面板勾选本地 MOD 后应用，再重启游戏。"
