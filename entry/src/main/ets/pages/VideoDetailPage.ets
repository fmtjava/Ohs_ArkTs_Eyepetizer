import { PARAM_ITEM_DATA_KEY } from '../common/Constants';
import display from '@ohos.display';
import { Item, ItemData } from '../model/Item';
import { DateUtil } from '../common/DateUtil';
import { VideoDetailViewModel } from '../viewmodel/VideoDetailViewModel';
import { PromptAction } from '@kit.ArkUI';
import { hideNavBar, resetNavBar } from '../common/Immersive';

const VIDEO_SMALL_CARD_TYPE: string = "videoSmallCard";

@Entry
@Component
struct VideoDetailPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private videoController: VideoController = new VideoController();
  private viewMode: VideoDetailViewModel = new VideoDetailViewModel();
  @State itemData: ItemData = {} as ItemData;
  @State screenWidth: number = 0;
  @State screenHeight: number = 0;
  @State itemList: Item[] = []

  onPageShow(): void {
    if (this.itemData) {
      this.videoController.start()
    }
    hideNavBar(this.getUIContext().getHostContext());
  }

  onPageHide(): void {
    if (this.itemData) {
      this.videoController.pause();
    }
    resetNavBar(this.getUIContext().getHostContext());
  }

  async aboutToAppear(): Promise<void> {
    const params = this.uiContext.getRouter().getParams();
    if (params != null) {
      const paramsRecord = (params as Record<string, ItemData>)
      this.itemData = paramsRecord[`${PARAM_ITEM_DATA_KEY}`];
      this.fetchTabData();
      // 异步保存观看记录，不阻塞页面显示
      this.viewMode.saveVideo(this.itemData)
    }
    try {
      const defaultDisplay = display.getDefaultDisplaySync();
      this.screenWidth = defaultDisplay.width;
      this.screenHeight = defaultDisplay.height;
    } catch (error) {
    }
  }

  aboutToDisappear(): void {
    if (this.itemData) {
      this.videoController.stop();
    }
  }

  async fetchTabData() {
    try {
      this.itemList = await this.viewMode.loadRelateVideoData(this.itemData.id)
    } catch (error) {
      const message: string = error?.message || String(error) || '未知错误';
      this.promptAction.openToast({
        message: message
      }).catch(() => {
      })
    }
  }

  build() {
    Navigation() {
      Stack() {
        Image(`${this.itemData.cover?.blurred}/thumbnail/${this.screenHeight}x${this.screenWidth}`)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)

        Column() {
          Video({
            src: this.itemData.playUrl?.toString(),
            previewUri: this.itemData.cover?.feed.toString(),
            controller: this.videoController
          })
            .controls(true)
            .autoPlay(true)
            .objectFit(ImageFit.Contain)
            .loop(false)
            .width('100%')
            .height(200)
          List() {
            ListItem() {
              this.VideoInfoItemWidget()
            }
            .width('100%')

            ForEach(this.itemList, (videoItem: Item) => {
              if (videoItem.type === VIDEO_SMALL_CARD_TYPE) {
                ListItem() {
                  this.VideoRelateItemWidget(videoItem.data)
                }
                .width('100%')
              } else {
                ListItem() {
                  Text(videoItem.data.text || '')
                    .fontColor(Color.White)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .margin({
                      left: 10,
                      top: 10,
                      right: 10,
                      bottom: 10
                    })
                }
                .width('100%')
                .align(Alignment.Start)
              }
            }, (_videoItem: Item, index: number) => `video-item-key-${index}`)
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
        }
      }
    }
    .title(this.itemData.title || '')
    .hideBackButton(false)
    .titleMode(NavigationTitleMode.Mini)
  }

  @Builder
  private VideoInfoItemWidget() {
    Column() {
      Text(this.itemData.title || '')
        .fontColor(Color.White)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 10, top: 10 })
      Text(`${this.itemData.category} / ${DateUtil.formatTimestamp(this.itemData.author?.latestReleaseTime || 0)}`)
        .fontColor(Color.White)
        .fontSize(12)
        .margin({ left: 10, top: 10 })
      Text(this.itemData.description || '')
        .fontColor(Color.White)
        .fontSize(14)
        .margin({ left: 10, top: 10, right: 20 })
      Row() {
        SymbolGlyph($r('sys.symbol.ohos_star'))
          .fontColor([Color.White])
          .fontSize(14)
        Text(`${this.itemData.consumption?.collectionCount}`)
          .fontColor(Color.White)
          .fontSize(14)
          .margin({ left: 3 })
        SymbolGlyph($r('sys.symbol.share'))
          .fontColor([Color.White])
          .fontSize(14)
          .margin({ left: 30 })
        Text(`${this.itemData.consumption?.shareCount}`)
          .fontColor(Color.White)
          .fontSize(14)
          .margin({ left: 3 })
        SymbolGlyph($r('sys.symbol.message'))
          .fontColor([Color.White])
          .fontSize(14)
          .margin({ left: 30 })
        Text(`${this.itemData.consumption?.replyCount}`)
          .fontColor(Color.White)
          .fontSize(14)
          .margin({ left: 3 })
      }
      .margin({ left: 10, top: 10 })

      Divider()
        .width('100%')
        .backgroundColor(Color.White)
        .margin({ top: 10 })

      Row() {
        Image(this.itemData.author?.icon || '')
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({
            left: 10,
            top: 10,
            right: 10,
            bottom: 10
          })
        Column() {
          Text(this.itemData.author?.name || '')
            .fontColor(Color.White)
            .fontSize(15)

          Text(this.itemData.author?.description || '')
            .fontColor(Color.White)
            .fontSize(13)
            .margin({ top: 3 })
        }
        .layoutWeight(1)
        .margin({ top: 10, bottom: 10 })
        .alignItems(HorizontalAlign.Start)

        Text($r('app.string.add_follow'))
          .fontColor(Color.Gray)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(Color.White)
          .fontSize(12)
          .padding({
            left: 5,
            top: 5,
            right: 5,
            bottom: 5
          })
          .borderRadius(5)
          .margin({ left: 10, right: 20 })
      }
      .width('100%')

      Divider()
        .backgroundColor(Color.White)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private VideoRelateItemWidget(item: ItemData) {
    Row() {
      Stack() {
        Image(item.cover?.detail || '')
          .width(135)
          .height(80)
          .objectFit(ImageFit.Cover)
          .borderRadius(5)
        Text(DateUtil.formatDuration((item.duration || 0) * 1000))
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .fontSize(10)
          .borderRadius(5)
          .padding({
            left: 3,
            top: 3,
            right: 3,
            bottom: 3
          })
          .position({ right: 5, bottom: 5 })
      }

      Column() {
        Text(item.title || '')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .fontSize(14)
        Text(`#${item.category} / ${item.author?.name}`)
          .fontColor(Color.White)
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
      .alignItems(HorizontalAlign.Start)
    }
    .margin({
      left: 10,
      top: 10,
      right: 10,
      bottom: 5
    })
    .onClick(() => {
      this.itemData = item;
    })
  }
}