export interface ChatResponse {
  code: number
  message: string
  choices: Choice[]
}

export interface Choice {
  message: Message
}

export interface Message {
  role: string
  content: string
}