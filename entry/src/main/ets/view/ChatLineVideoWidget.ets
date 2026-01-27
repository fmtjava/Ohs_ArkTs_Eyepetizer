import { Message } from "../model/dto/QueryChatParam"

const ASSISTANT_ROLE = 'assistant'

@Component
export struct ChatLineVideoWidget {
  @ObjectLink msg: Message
  private videoController: VideoController = new VideoController();

  aboutToDisappear(): void {
    this.videoController.stop();
  }

  build() {
    if (this.msg.role === ASSISTANT_ROLE) {
      Row() {
        Video({
          previewUri: this.msg.thumbnail,
          src: this.msg.content,
          controller: this.videoController
        })
          .width('100%')
          .height(200)
          .controls(true)
          .autoPlay(false)
          .objectFit(ImageFit.Contain)
          .loop(false)
          .borderRadius(8)
          .backgroundColor(Color.White)
      }
      .constraintSize({ maxWidth: '90%' })
      .padding({
        left: 4,
        top: 4,
        right: 4,
        bottom: 4
      })
    } else {
      Row() {
        Text(this.msg.content)
          .fontSize(20)
          .padding({
            left: 8,
            top: 8,
            right: 8,
            bottom: 8
          })
          .backgroundColor('#96EF6B')
          .borderRadius(8)
          .constraintSize({ maxWidth: '90%' })
      }
      .width('100%')
      .padding({
        left: 4,
        top: 4,
        right: 4,
        bottom: 4
      })
      .justifyContent(FlexAlign.End)
    }
  }
}