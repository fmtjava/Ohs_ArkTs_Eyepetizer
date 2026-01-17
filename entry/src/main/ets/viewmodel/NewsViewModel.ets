import { AxiosResponse } from '@ohos/axios';
import { NEWS_URL } from '../api/Apis';
import { get } from '../common/http';
import { News, NewsItem } from '../model/News';

export class NewsViewModel {
  private nextPageUrl: string | null = null;

  // 重置分页状态，用于下拉刷新
  resetPagination(): void {
    this.nextPageUrl = null;
  }

  // 检查是否还有更多数据
  hasMoreData(): boolean {
    return this.nextPageUrl !== null && this.nextPageUrl !== '';
  }

  async loadData(): Promise<NewsItem[]> {
    let url = this.nextPageUrl ?? NEWS_URL;
    if (this.nextPageUrl !== null) {
      url = `${url}&vc=6030000&deviceModel=Android`
    }
    const response: AxiosResponse<string> = await get(url);
    const news: News = JSON.parse(response.data);
    this.nextPageUrl = news.nextPageUrl;
    return news.itemList;
  }
}