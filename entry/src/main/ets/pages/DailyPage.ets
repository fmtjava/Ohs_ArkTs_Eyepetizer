import { RankItemWidget } from "../view/RankItemWidget"
import { LoadMoreWidget } from "../view/LoadingMoreWidget"
import { PromptAction } from "@kit.ArkUI";
import { SwiperDataSource } from "../datasource/SwiperDataSource";
import { Item, ItemData } from "../model/Item";
import { DailyDataSource } from "../datasource/DailyDataSource";
import { DailyViewModel } from "../viewmodel/DailyViewModel";
import { PARAM_ITEM_DATA_KEY } from "../common/Constants";

const TEXT_HEADER_TYPE: string = "textHeader";

@Preview
@Component
export struct DailyPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private viewModel: DailyViewModel = new DailyViewModel();
  private swiperDataSource: SwiperDataSource = new SwiperDataSource([]);
  @State dailyDataSource: DailyDataSource = new DailyDataSource([]);
  @State refreshing: boolean = true;
  @State loadingMore: boolean = false;

  aboutToAppear(): void {
    this.fetchData(true);
  }

  async fetchData(isRefresh: boolean) {
    try {
      if (isRefresh) {
        // 刷新：重置分页状态并加载第一页（用于轮播）
        this.viewModel.resetPagination();
        const firstPageList: Item[] = await this.viewModel.loadData();
        // 第一页数据用于轮播
        this.swiperDataSource.setData(firstPageList);

        // 列表内容从第二页开始
        const bannerItem: Item = {
          type: 'banner',
          data: {} as ItemData
        }
        let listItems: Item[] = [];

        // 列表从第二页开始
        if (this.viewModel.hasMoreData()) {
          listItems = await this.viewModel.loadData();
        }
        this.dailyDataSource.setData([bannerItem, ...listItems]);
      } else {
        // 加载更多：只在列表末尾追加新数据
        if (!this.viewModel.hasMoreData()) {
          return;
        }
        const itemList: Item[] = await this.viewModel.loadData();
        if (itemList.length > 0) {
          itemList.forEach(item => {
            this.dailyDataSource.pushData(item);
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
    Column() {
      this.TitleBar()
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  private TitleBar() {
    Stack() {
      Text($r('app.string.daily_paper'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)

      Button() {
        SymbolGlyph($r('sys.symbol.AI_search'))
          .fontSize(24)
          .fontColor([Color.Black])
          .fontWeight(FontWeight.Medium)
      }
      .backgroundColor(Color.Transparent)
      .type(ButtonType.Normal)
      .width(22)
      .height(22)
      .onClick(() => {

      })
      .position({ top: '50%', right: 15 })
      .translate({ y: '-50%' })
    }
    .width('100%')
    .height(45)
    .shadow({
      radius: 4,
      color: 0x33000000,
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  private SwiperWidget() {
    Swiper() {
      LazyForEach(this.swiperDataSource, (itemInfo: Item) => {
        Image(itemInfo.data.cover?.feed || '')
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            if (itemInfo.data) {
              const params: Record<string, ItemData> = {};
              params[PARAM_ITEM_DATA_KEY] = itemInfo.data;
              this.uiContext.getRouter().pushUrl({
                url: 'pages/VideoDetailPage',
                params: params
              }).catch(() => {
              })
            }
          })
      }, (_itemInfo: Item, index: number) => `swiper-key-${index}`)
    }
    .margin({
      left: 15,
      right: 15,
      top: 15,
      bottom: 15
    })
    .height(200)
    .autoPlay(true)
    .loop(true)
    .vertical(false)
    .indicator(
      new DotIndicator()
        .itemWidth(8)
        .itemHeight(8)
        .selectedItemWidth(8)
        .selectedItemHeight(8)
        .color('#3DFFFFFF')
        .selectedColor(Color.White))
    .borderRadius(4)
  }

  @Builder
  private TitleItemWidget(itemData: ItemData) {
    Row() {
      Text(itemData.text || '')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#DE000000')
    }
    .width('100%')
    .height(30)
    .margin({ bottom: 5 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private getListView() {
    List() {
      LazyForEach(this.dailyDataSource, (item: Item, index: number) => {
        ListItem() {
          if (index === 0) {
            this.SwiperWidget()
          } else if (item.type === TEXT_HEADER_TYPE) {
            this.TitleItemWidget(item.data)
          } else {
            RankItemWidget({ itemData: item.data })
          }
        }
        .width('100%')
      }, (_item: Item, index: number) => `daily-key-${index}`);

      // 加载更多指示器或没有更多数据提示
      if (this.loadingMore || (this.dailyDataSource.totalCount() > 1 && !this.viewModel.hasMoreData())) {
        ListItem() {
          LoadMoreWidget({
            loadingMore: this.loadingMore,
            noMoreData: this.dailyDataSource.totalCount() > 1 && !this.viewModel.hasMoreData(),
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .cachedCount(5)
    .onReachEnd(() => {
      // 上拉加载更多
      if (!this.loadingMore && this.viewModel.hasMoreData()) {
        this.loadingMore = true;
        this.fetchData(false).then(() => {
          this.loadingMore = false;
        }).catch(() => {
          this.loadingMore = false;
        });
      }
    })
  }
}