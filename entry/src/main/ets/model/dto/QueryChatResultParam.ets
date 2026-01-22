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

export class Message {
  public  role: string
  public content: string

  constructor(role: string, content: string) {
    this.role = role
    this.content = content
  }
}