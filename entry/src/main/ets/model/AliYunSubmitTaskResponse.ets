export interface AliYunSubmitTaskResponse {
  output: AliYunSubmitTaskOutput
  request_id: string
}

export interface AliYunSubmitTaskOutput {
  task_status: string
  task_id: string
}