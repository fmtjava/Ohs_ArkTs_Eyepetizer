export class ImageSynthesisParam {
  public model: string
  public input: PromptInput

  constructor(model: string, input: PromptInput) {
    this.model = model
    this.input = input
  }
}

export class PromptInput {
  public prompt: string

  constructor(prompt: string) {
    this.prompt = prompt
  }
}