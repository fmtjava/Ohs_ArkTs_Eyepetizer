export class VideoSynthesisParam {
  public model: string
  public input: VideoPromptInput
  public parameters: VideoParameter

  constructor(model: string, input: VideoPromptInput, parameters: VideoParameter) {
    this.model = model
    this.input = input
    this.parameters = parameters
  }
}

export class VideoPromptInput {
  public prompt: string

  constructor(prompt: string) {
    this.prompt = prompt
  }
}

export class VideoParameter {
  public size: string
  public prompt_extend: boolean
  public duration: number
  public shot_type: string

  constructor(size: string, prompt_extend: boolean, duration: number, shot_type: string) {
    this.size = size
    this.prompt_extend = prompt_extend
    this.duration = duration
    this.shot_type = shot_type
  }
}