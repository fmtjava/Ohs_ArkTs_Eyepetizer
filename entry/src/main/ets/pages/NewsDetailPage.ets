import { webview } from "@kit.ArkWeb"
import { PARAM_WEB_TITLE_KEY, PARAM_WEB_URL_KEY } from "../common/Constants";
import { JsBridge } from "../web/JsBridge";

const DEBUGGING_PORT: number = 8889;

@Entry
@Component
struct NewDetailPage {
  private uiContext: UIContext = this.getUIContext();
  private controller: webview.WebviewController = new webview.WebviewController();
  private jsBridge: JsBridge = new JsBridge();
  @State progress: number = 0
  @State webUrl: string = ''
  @State title: string = ''

  aboutToAppear(): void {
    const params = this.uiContext.getRouter().getParams();
    if (params != null) {
      const paramsRecord = (params as Record<string, string>)
      this.webUrl = paramsRecord[`${PARAM_WEB_URL_KEY}`] || '';
      this.title = paramsRecord[`${PARAM_WEB_TITLE_KEY}`] || '';
    }

    try {
      // 配置Web开启无线调试模式，指定TCP Socket的端口。
      webview.WebviewController.setWebDebuggingAccess(true, DEBUGGING_PORT);
    } catch (error) {
      console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
    }
  }

  build() {
    Navigation() {
      Column() {
        if (this.progress < 100 && this.webUrl) {
          Progress({ value: this.progress, total: 100 })
            .width('100%')
            .height(3)
        }

        Web({ src: this.webUrl, controller: this.controller })
          .javaScriptAccess(true) // 启用 JavaScript，视频播放通常需要
          .javaScriptProxy({
            // 暴露到 JS 里的对象名，例如 window.nativeBridge
            name: 'nativeBridge',
            object: this.jsBridge,
            methodList: [
              'helloFromJs'
            ],
            controller: this.controller
          })
          .fileAccess(true) // 允许文件访问
          .domStorageAccess(true) // 允许 DOM 存储
          .imageAccess(true) // 允许图片访问
          .mixedMode(MixedMode.All) // 允许混合内容（HTTP/HTTPS）
          .mediaPlayGestureAccess(true) // 允许媒体播放手势，支持视频播放
          .onProgressChange((event) => {
            this.progress = event.newProgress;
          })
          .onPageEnd(() => {
            // 执行某段 js 代码
            const jsCode =
              "javascript:(function() {document.getElementsByClassName(\"share-bar-container\")[0].style.display=\'none\';" +
                "document.getElementsByClassName(\"footer-container j-footer-container\")[0].style.display=\'none\';" +
                "document.getElementsByClassName(\"kyt-promotion-bar-positioner\")[0].style.display=\'none\';" +
                "})()";
            this.controller.runJavaScript(jsCode).then(() => {
            }).catch((error: BusinessError) => {
              console.error("error: " + error);
            })
          })
          .verticalScrollBarAccess(false)
          .width('100%')
          .height('100%')
      }
      .width('100%')
      .height('100%')
    }
    .title(this.title)
    .hideBackButton(false)
    .titleMode(NavigationTitleMode.Mini)
  }
}