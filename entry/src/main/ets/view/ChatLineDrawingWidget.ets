import { Message } from "../model/dto/QueryChatParam"

const ASSISTANT_ROLE = 'assistant'

@Component
export struct ChatLineDrawingWidget {
  @ObjectLink msg: Message

  build() {
    if (this.msg.role === ASSISTANT_ROLE) {
      Row() {
        Image(this.msg.content)
          .padding({
            left: 4,
            top: 4,
            right: 4,
            bottom: 4
          })
          .constraintSize({ maxWidth: '90%' })
          .borderRadius(8)
          .align(Alignment.BottomEnd)
          .backgroundColor(Color.White)
      }
      .width('100%')
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