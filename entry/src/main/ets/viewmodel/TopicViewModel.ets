import { AxiosResponse } from '@ohos/axios';
import { TOPIC_URL } from '../api/Apis';
import { get } from '../common/http';
import { Topic, TopicItem } from '../model/Topic';

export class TopicViewModel {
  private nextPageUrl: string | null = null;

  // 重置分页状态，用于下拉刷新
  resetPagination(): void {
    this.nextPageUrl = null;
  }

  // 检查是否还有更多数据
  hasMoreData(): boolean {
    return this.nextPageUrl !== null && this.nextPageUrl !== '';
  }

  async loadData(): Promise<TopicItem[]> {
    const url = this.nextPageUrl ?? TOPIC_URL;
    const response: AxiosResponse<string> = await get(url);
    const topic: Topic = JSON.parse(response.data);
    this.nextPageUrl = topic.nextPageUrl;
    return topic.itemList;
  }
}