export interface AliYunQueryTaskResponse {
  request_id: string
  output: Output
  usage: Usage
}

export interface Output {
  task_id: string
  task_status: string
  results?: QueryResult[]
  task_metrics?: TaskMetrics
  code?: string
  message?: string
}

export interface QueryResult {
  url: string
}

export interface TaskMetrics {
  TOTAL: number
  SUCCEEDED: number
  FAILED: number
}

export interface Usage {
  image_count: number
}
