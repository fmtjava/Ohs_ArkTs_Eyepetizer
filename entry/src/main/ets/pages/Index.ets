import { DailyPage } from './DailyPage'
import { DiscoverPage } from './DiscoverPage'
import { HotPage } from './HotPage';
import { PersonPage } from './PersonPage'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        DailyPage()
      }
      .tabBar(this.TabBuilder($r('app.string.daily_paper'), $rawfile('image/home_ic_selected.png'),
        $rawfile('image/home_ic_normal.png'), 0))

      TabContent() {
        DiscoverPage()
      }.tabBar(this.TabBuilder($r('app.string.discover'), $rawfile('image/home_ic_discovery_selected.png'),
        $rawfile('image/home_ic_discovery_normal.png'), 1))

      TabContent() {
        HotPage()
      }.tabBar(this.TabBuilder($r('app.string.hot'), $rawfile('image/home_ic_hot_selected.png'),
        $rawfile('image/home_ic_hot_normal.png'), 2))

      TabContent() {
        PersonPage()
      }.tabBar(this.TabBuilder($r('app.string.mime'), $rawfile('image/home_ic_mine_selected.png'),
        $rawfile('image/home_ic_mine_normal.png'), 3))
    }
    .scrollable(false)
  }

  @Builder
  TabBuilder(titleRes: Resource, selectIconRes: Resource, normalIconRes: Resource, index: number) {
    Column() {
      Image(this.currentIndex === index ? selectIconRes : normalIconRes)
        .width(24)
        .height(24)
      Text(titleRes)
        .fontSize(this.currentIndex === index ? '#000000' : '#9a9a9a')
        .margin({ top: 5 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
    })
  }
}