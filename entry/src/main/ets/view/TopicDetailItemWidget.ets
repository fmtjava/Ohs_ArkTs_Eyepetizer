import { ItemData } from '../model/Item';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PlayState } from '../common/PlayState';

@Component
export struct TopicDetailItemWidget {
  // 当前视频信息
  itemData?: ItemData;
  // 当前视频的索引位置
  videoInfoPosition: number = 0;
  // 视频控制器
  private videoController: VideoController = new VideoController();
  // 播放器状态
  @State playState: PlayState = PlayState.STOP;
  // 当前播放视频的 videoIndex
  @Link @Watch('handlePageShow') videoIndex: number;
  // 用于控制标识视频播放器是否显示
  @Link @Watch('handlePageShow') isShowVideoView: boolean;

  aboutToDisappear(): void {
    if (this.itemData) {
      this.videoController.stop();
    }
  }

  build() {
    Column() {
      Stack() {
        Video({
          src: this.itemData?.playUrl || '',
          previewUri: this.itemData?.cover?.feed || '',
          controller: this.videoController
        })
          .controls(true)
          .objectFit(ImageFit.Cover)
          .loop(false)
          .borderRadius(4)
          .width('100%')
          .height('100%')
          .onStart(() => {
            this.playState === PlayState.START
            this.videoIndex = this.videoInfoPosition;
          })
          .onPause(() => {
            this.playState === PlayState.PAUSE;
          })
          .onStop(() => {
            this.playState === PlayState.STOP;
          })
          .visibility(this.playState === PlayState.START ? Visibility.Visible : Visibility.Hidden)

        Image(this.itemData?.cover?.feed || '')
          .borderRadius(4)
          .width('100%')
          .height('100%')
          .visibility(this.playState === PlayState.START ? Visibility.Hidden : Visibility.Visible)
          .onClick(() => {
            this.handleOnClick();
          })

        Image($r('app.media.ic_public_play'))
          .height(50)
          .width(50)
          .visibility(this.playState === PlayState.START ? Visibility.Hidden : Visibility.Visible)
          .onClick(() => {
            this.handleOnClick();
          })
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
          // 创建分享控制器
          const controller: systemShare.ShareController = new systemShare.ShareController(shareData);
          // 获取 UIAbilityContext
          const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
          // 显示分享弹窗
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
   * 播放
   */
  play(): void {
    if (this.playState !== PlayState.START) {
      this.playState = PlayState.START;
    }
    this.videoController.start();
  }

  /**
   * 暂停
   */
  pause(): void {
    if (this.playState !== PlayState.PAUSE) {
      this.playState = PlayState.PAUSE;
    }
    this.videoController.pause();
  }

  /**
   * 停止
   */
  stop(): void {
    if (this.playState !== PlayState.STOP) {
      this.playState = PlayState.STOP;
    }
    this.videoController.stop();
  }

  /**
   * 点击处理视频
   */
  handleOnClick(): void {
    if (this.playState === PlayState.START) {
      this.pause();
    } else if (this.playState === PlayState.PAUSE || this.playState === PlayState.STOP) {
      this.videoIndex = this.videoInfoPosition;
      this.play();
    }
  }

  /**
   * 根据videoIndex、isShowVideoView和videoInfoPosition更改播放状态
   */
  handlePageShow(): void {
    // 判断视频界面是否进入前台，同时判断当前视频索引是否为 List 选中的视频，来决定是否播放
    if (this.isShowVideoView === true && this.videoInfoPosition === this.videoIndex) {
      this.play();
    } else {
      this.stop();
    }
  }
}