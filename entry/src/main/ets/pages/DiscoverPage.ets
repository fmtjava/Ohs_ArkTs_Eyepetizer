import { CategoryPage } from "./CategoryPage";
import { FollowPage } from "./FollowPage";
import { NewsPage } from "./NewsPage";
import { RecommendPage } from "./RecommendPage";
import { TopicPage } from "./TopicPage";

@Component
export struct DiscoverPage {
  @State currentIndex: number = 0;
  private tabInfoList: Array<Resource> =
    [$r('app.string.follow'), $r('app.string.category'), $r('app.string.topic'), $r('app.string.news'),
      $r('app.string.recommend')];

  build() {
    Column() {
      this.TitleBar()
      Tabs({ barPosition: BarPosition.Start }) {
        ForEach(this.tabInfoList, (tabResource: Resource, index: number) => {
          TabContent() {
            if (index === 0) {
              FollowPage()
            } else if (index === 1) {
              CategoryPage()
            } else if (index === 2) {
              TopicPage()
            } else if (index === 3) {
              NewsPage()
            } else {
              RecommendPage()
            }
          }.tabBar(this.TabBuilder(tabResource, index))
        })
      }
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private TitleBar() {
    Stack() {
      Text($r('app.string.discover'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(45)
  }

  @Builder
  private TabBuilder(titleRes: Resource, index: number) {
    Column() {
      Text(titleRes)
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