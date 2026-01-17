import { PromptAction } from '@kit.ArkUI';
import display from '@ohos.display';
import { RecommendDataSource } from '../datasource/RecommendDataSource';
import { RecommendItem } from '../model/Recommend';
import { TopicItem } from '../model/Topic';
import { LoadMoreWidget } from '../view/LoadingMoreWidget';
import { RecommendViewModel } from '../viewmodel/RecommendViewModel';

const VIDEO_TYPE: string = "video"
const DEFAULT_ASPECT_RATIO: number = 16 / 9;

@Component
export struct RecommendPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private viewMode: RecommendViewModel = new RecommendViewModel();
  private dataSource: RecommendDataSource = new RecommendDataSource([]);
  @State refreshing: boolean = true;
  @State loadingMore: boolean = false;

  aboutToAppear(): void {
    this.fetchData(true);
  }

  async fetchData(isRefresh: boolean) {
    try {
      if (isRefresh) {
        // 刷新：重置分页状态并加载第一页（用于轮播）
        this.viewMode.resetPagination();
        const listItems: RecommendItem[] = await this.viewMode.loadData();
        this.dataSource.setData(listItems);
      } else {
        // 加载更多：只在列表末尾追加新数据
        if (!this.viewMode.hasMoreData()) {
          return;
        }
        const itemList: RecommendItem[] = await this.viewMode.loadData();
        if (itemList.length > 0) {
          itemList.forEach(item => {
            this.dataSource.pushData(item);
          });
        }
      }
    } catch (error) {
      const message: string = error?.message || String(error) || '未知错误';
      this.promptAction.openToast({
        message: message
      }).catch(() => {
      })
    }
  }

  build() {
    Refresh({ refreshing: this.refreshing, offset: 64, friction: 100 }) {
      this.getListView()
    }
    .onRefreshing(() => {
      this.refreshing = true;
      this.fetchData(true).then(() => {
        this.refreshing = false;
      }).catch(() => {
        this.refreshing = false;
      });
    })
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  private getListView() {
    WaterFlow() {
      LazyForEach(this.dataSource, (item: RecommendItem, index: number) => {
        FlowItem() {
          this.RecommendItemWidget(item)
        }
        .width('100%')
      }, (_item: TopicItem, index: number) => `topic-key-${index}`);

      // 加载更多指示器或没有更多数据提示
      // 使用负 margin 让 FlowItem 占据两列（整行）
      // 计算：列间距 10px，需要左右各扩展 5px 来占据列间距，同时需要抵消左右 padding 各 10px
      if (this.loadingMore || (this.dataSource.totalCount() > 1 && !this.viewMode.hasMoreData())) {
        FlowItem() {
          LoadMoreWidget({
            loadingMore: this.loadingMore,
            noMoreData: this.dataSource.totalCount() > 1 && !this.viewMode.hasMoreData(),
          })
        }
        .width('100%')
        .gridSpan(2)
      }
    }
    .columnsTemplate('1fr 1fr') // 设置两列等宽布局
    .columnsGap(10) // 列间距
    .rowsGap(10) // 行间距
    .width('100%')
    .height('100%')
    .padding({ left: 10, right: 10 })
    .scrollBar(BarState.Off)
    .cachedCount(5)
    .onReachEnd(() => {
      // 上拉加载更多
      if (!this.loadingMore && this.viewMode.hasMoreData()) {
        this.loadingMore = true;
        this.fetchData(false).then(() => {
          this.loadingMore = false;
        }).catch(() => {
          this.loadingMore = false;
        });
      }
    })
  }

  @Builder
  private RecommendItemWidget(item: RecommendItem) {
    Column() {
      Stack() {
        Image(item.data.content.data.cover?.feed || '')
          .width('100%')
          .aspectRatio(this.getAspectRatio(item.data.content.data.width || 0, item.data.content.data.height || 0))
          .borderRadius({ topLeft: 4, topRight: 4 })
          .objectFit(ImageFit.Cover)
        if (item.data.content.data.urls !== undefined && item.data.content.data.urls !== null) {
          if (item.data.content.data.urls.length > 0) {
            SymbolGlyph(item.data.content.type === VIDEO_TYPE ? $r('sys.symbol.video') : $r('sys.symbol.ohos_photo'))
              .fontSize(18)
              .fontColor([Color.White])
              .position({ left: 5, top: 5 })
          }
        }
      }

      Text(item.data.content.data.description || '')
        .fontSize(14)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor('#DE000000')
        .margin({
          left: 6,
          top: 10,
          right: 6,
          bottom: 10
        })
      Flex({ justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
        Row() {
          Image(item.data.content.data.owner?.avatar || '')
            .width(24)
            .height(24)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
          Text(item.data.content.data.owner?.nickname || '')
            .fontSize(12)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width(80)
            .margin({ left: 3 })
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        Row() {
          SymbolGlyph($r('sys.symbol.hand_thumbsup'))
            .fontSize(14)
            .fontColor([Color.Gray])
          Text(item.data.content.data.consumption?.collectionCount.toString())
            .fontSize(12)
            .margin({ left: 3 })
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(40) // 设置固定高度，确保垂直居中生效
    }
    .width('100%')
    .backgroundColor(Color.White)
    .shadow({
      radius: 4,
      color: 0x33000000,
      offsetX: 0,
      offsetY: 4
    })
    .borderRadius(5)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 计算图片的宽高比
   * @param imageWidth 图片宽度（px）
   * @param imageHeight 图片高度（px）
   * @returns 宽高比（width / height），如果无法计算则返回默认值
   */
  private getAspectRatio(imageWidth: number, imageHeight: number): number {
    // 如果宽高都有效且大于0，直接计算宽高比
    if (imageWidth > 0 && imageHeight > 0) {
      return imageWidth / imageHeight;
    }

    // 如果宽高无效或为0，返回默认宽高比
    // 可以根据业务需求选择：1.0（正方形）或 16/9（常见视频比例）
    // 这里使用 16/9，因为推荐页通常包含视频内容
    return DEFAULT_ASPECT_RATIO;
  }
}