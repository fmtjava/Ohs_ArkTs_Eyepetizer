@Component
export struct LoadMoreWidget {
  @Prop loadingMore: boolean = false
  @Prop noMoreData: boolean = false
  // 可选的样式配置
  loadingColor: ResourceColor = '#999999'
  noMoreDataColor: ResourceColor = '#CCCCCC'
  loadingHeight: number = 60
  noMoreDataHeight: number = 50

  build() {
    // 根据状态直接渲染对应组件，避免不必要的 Stack
    // 注意：调用方应确保 loadingMore 或 noMoreData 至少一个为 true
    if (this.loadingMore) {
      this.LoadingMoreIndicator()
    } else {
      this.NoMoreDataIndicator()
    }
  }

  @Builder
  private LoadingMoreIndicator() {
    Row() {
      LoadingProgress()
        .width(24)
        .height(24)
        .color(this.loadingColor)
      Text($r('app.string.loading'))
        .fontSize(14)
        .fontColor(this.loadingColor)
        .margin({ left: 8 })
    }
    .width('100%')
    .height(this.loadingHeight)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private NoMoreDataIndicator() {
    Row() {
      Text($r('app.string.no_more_data'))
        .fontSize(14)
        .fontColor(this.noMoreDataColor)
    }
    .width('100%')
    .height(this.noMoreDataHeight)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
}