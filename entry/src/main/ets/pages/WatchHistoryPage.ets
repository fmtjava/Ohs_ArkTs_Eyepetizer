import { PARAM_ITEM_DATA_KEY } from '../common/Constants';
import { DateUtil } from '../common/DateUtil';
import { ItemData } from '../model/Item';
import { WatchHistoryVideoModel } from '../viewmodel/WatchHistoryVideoModel';

@Entry
@Component
struct WatchHistoryPage {
  private videoViewModel: WatchHistoryVideoModel = new WatchHistoryVideoModel();
  @State itemList: ItemData[] = []

  aboutToAppear(): void {
    this.itemList = this.videoViewModel.getVideoList();
  }

  build() {
    Navigation() {
      List() {
        ForEach(this.itemList, (itemData: ItemData, index: number) => {
          ListItem() {
            this.VideoItemWidget(itemData)
          }
          .width('100%')
          .swipeAction({
            end: this.buildDeleteButton(itemData.id || 0, index)
          })
        }, (itemData: ItemData) => `watch-key-${itemData.id}`)
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
    .title($r('app.string.watch_history'))
    .hideBackButton(false)
    .titleMode(NavigationTitleMode.Mini)
  }

  @Builder
  private buildDeleteButton(videoId: number, index: number) {
    Button() {
      Text($r('app.string.delete'))
        .fontColor(Color.White)
        .fontSize(14)
    }
    .type(ButtonType.Normal)
    .backgroundColor('#FF3B30')
    .width(80)
    .height('100%')
    .onClick(() => {
      // 删除数据库记录
      this.videoViewModel.deleteVideo(videoId);
      // 从列表中移除，使用 filter 创建新数组以触发状态更新
      this.itemList = this.itemList.filter((item: ItemData) => item.id !== videoId);
    })
  }

  @Builder
  private VideoItemWidget(itemData: ItemData) {
    Row() {
      Stack() {
        Image(itemData.cover?.detail || '')
          .width(135)
          .height(80)
          .borderRadius(5)
          .objectFit(ImageFit.Cover)

        Text(DateUtil.formatDuration((itemData.duration || 0) * 1000))
          .fontColor(Color.White)
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .borderWidth(5)
          .backgroundColor('#8A000000')
          .padding({
            left: 3,
            top: 3,
            right: 3,
            bottom: 3
          })
          .position({ right: 5, bottom: 5 })
      }

      Column() {
        Text(itemData.title || '')
          .fontColor('#DE000000')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
        Text(`#${itemData.category} / ${itemData.author?.name}`)
          .fontColor('#424242')
          .fontSize(12)
          .margin({ top: 15 })
      }
      .margin({
        left: 10,
        top: 10,
        right: 10,
        bottom: 10
      })
      .layoutWeight(1)
    }
    .margin({
      left: 10,
      top: 10,
      right: 10,
      bottom: 5
    })
    .onClick(() => {
      const params: Record<string, ItemData> = {};
      params[PARAM_ITEM_DATA_KEY] = itemData;
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/VideoDetailPage',
        params: params
      }).catch(() => {
      })
    })
  }
}