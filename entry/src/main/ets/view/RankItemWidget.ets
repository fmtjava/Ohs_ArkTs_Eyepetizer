import { ItemData } from "../model/Item"
import { DateUtil } from "../common/DateUtil"
import { PARAM_ITEM_DATA_KEY } from "../common/Constants";
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct RankItemWidget {
  itemData?: ItemData
  private uiContext: UIContext = this.getUIContext();

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(this.itemData?.cover?.feed || '')
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(4)
          .onClick(() => {
            if (this.itemData) {
              const params: Record<string, ItemData> = {};
              params[PARAM_ITEM_DATA_KEY] = this.itemData;
              this.uiContext.getRouter().pushUrl({
                url: 'pages/VideoDetailPage',
                params: params
              }).catch(() => {
              })
            }
          })

        Text(this.itemData?.category || '')
          .width(44)
          .height(44)
          .borderRadius(22)
          .backgroundColor('#8AFFFFFF')
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .position({ x: 15, y: 10 })

        Text(this.getDurationText())
          .backgroundColor('#8A000000')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .padding({
            left: 5,
            top: 5,
            right: 5,
            bottom: 5
          })
          .borderRadius(5)
          .fontSize(14)
          .position({ bottom: 10, right: 10 })
      }
      .width('100%')
      .height(200)

      Row() {
        Image(this.itemData?.author?.icon || '')
          .width(40)
          .height(40)
          .borderRadius(20)
          .objectFit(ImageFit.Cover)
        Column() {
          Text(this.itemData?.title || '')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.itemData?.author?.name || '')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#9a9a9a')
            .maxLines(1)
            .margin({ top: 2 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button() {
          SymbolGlyph($r('sys.symbol.share'))
            .fontSize(24)
            .fontColor(['#8A000000'])
            .fontWeight(FontWeight.Medium)
        }
        .backgroundColor(Color.Transparent)
        .type(ButtonType.Normal)
        .width(40)
        .height(60)
        .onClick(() => {
          // 构造ShareData，需配置一条有效数据信息
          let shareData: systemShare.SharedData = new systemShare.SharedData({
            utd: utd.UniformDataType.HYPERLINK,
            content: this.itemData?.playUrl || '',
            title: this.itemData?.title || '',
            description: this.itemData?.description || '',
          });
          const controller: systemShare.ShareController = new systemShare.ShareController(shareData);
          const context: common.UIAbilityContext = this.uiContext.getHostContext() as common.UIAbilityContext;
          controller.show(context, {
            selectionMode: systemShare.SelectionMode.SINGLE,
            previewMode: systemShare.SharePreviewMode.DEFAULT,
          }).then(() => {
            console.info('ShareController show success.');
          }).catch((error: BusinessError) => {
            console.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
          });
        })
      }
      .width('100%')
      .margin({ top: 10 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .height(60)

      Divider()
        .width('100%')
    }
    .margin({
      left: 15,
      top: 5,
      right: 15,
      bottom: 10
    })
  }

  /**
   * 获取格式化后的时长文本
   * @returns 格式化的时长字符串，如 "03:00"
   */
  private getDurationText(): string {
    if (this.itemData?.duration) {
      return DateUtil.formatDuration(this.itemData.duration * 1000);
    }
    return '00:00';
  }
}