import { Item, ItemData } from "../model/Item";
import { LoadMoreWidget } from "../view/LoadingMoreWidget";
import { PromptAction } from "@kit.ArkUI";
import { FollowDataSource } from "../datasource/FollowDataSource";
import { DateUtil } from "../common/DateUtil";
import { FollowViewModel } from "../viewmodel/FollowViewModel";
import { PARAM_ITEM_DATA_KEY } from "../common/Constants";

@Component
export struct FollowPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private viewMode: FollowViewModel = new FollowViewModel();
  private dataSource: FollowDataSource = new FollowDataSource([]);
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
        const listItems: Item[] = await this.viewMode.loadData();
        this.dataSource.setData(listItems);
      } else {
        // 加载更多：只在列表末尾追加新数据
        if (!this.viewMode.hasMoreData()) {
          return;
        }
        const itemList: Item[] = await this.viewMode.loadData();
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
    List() {
      LazyForEach(this.dataSource, (item: Item, index: number) => {
        ListItem() {
          this.FollowItemWidget(item, index)
        }
        .width('100%')
      }, (_item: Item, index: number) => `follow-key-${index}`);

      // 加载更多指示器或没有更多数据提示
      if (this.loadingMore || (this.dataSource.totalCount() > 1 && !this.viewMode.hasMoreData())) {
        ListItem() {
          LoadMoreWidget({
            loadingMore: this.loadingMore,
            noMoreData: this.dataSource.totalCount() > 1 && !this.viewMode.hasMoreData(),
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
  private FollowItemWidget(item: Item, position: number) {
    Column() {
      Row() {
        Image(item.data.header?.icon || '')
          .width(40)
          .height(40)
          .borderRadius(20)
          .objectFit(ImageFit.Cover)
        Column() {
          Text(item.data.header?.title || '')
            .fontColor(Color.Black)
            .fontSize(14)
          Text(item.data.header?.description || '')
            .fontColor('#424242')
            .fontSize(14)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 3 })
        }
        .margin({ left: 10 })
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text($r('app.string.add_follow'))
          .fontSize(12)
          .fontColor(Color.Gray)
          .backgroundColor('#F4F4F4')
          .padding({
            left: 5,
            top: 5,
            right: 5,
            bottom: 5
          })
          .borderRadius(5)
          .margin({ right: 10 })
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (item.data.itemList !== null && item.data.itemList !== undefined && item.data.itemList.length > 0) {
        List() {
          ForEach(item.data.itemList, (item: Item, index: number) => {
            this.FollowHorizontalItemWidget(item)
          }, (_item: Item, index: number) => `follow-horizontal-key-${position}-${index}`)
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(220)
      }

      Divider()
        .width('100%')
        .margin({ top: 15 })
    }
    .margin({ left: 15, bottom: 10 })
  }

  @Builder
  private FollowHorizontalItemWidget(item: Item) {
    Column() {
      Stack() {
        Image(item.data.cover?.feed || '')
          .width('100%')
          .height('100%')
          .borderRadius(4)
          .objectFit(ImageFit.Cover)

        Text(item.data.category || '')
          .fontSize(13)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#8AFFFFFF')
          .borderRadius(5)
          .padding({
            left: 6,
            top: 6,
            right: 6,
            bottom: 6
          })
          .position({ top: 8, right: 8 })
      }
      .width(300)
      .height(180)
      .onClick(() => {
        if (item.data) {
          const params: Record<string, ItemData> = {};
          params[PARAM_ITEM_DATA_KEY] = item.data;
          this.uiContext.getRouter().pushUrl({
            url: 'pages/VideoDetailPage',
            params: params
          }).catch(() => {
          })
        }
      })

      Text(item.data.title || '')
        .fontSize(14)
        .maxLines(1)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor(Color.Black)

      Text(DateUtil.formatTimestamp(item.data.author?.latestReleaseTime || 0))
        .fontSize(12)
        .margin({ top: 3 })
        .fontColor('#424242')
    }
    .margin({ right: 15 })
    .alignItems(HorizontalAlign.Start)
  }
}