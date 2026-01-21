import { HotTabDataSource } from "../datasource/HotTabDataSource";
import { Tab } from "../model/TabListInfo"
import { PromptAction } from "@kit.ArkUI";
import { Item } from "../model/Item";
import { RankItemWidget } from "../view/RankItemWidget";
import { HotTabViewModel } from "../viewmodel/HotTabViewModel";

@Component
export struct HotTabListPage {
  @Prop tab: Tab
  @State refreshing: boolean = false;
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private viewModel: HotTabViewModel = new HotTabViewModel();
  private dataSource: HotTabDataSource = new HotTabDataSource([]);

  aboutToAppear(): void {
    this.fetchData();
  }

  async fetchData() {
    try {
      const itemList: Item[] = await this.viewModel.loadTabListData(this.tab.apiUrl);
      if (itemList.length > 0) {
        itemList.forEach(item => {
          this.dataSource.pushData(item);
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
    Refresh({ refreshing: this.refreshing, offset: 64, friction: 100 }) {
      this.getListView(this.tab.name)
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

  @Builder
  private getListView(tabName: string) {
    List() {
      LazyForEach(this.dataSource, (item: Item, index: number) => {
        ListItem() {
          RankItemWidget({ itemData: item.data })
        }
        .width('100%')
      }, (_item: Item, index: number) => `${tabName}-key-${index}`);
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .cachedCount(5)
  }
}