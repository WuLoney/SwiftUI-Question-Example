

# ScrollView embedded drag gesture conflict

## 问题：

处理滚动视图内嵌拖动手势，导致的手势

- 在scrollview内部视图添加拖动手势视图中：

1. 同一方向滚动时会导致拖动手势无法响应onEnd回调

2. 倾斜拖动内部视图，会导致内部视图与ScrollView滚动同时响应

3. 假如ScrollView是垂直滚动，内部视图是水平拖动，在内部视图垂直拖动时，ScrollView无法响应滚动

## 解决方案：

- 使用XCode16之前的完美解决方案

内部视图使用 `.simultaneousGesture()` 方法包含一个点击手势`TapGesture`，通过`exclusively(before: DragGesture)`的方式只响应拖动手势，这个在XCode16之前能解决[问题3]。

通过在scrollview与内部拖动手势之间添加一个点击手势，这样可以破坏scrollview与dragGesture之间的响应链，不会导致同时响应


- 使用xcode16之后的解决方案


