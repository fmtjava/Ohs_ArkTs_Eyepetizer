import { AxiosResponse } from '@ohos/axios';
import { INTELLIGENT_IMAGE_SYNTHESIS_URL } from '../api/Apis';
import { AliYunQueryTaskResponse } from '../model/AliYunQueryTaskResponse';
import { AliYunSubmitTaskResponse } from '../model/AliYunSubmitTaskResponse';
import { get, post } from './http';

enum TaskStatus {
  PENDING = 'PENDING',
  RUNNING = 'RUNNING',
  SUCCEEDED = 'SUCCEEDED',
  FAILED = 'FAILED',
  CANCELED = 'CANCELED',
  UNKNOWN = 'UNKNOWN'
}

/**
 * 轮询任务结果
 */
export interface PollResult<T> {
  success: boolean; // 是否成功
  taskId: string; // 任务ID
  data?: T; // 任务结果数据
  error?: string; // 错误信息
}

export class TaskPollingUtil {
  // 简单任务记录（仅存储任务ID和时间戳）
  private static activeTasks: Map<string, number> = new Map();

  static async submitAndPoll<Param, Data>(
    executeUrl: string,
    queryUrl: string,
    executeParams: object,
    executeHeaders?: Record<string, string>,
    queryHeaders?: Record<string, string>,
    pollInterval: number = 3000
  ): Promise<PollResult<Data>> {
    // 1、生成唯一任务ID（时间戳+随机数）
    const submitTaskId = `task_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    // 2、记录任务开始时间
    TaskPollingUtil.activeTasks.set(submitTaskId, Date.now());

    try {
      // 3、提交任务获取taskId
      const response: AxiosResponse<string> =
        await post<Param>(executeUrl, executeParams as Param, executeHeaders);
      const submitTaskResponse: AliYunSubmitTaskResponse = JSON.parse(response.data);

      const realTaskId = submitTaskResponse.output.task_id;

      if (!realTaskId) {
        TaskPollingUtil.activeTasks.delete(submitTaskId);
        throw new Error("任务提交失败: 未获取到taskId");
      }

      // 2. 轮询任务状态
      while (true) {
        // 检查任务是否已被取消（通过时间戳判断）
        const startTime = TaskPollingUtil.activeTasks.get(submitTaskId);
        if (!startTime || Date.now() - startTime > 3600000) {
          throw new Error("任务已取消或超时");
        }
        // 构建查询URL（替换{taskId}占位符）
        const actualQueryUrl = queryUrl.replace('{task_id}', realTaskId);

        // 发送查询请求
        const queryResponse: AxiosResponse<string> = await get(actualQueryUrl, queryHeaders);
        const queryTaskResponse: AliYunQueryTaskResponse = JSON.parse(queryResponse.data);

        // 任务完成
        if (queryTaskResponse.output.task_status === TaskStatus.SUCCEEDED) {
          TaskPollingUtil.activeTasks.delete(submitTaskId);
          return {
            success: true,
            taskId: realTaskId,
            data: executeUrl === INTELLIGENT_IMAGE_SYNTHESIS_URL ? queryTaskResponse.output.results as Data :
              queryTaskResponse.output.video_url as Data
          };
        }

        // 任务失败
        if (queryTaskResponse.output.task_status === TaskStatus.FAILED) {
          TaskPollingUtil.activeTasks.delete(submitTaskId);
          return {
            success: false,
            taskId: realTaskId,
            error: queryTaskResponse.output.message || "任务执行失败"
          };
        }
        // 任务仍在处理中，继续轮询
        await TaskPollingUtil.delay(pollInterval);
      }
    } catch (error) {
      TaskPollingUtil.activeTasks.delete(submitTaskId);
      // 格式化错误信息
      const errorMsg = error instanceof Error ? error.message : String(error);
      return {
        success: false,
        taskId: "",
        error: errorMsg
      };
    }
  }

  /**
   * 取消所有活跃任务（简单实现）
   */
  static cancelAllTasks() {
    // 简单实现：清空所有任务记录
    TaskPollingUtil.activeTasks.clear();
  }

  /**
   * 延迟执行
   * @param ms 延迟毫秒数
   */
  private static delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}