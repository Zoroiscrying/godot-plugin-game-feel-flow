# Game Feel Flow 快速入门

## 安装

1. 下载插件
2. 复制 `addons/game_feel_flow` 到你的项目
3. 在Godot编辑器中启用插件（项目设置 → 插件 → Game Feel Flow → 启用）

## 第一个效果

### 使用GFUtil快捷方式（推荐）

```gdscript
# 轻击效果
GFUtil.hit(target_node, 1.0)

# 震动效果
GFUtil.shake(target_node, 1.0)

# 闪白效果
GFUtil.flash(target_node, Color.WHITE)

# 缩放效果
GFUtil.scale(target_node, 1.0)

# 颜色效果
GFUtil.color(target_node, Color.RED)

# 冻结帧
GFUtil.freeze(0.05)

# 慢动作
GFUtil.slow_motion(1.0, 0.3)
```

### 使用GameFeelFlow全局单例

```gdscript
# 通过名称播放
GameFeelFlow.play("shake", target_node, 1.0)

# 通过组合效果播放
GameFeelFlow.play_combo("hit_light", target_node, 1.0)
```

### 使用GFFPlayer组件

```gdscript
# 在Inspector中配置GFFPlayer
# 添加效果并设置参数
# 然后通过代码播放
$GFFPlayer.play("shake", 1.0)
```

## 自定义参数

```gdscript
# 使用GFFParams
var params = GFFParams.create(2.0, 0.5)
    .with_color("color", Color.RED)
    .with_float("amplitude", 0.2)

GameFeelFlow.play("shake", target_node, params)
```

## 组合效果

```gdscript
# 使用预定义组合
GFUtil.hit(target_node, 1.0)        # 轻击
GFUtil.hit_heavy(target_node, 1.0)  # 重击
GFUtil.death(target_node, 1.0)      # 死亡
GFUtil.pickup(target_node, 1.0)     # 拾取
GFUtil.explosion(target_node, 1.0)  # 爆炸
```

## 示例场景

在Godot编辑器中打开以下场景查看效果：

- `addons/game_feel_flow/examples/main_3d.tscn` - 3D效果演示
- `addons/game_feel_flow/examples/main_2d.tscn` - 2D效果演示
- `addons/game_feel_flow/examples/main_ui.tscn` - UI效果演示
- `addons/game_feel_flow/examples/demo_effects.tscn` - 效果演示
- `addons/game_feel_flow/examples/demo_game.tscn` - 游戏场景演示
- `addons/game_feel_flow/examples/demo_inspector.tscn` - 调参界面

## 下一步

- 查看 [API文档](API.md) 了解完整API
- 查看 [示例代码](examples/) 了解更多用法
- 在 [GitHub](https://github.com/your-username/godot-plugin-game-feel-flow) 提交问题和建议
