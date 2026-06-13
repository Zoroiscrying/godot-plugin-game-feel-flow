# Game Feel Flow API 文档

## GameFeelFlow 全局单例

### play(effect, target, params)

播放效果

**参数：**
- `effect`: String | GFFFeedback | GFFCombo - 效果名称或对象
- `target`: Node - 目标节点
- `params`: GFFParams | Dictionary | float - 参数

**示例：**
```gdscript
# 通过名称播放
GameFeelFlow.play("shake", target_node, 1.0)

# 通过效果对象播放
var feedback = GFFShake.new()
GameFeelFlow.play(feedback, target_node, GFFParams.create(2.0))

# 通过组合效果播放
GameFeelFlow.play(GFFCombo.hit_light(), target_node)
```

### play_combo(combo, target, params)

播放组合效果

**参数：**
- `combo`: String | GFFCombo - 组合效果名称或对象
- `target`: Node - 目标节点
- `params`: GFFParams | Dictionary | float - 参数

**示例：**
```gdscript
# 通过名称播放
GameFeelFlow.play_combo("hit_light", target_node, 1.0)

# 通过组合效果对象播放
GameFeelFlow.play_combo(GFFCombo.hit_light(), target_node)
```

### stop(target)

停止目标的所有效果

**参数：**
- `target`: Node - 目标节点

### register_effect(name, effect)

注册效果

**参数：**
- `name`: String - 效果名称
- `effect`: GFFFeedback - 效果对象

### register_combo(name, combo)

注册组合效果

**参数：**
- `name`: String - 组合效果名称
- `combo`: GFFCombo - 组合效果对象

### emit(event, data)

发送事件

**参数：**
- `event`: String - 事件名称
- `data`: Dictionary - 事件数据

### listen(event, callback)

监听事件

**参数：**
- `event`: String - 事件名称
- `callback`: Callable - 回调函数

### unlisten(event, callback)

取消监听

**参数：**
- `event`: String - 事件名称
- `callback`: Callable - 回调函数

### set_debug(enabled)

设置调试模式

**参数：**
- `enabled`: bool - 是否启用

---

## GFFPlayer 播放器

### play(effect, params)

播放效果

**参数：**
- `effect`: String | GFFFeedback | GFFCombo - 效果名称或对象
- `params`: GFFParams | Dictionary | float - 参数

**示例：**
```gdscript
# 通过名称播放
$GFFPlayer.play("shake", 1.0)

# 通过效果对象播放
$GFFPlayer.play(feedback, GFFParams.create(2.0))

# 通过组合效果播放
$GFFPlayer.play(GFFCombo.hit_light())
```

### play_combo(combo, params)

播放组合效果

**参数：**
- `combo`: String | GFFCombo - 组合效果名称或对象
- `params`: GFFParams | Dictionary | float - 参数

### play_all(params)

播放所有效果

**参数：**
- `params`: GFFParams | Dictionary | float - 参数

### stop()

停止所有效果

### stop_effect(effect_name)

停止指定效果

**参数：**
- `effect_name`: String - 效果名称

### is_playing()

是否正在播放

**返回：** bool

### is_effect_playing(effect_name)

指定效果是否正在播放

**参数：**
- `effect_name`: String - 效果名称

**返回：** bool

---

## GFFFeedback 效果基类

### 属性

- `enabled`: bool - 是否启用
- `label`: String - 效果标签
- `priority`: int - 优先级
- `overlap_strategy`: OverlapStrategy - 叠加策略
- `duration`: float - 持续时间
- `delay`: float - 延迟时间
- `cooldown`: float - 冷却时间
- `restore_after_play`: bool - 播放后是否恢复
- `restore_mode`: RestoreMode - 恢复模式

### 信号

- `started` - 效果开始
- `finished` - 效果结束

### 方法

- `apply(target, params)` - 应用效果
- `stop()` - 停止效果
- `is_playing()` - 是否正在播放

---

## GFFParams 参数类

### 静态方法

- `create(intensity, duration)` - 创建参数

### 链式方法

- `with_float(key, value)` - 添加浮点参数
- `with_int(key, value)` - 添加整数参数
- `with_bool(key, value)` - 添加布尔参数
- `with_vector2(key, value)` - 添加Vector2参数
- `with_vector3(key, value)` - 添加Vector3参数
- `with_color(key, value)` - 添加颜色参数
- `with_string(key, value)` - 添加字符串参数
- `with_curve(key, value)` - 添加曲线参数
- `with_node(key, value)` - 添加节点参数
- `with_resource(key, value)` - 添加资源参数
- `with_variant(key, value)` - 添加变体参数

### 获取方法

- `get_float(key, default)` - 获取浮点参数
- `get_int(key, default)` - 获取整数参数
- `get_bool(key, default)` - 获取布尔参数
- `get_vector2(key, default)` - 获取Vector2参数
- `get_vector3(key, default)` - 获取Vector3参数
- `get_color(key, default)` - 获取颜色参数
- `get_string(key, default)` - 获取字符串参数
- `get_curve(key, default)` - 获取曲线参数
- `get_node(key, default)` - 获取节点参数
- `get_resource(key, default)` - 获取资源参数
- `get_variant(key, default)` - 获取变体参数

---

## GFUtil 快捷工具

### 组合效果

- `hit(target, intensity)` - 轻击效果
- `hit_heavy(target, intensity)` - 重击效果
- `death(target, intensity)` - 死亡效果
- `pickup(target, intensity)` - 拾取效果
- `explosion(target, intensity)` - 爆炸效果

### 单一效果

- `shake(target, intensity)` - 震动效果
- `scale(target, intensity)` - 缩放效果
- `flash(target, color)` - 闪白效果
- `color(target, color)` - 颜色效果
- `alpha(target, target_alpha)` - 透明度效果
- `freeze(duration)` - 冻结帧效果
- `slow_motion(duration, scale)` - 慢动作效果

---

## GFFCombo 组合效果

### 静态方法

- `hit_light()` - 轻击组合
- `hit_heavy()` - 重击组合
- `death()` - 死亡组合
- `pickup()` - 拾取组合
- `explosion()` - 爆炸组合

### 属性

- `label`: String - 组合标签
- `effects`: Array[GFFFeedback] - 效果数组
- `default_params`: GFFParams - 默认参数

### 方法

- `execute(target, params)` - 执行组合效果
