import { PromptAction } from '@kit.ArkUI';
import { TopicDataSource } from '../datasource/TopicDataSource';
import { TopicItem } from '../model/Topic';
import { LoadMoreWidget } from '../view/LoadingMoreWidget';
import { TopicViewModel } from '../viewmodel/TopicViewModel';

@Component
export struct TopicPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private viewMode: TopicViewModel = new TopicViewModel();
  private dataSource: TopicDataSource = new TopicDataSource([]);
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
        const listItems: TopicItem[] = await this.viewMode.loadData();
        this.dataSource.setData(listItems);
      } else {
        // 加载更多：只在列表末尾追加新数据
        if (!this.viewMode.hasMoreData()) {
          return;
        }
        const itemList: TopicItem[] = await this.viewMode.loadData();
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
      LazyForEach(this.dataSource, (item: TopicItem, index: number) => {
        ListItem() {
          this.TopicItemWidget(item)
        }
        .width('100%')
      }, (_item: TopicItem, index: number) => `topic-key-${index}`);

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
  private TopicItemWidget(item: TopicItem) {
    Column() {
      Image(item.data.image)
        .width('100%')
        .height(200)
        .borderRadius(4)
        .objectFit(ImageFit.Cover)
        .padding({
          left: 10,
          top: 10,
          right: 10,
          bottom: 10
        })

      Divider()
        .width('100%')
        .margin({ left: 10, right: 10 })
    }
    .width('100%')
  }
}