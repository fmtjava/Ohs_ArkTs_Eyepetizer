import { PromptAction } from "@kit.ArkUI";
import { Tab } from "../model/TabListInfo";
import { HotViewModel } from "../viewmodel/HotViewModel";
import { HotTabListPage } from "./HotTabListPage";

@Preview
@Component
export struct HotPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private viewMode: HotViewModel = new HotViewModel();
  @State currentIndex: number = 0;
  @State tabInfoList: Tab[] = []

  aboutToAppear(): void {
    this.fetchTabData();
  }

  async fetchTabData() {
    try {
      this.tabInfoList = await this.viewMode.loadTabData()
    } catch (error) {
      const message: string = error?.message || String(error) || '未知错误';
      this.promptAction.openToast({
        message: message
      }).catch(() => {
      })
    }
  }

  build() {
    Column() {
      this.TitleBar()
      Tabs({ barPosition: BarPosition.Start }) {
        ForEach(this.tabInfoList, (tabInfo: Tab, index: number) => {
          TabContent() {
            HotTabListPage({ tab: tabInfo })
          }.tabBar(this.TabBuilder(tabInfo.name, index))
        }, (_tabInfo: Tab, index: number) => `tab-key-${index}`)
      }
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  private TitleBar() {
    Stack() {
      Text($r('app.string.hot'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(45)
  }

  @Builder
  private TabBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(this.currentIndex === index ? '#000000' : '#9a9a9a')
        .fontSize(18)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
      Divider()
        .strokeWidth(2)
        .color($r('sys.color.black'))
        .visibility(this.currentIndex === index ? Visibility.Visible : Visibility.Hidden)
        .margin({ top: 5 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}