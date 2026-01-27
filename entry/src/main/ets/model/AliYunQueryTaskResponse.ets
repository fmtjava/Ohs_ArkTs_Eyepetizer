export interface AliYunQueryTaskResponse {
  request_id: string
  output: Output
}

export interface Output {
  task_id: string
  task_status: string
  results?: QueryResult[]
  video_url?: string
  code?: string
  message?: string
}

export interface QueryResult {
  url: string
}

