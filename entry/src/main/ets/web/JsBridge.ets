// 定义一个桥对象，暴露给 H5 调用
export class JsBridge {
  helloFromJs(param: string): string {
    console.log(`ArkTS 收到 JS 参数: ${param}`);
    // 可以在这里做各种 ArkTS 逻辑，比如路由、弹 Toast 等
    return `ArkTS 已收到：${param}`;
  }
}