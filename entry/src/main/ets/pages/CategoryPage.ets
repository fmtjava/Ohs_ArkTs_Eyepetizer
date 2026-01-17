import { Category } from "../model/Category";
import { PromptAction } from "@kit.ArkUI";
import { CategoryViewModel } from "../viewmodel/CategoryViewModel";

@Component
export struct CategoryPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private viewModel: CategoryViewModel = new CategoryViewModel();
  @State categoryList: Category[] = [];
  @State refreshing: boolean = true;

  aboutToAppear(): void {
    this.fetchData();
  }

  async fetchData() {
    try {
      this.categoryList = await this.viewModel.loadData()
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
      this.getGridView()
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
  private getGridView() {
    Grid() {
      ForEach(this.categoryList, (category: Category) => {
        GridItem() {
          Stack() {
            Image(category.bgPicture)
              .width('100%')
              .height(200)
              .borderRadius(4)
              .objectFit(ImageFit.Cover)
            Text(`#${category.name}`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
          }
        }
        .width('100%')
      }, (_item: Category, index: number) => `key-${index}`)
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(5)
    .rowsGap(5)
    .height('100%')
    .margin({ left: 5, right: 5 })
    .padding({ bottom: 80 })
    .scrollBar(BarState.Off)
  }
}