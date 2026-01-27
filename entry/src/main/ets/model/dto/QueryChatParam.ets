import { image } from "@kit.ImageKit"

export class QueryChatResultParam {
  public model: string
  public user: string
  public messages: Message[]

  constructor(model: string, user: string, messages: Message[]) {
    this.model = model
    this.user = user
    this.messages = messages
  }
}

@Observed
export class Message {
  public  role: string
  public content: string
  public thumbnail?: image.PixelMap

  constructor(role: string, content: string, thumbnail?: image.PixelMap) {
    this.role = role
    this.content = content
    this.thumbnail = thumbnail
  }

}