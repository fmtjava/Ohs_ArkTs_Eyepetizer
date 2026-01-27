export class ImageSynthesisParam {
  public model: string
  public input: ImagePromptInput

  constructor(model: string, input: ImagePromptInput) {
    this.model = model
    this.input = input
  }
}

export class ImagePromptInput {
  public prompt: string

  constructor(prompt: string) {
    this.prompt = prompt
  }
}