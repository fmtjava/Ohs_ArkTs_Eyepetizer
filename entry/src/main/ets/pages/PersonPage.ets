@Component
export struct PersonPage {
  private uIContext: UIContext = this.getUIContext();

  build() {
    Column() {
      Image($rawfile('image/ic_img_avatar.png'))
        .margin({ top: 45 })
        .width(88)
        .height(88)
        .borderRadius(44)
      Text('fmtjava')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .margin({ top: 20 })
      Text('查看个人主页 >')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#424242')
        .margin({ top: 10 })
      Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
        Row() {
          Image($rawfile('image/icon_like_grey.png'))
            .width(20)
            .height(20)
          Text($r('app.string.collect'))
            .fontSize(14)
            .fontColor(Color.Gray)
        }

        Divider()
          .width(0.5)
          .height(40)
          .vertical(false)
          .background(Color.Gray)

        Row() {
          Image($rawfile('image/icon_comment_grey.png'))
            .width(20)
            .height(20)
          Text($r('app.string.comment'))
            .fontSize(14)
            .fontColor(Color.Gray)
        }
      }
      .margin({ top: 20, bottom: 20 })

      Text($r('app.string.my_message'))
        .fontSize(16)
        .padding({ top: 15, bottom: 15 })
        .fontColor('#DE000000')

      Text($r('app.string.my_record'))
        .fontSize(16)
        .padding({ top: 15, bottom: 15 })
        .fontColor('#DE000000')

      Text($r('app.string.my_cache'))
        .fontSize(16)
        .padding({ top: 15, bottom: 15 })
        .fontColor('#DE000000')

      Text($r('app.string.watch_history'))
        .fontSize(16)
        .padding({ top: 15, bottom: 15 })
        .fontColor('#DE000000')
        .onClick(() => {
          this.uIContext.getRouter().pushUrl({
            url: 'pages/WatchHistoryPage'
          }).catch(() => {

          })
        })

      Text($r('app.string.feedback'))
        .width('100%')
        .fontSize(16)
        .padding({ top: 15, bottom: 15 })
        .fontColor('#DE000000')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}