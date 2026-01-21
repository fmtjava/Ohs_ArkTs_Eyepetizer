import { CategoryDetailDataSource } from '../datasource/CategoryDetailDataSource';
import { Item } from '../model/Item';
import { CategoryDetailViewModel } from '../viewmodel/CategoryDetailViewModel';
import { PromptAction } from '@kit.ArkUI';
import { Category } from '../model/Category';
import { PARAM_CATEGORY_DATA_KEY } from '../common/Constants';
import { LoadMoreWidget } from '../view/LoadingMoreWidget';
import { RankItemWidget } from '../view/RankItemWidget';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';

const DEFAULT_header_BG =
  'http://ali-img.kaiyanapp.com/bcf6da5da1363e140ddbd536147f9931.jpeg?imageMogr2/quality/60/format/jpg'

@Entry
@Component
struct CategoryDetailPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private viewModel: CategoryDetailViewModel = new CategoryDetailViewModel();
  private dailyDataSource: CategoryDetailDataSource = new CategoryDetailDataSource([]);
  private category: Category = {} as Category
  @State loadingMore: boolean = false;
  @State alpha: number = 0
  // 原始窗口配置备份
  private originalBarProps: window.SystemBarProperties | null = null;
  // 滚动的偏移量
  private scrollOffset: number = 0;

  onPageShow(): void {
    this.setImmersiveMode()
  }

  onPageHide(): void {
    this.restoreOriginalSettings()
  }

  aboutToAppear(): void {
    const params = this.uiContext.getRouter().getParams();
    if (params !== null) {
      const paramsRecord = (params as Record<string, Category>)
      this.category = paramsRecord[`${PARAM_CATEGORY_DATA_KEY}`];
      this.fetchData();
    }
  }

  /**
   *  设置沉浸式状态栏
   */
  private async setImmersiveMode() {
    // 1. 获取当前窗口
    window.getLastWindow(this.getUIContext().getHostContext(), async (err: BusinessError, win: window.Window) => {
      try {
        if (err.code) {
          console.error(`获取窗口失败：${err.message}`);
          return;
        }
        // 2.备份原始设置
        this.originalBarProps = win.getWindowSystemBarProperties();

        // 3.设置沉浸式
        await win.setWindowLayoutFullScreen(true);
        await win.setWindowSystemBarProperties({
          statusBarColor: '#00000000', // 透明状态栏
          navigationBarColor: '#00000000', // 透明导航栏
          statusBarContentColor: 'light' // 浅色文字（深色背景）
        });
      } catch (error) {
        console.error(`沉浸式模式设置失败: ${(error as BusinessError).code}, ${error.message}`);
      }
    });
  }

  // 恢复原始设置
  private async restoreOriginalSettings() {
    // 1. 获取当前窗口
    window.getLastWindow(this.getUIContext().getHostContext(), async (err: BusinessError, win: window.Window) => {
      try {
        if (err.code) {
          console.error(`获取窗口失败：${err.message}`);
          return;
        }
        // 2.恢复状态栏原始设置
        await win.setWindowLayoutFullScreen(false);
        if (this.originalBarProps) {
          await win.setWindowSystemBarProperties(this.originalBarProps);
        }
      } catch (error) {
        console.error(`状态栏恢复失败: ${(error as BusinessError).code}, ${error.message}`);
      }
    });
  }

  async fetchData() {
    try {
      const itemList: Item[] = await this.viewModel.loadData(this.category.id);
      if (itemList.length > 0) {
        itemList.forEach(item => {
          this.dailyDataSource.pushData(item);
        });
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
    Stack({ alignContent: Alignment.Top }) {
      this.getListView()
      Stack({ alignContent: Alignment.Start }) {
        Row() {
          Blank()
            .width(100)

          Text(this.category.name)
            .fontSize(20)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Bold)
            .opacity(this.alpha)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Blank()
            .width(100)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height('100%')
        .padding({ top: 25 })
        .backgroundColor(Color.White)
        .opacity(this.alpha)

        Stack({ alignContent: Alignment.Start }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(30)
            .fontColor([this.alpha >= 1 ? Color.Black : Color.White])
        }
        .width(100)
        .height('100%')
        .padding({ top: 25, left: 15 })
        .onClick(() => {
          this.uiContext.getRouter().back()
        })
      }
      .width('100%')
      .height(88)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private getListView() {
    List() {
      ListItem() {
        Image(DEFAULT_header_BG)
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .margin({ bottom: 10 })
      }

      LazyForEach(this.dailyDataSource, (item: Item, index: number) => {
        ListItem() {
          RankItemWidget({ itemData: item.data })
        }
        .width('100%')
      }, (_item: Item, index: number) => `category-detail-key-${index}`);

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
        this.fetchData().then(() => {
          this.loadingMore = false;
        }).catch(() => {
          this.loadingMore = false;
        });
      }
    })
    .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
      // 累计计算偏移量(可能 > 0，也可能 < 0)
      this.scrollOffset += scrollOffset;
      this.dispatchScrollOffset();
    })
    .onScrollStop(() => {
      this.dispatchScrollOffset();
    })
  }

  /**
   * 处理滚动事件
   */
  private dispatchScrollOffset() {
    const opacity = this.scrollOffset / 200;
    // 注意这里的边界场景
    this.alpha = opacity > 1 ? 1 : opacity < 0 ? 0 : opacity;
  }
}