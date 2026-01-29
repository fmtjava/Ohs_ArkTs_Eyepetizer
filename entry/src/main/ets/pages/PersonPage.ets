import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct PersonPage {
  private uIContext: UIContext = this.getUIContext();
  @State selectedImageUri: string = '';

  build() {
    Column() {
      Image(this.selectedImageUri === '' ? $rawfile('image/ic_img_avatar.png') : this.selectedImageUri)
        .margin({ top: 45 })
        .width(88)
        .height(88)
        .borderRadius(44)
        .onClick(() => {
          this.selectPhoto();
        })
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

  /**
   *  相册取图
   */
  private async selectPhoto() {
    try {
      // 配置选择选项
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1; // 最多选择 1 张

      // 创建图库选择器实例
      const photoPicker = new photoAccessHelper.PhotoViewPicker();

      // 打开相册并获取选中结果
      const photoSelectResult = await photoPicker.select(photoSelectOptions);

      // 获取第一张选中图片的 URI
      if (photoSelectResult.photoUris.length > 0) {
        this.selectedImageUri = photoSelectResult.photoUris[0];
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`选择图片失败: ${err.code}, ${err.message}`);
    }
  }
}