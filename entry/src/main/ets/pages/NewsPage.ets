import { PromptAction } from '@kit.ArkUI';
import { PARAM_WEB_TITLE_KEY, PARAM_WEB_URL_KEY } from '../common/Constants';
import { NewsDataSource } from '../datasource/NewsDataSource';
import { NewsItem } from '../model/News';
import { LoadMoreWidget } from '../view/LoadingMoreWidget';
import { NewsViewModel } from '../viewmodel/NewsViewModel';

const TEXT_CARD: string = "textCard"

@Component
export struct NewsPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private viewMode: NewsViewModel = new NewsViewModel();
  private dataSource: NewsDataSource = new NewsDataSource([]);
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
        const listItems: NewsItem[] = await this.viewMode.loadData();
        this.dataSource.setData(listItems);
      } else {
        // 加载更多：只在列表末尾追加新数据
        if (!this.viewMode.hasMoreData()) {
          return;
        }
        const itemList: NewsItem[] = await this.viewMode.loadData();
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
      LazyForEach(this.dataSource, (item: NewsItem, index: number) => {
        ListItem() {
          this.NewsItemWidget(item, index)
        }
        .width('100%')
        .align(Alignment.Start)
      }, (_item: NewsItem, index: number) => `topic-key-${index}`);

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
  private NewsItemWidget(newsItem: NewsItem, position: number) {
    if (newsItem.type === TEXT_CARD) {
      Text(newsItem.data.text)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .margin({ left: 10, top: 5 })
    } else {
      Column() {
        Image(newsItem.data.backgroundImage)
          .width('100%')
          .height(140)
          .objectFit(ImageFit.Cover)

        if (newsItem.data.titleList && newsItem.data.titleList.length > 0) {
          ForEach(newsItem.data.titleList, (title: string) => {
            Text(title)
              .fontSize(12)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({
                left: 10,
                top: 5,
                right: 10,
                bottom: 5
              })
          }, (_item: string, index: number) => `news-${position}-${index}`)
        }
      }
      .backgroundColor('#EDEDED')
      .borderRadius(4)
      .alignItems(HorizontalAlign.Start)
      .margin({
        left: 10,
        top: 10,
        right: 10,
        bottom: 10
      })
      .padding({ bottom: 5 })
      .shadow({
        radius: 4,
        color: 0x33000000,
        offsetX: 0,
        offsetY: 4
      })
      .onClick(() => {
        const params: Record<string, string> = {};
        const actionUrl = newsItem.data.actionUrl || '';

        // 正确解析 URL 参数
        let webUrl = '';
        if (actionUrl.includes('url=')) {
          const urlIndex = actionUrl.indexOf('url=');
          const urlValue = actionUrl.substring(urlIndex + 4); // 'url=' 长度为 4
          // 提取 URL 值（可能包含 & 或其他参数，需要截取到下一个 & 或字符串末尾）
          const endIndex = urlValue.indexOf('&');
          webUrl = endIndex > 0 ? urlValue.substring(0, endIndex) : urlValue;
          webUrl = decodeURIComponent(webUrl);
        } else if (actionUrl.startsWith('http://') || actionUrl.startsWith('https://')) {
          // 如果 actionUrl 本身就是完整的 URL
          webUrl = actionUrl;
        }

        params[PARAM_WEB_URL_KEY] = webUrl;
        params[PARAM_WEB_TITLE_KEY] = newsItem.data.titleList ? newsItem.data.titleList[0] : '';
        this.uiContext.getRouter().pushUrl({
          url: 'pages/NewsDetailPage',
          params: params
        }).catch((error: Error) => {
          const message: string = error?.message || String(error) || '未知错误';
          this.promptAction.openToast({
            message: message
          }).catch(() => {
          })
        })
      })
    }
  }
}