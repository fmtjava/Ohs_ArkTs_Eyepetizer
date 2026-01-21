import { Item } from '../model/Item';
import { TopicDetail, TopicItem } from '../model/TopicDetail';
import { TopicDetailViewModel } from '../viewmodel/TopicDetailViewModel';
import { PromptAction } from '@kit.ArkUI';
import { PARAM_TOPIC_ID_KEY } from '../common/Constants';
import { TopicDetailItemWidget } from '../view/TopicDetailItemWidget';
import { hideNavBar, resetNavBar } from '../common/Immersive';

@Entry
@Component
struct TopicDetailPage {
  private viewModel: TopicDetailViewModel = new TopicDetailViewModel();
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private topicId: number = 0
  @State topicDetail: TopicDetail = {} as TopicDetail;
  @State refreshing: boolean = false;
  // 当前播放的视频索引
  @State videoIndex: number = -1;
  // 是否显示视频界面
  @State isShowVideoView: boolean = false;

  onPageShow(): void {
    this.isShowVideoView = true;
    hideNavBar(this.getUIContext().getHostContext());
  }

  onPageHide(): void {
    this.isShowVideoView = false;
    resetNavBar(this.getUIContext().getHostContext());
  }

  aboutToAppear(): void {
    const params = this.uiContext.getRouter().getParams();
    if (params != null) {
      const paramsRecord = (params as Record<string, number>)
      this.topicId = paramsRecord[`${PARAM_TOPIC_ID_KEY}`];
      this.fetchData();
    }
    this.isShowVideoView = true;
  }

  aboutToDisappear(): void {
    this.isShowVideoView = false;
  }

  async fetchData() {
    try {
      const topicDetail = await this.viewModel.getTopicDetail(this.topicId);
      this.topicDetail = topicDetail;
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
      Refresh({ refreshing: this.refreshing, offset: 64, friction: 100 }) {
        List() {
          ListItem() {
            this.TopicDetailHeadWidget()
          }
          .width('100%')

          ForEach(this.topicDetail.itemList, (item: TopicItem, index: number) => {
            ListItem() {
              TopicDetailItemWidget({
                itemData: item.data.content.data,
                videoInfoPosition: index,
                videoIndex: this.videoIndex,
                isShowVideoView: this.isShowVideoView
              })
            }
            .width('100%')
          }, (_item: Item, index: number) => `topic-detail-key-${index}`)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .backgroundColor(Color.White)
      }
      .onRefreshing(() => {
        this.refreshing = true;
        this.fetchData().then(() => {
          this.refreshing = false;
        }).catch(() => {
          this.refreshing = false;
        });
      })
      .width('100%')
      .height('100%')
    }
    .title(this.topicDetail.brief)
    .hideBackButton(false)
    .titleMode(NavigationTitleMode.Mini)
  }

  @Builder
  private TopicDetailHeadWidget() {
    Stack() {
      Column() {
        Image(this.topicDetail.headerImage)
          .width('100%')
          .height(250)
          .objectFit(ImageFit.Cover)
        Text(this.topicDetail.text)
          .fontSize(12)
          .fontColor('#9a9a9a')
          .padding({
            left: 20,
            top: 40,
            right: 20,
            bottom: 10
          })
        Blank()
          .width('100%')
          .height(5)
          .backgroundColor('#1F000000')
      }
      .width('100%')

      Row() {
        Text(this.topicDetail.brief)
          .fontSize(14)
          .fontColor(Color.Black)
          .height(50)
          .backgroundColor(Color.White)
          .margin({
            top: 160,
            bottom: 20,
          })
          .padding({ left: 20, right: 20 })
          .borderWidth(1)
          .borderColor('#F5F5F5')
          .borderRadius(4)
          .width('100%')
      }
      .margin({ left: 20, right: 20 })
    }
    .width('100%')
  }
}