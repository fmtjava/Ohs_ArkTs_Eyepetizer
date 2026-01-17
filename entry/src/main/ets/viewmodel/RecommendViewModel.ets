import { AxiosResponse } from '@ohos/axios';
import { RECOMMEND_LIST } from '../api/Apis';
import { get } from '../common/http';
import { Recommend, RecommendItem } from '../model/Recommend';

const HORIZONTAL_SCROLL_CARD: string = "horizontalScrollCard"

export class RecommendViewModel {
  private nextPageUrl: string | null = null;

  // 重置分页状态，用于下拉刷新
  resetPagination(): void {
    this.nextPageUrl = null;
  }

  // 检查是否还有更多数据
  hasMoreData(): boolean {
    return this.nextPageUrl !== null && this.nextPageUrl !== '';
  }

  async loadData(): Promise<RecommendItem[]> {
    const url = this.nextPageUrl ?? RECOMMEND_LIST;
    const response: AxiosResponse<string> = await get(url);
    const recommend: Recommend = JSON.parse(response.data);
    this.nextPageUrl = recommend.nextPageUrl;
    const itemListWithoutScrollCard = recommend.itemList.filter(item => item.type !== HORIZONTAL_SCROLL_CARD)
    return itemListWithoutScrollCard;
  }
}