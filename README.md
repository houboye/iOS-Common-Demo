# iOS-Common-Demo
iOS Common&amp;Demo

> 点击OC进入OC代码初始化界面，点击Swift进入Swift初始化界面。

## Player
AVPlayer是对于AVPlayer的封装

IJKPlayer是对IJKPlayer的封装

- IJKGLView是基于IJKSDL实现的GLView

## Swift
demo自定义初始化方式，测试工具类等。

- value.swift里面是常用的常量。
- function.swift里面是常用的方法。

tools里面是常用工具。

- NavigationAnimator.swift 是导航栏push和pop时候的动画效果优化。
- NavigationHandler.swift 是导航栏手势： 向右滑动超过一半返回上一级，不到一半停留在当前控制器。
- BaseService.swift 实现了一个监听系统事件的服务类，需要监听的话直接继承此类。注意：调用start()方法，并且将Key设置为当前帐号。

## OC
demo自定义初始化方式，测试工具类等。

- Macro 定义了OC开发中常用的宏。

tools里面是常用工具。

- TimerHolder 封装了NSTimer。
- BYDevice可以得到一些设备信息。
- Spelling是拼音转换工具

Categorys 里面是常用的类目。

Addons 实现一些插件，替换需要公共配置的方法和解决一些问题。

- SwizzlingDefine 定义了一个swizzling_exchangeMethod方法。

Views里面是自定义View。

- BYPageView是一个自定义的PageView。
