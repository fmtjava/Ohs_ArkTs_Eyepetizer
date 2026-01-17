import { AxiosResponse } from "@ohos/axios";
import { FOLLOW_URL } from "../api/Apis";
import { get } from "../common/http";
import { Follow } from "../model/Follow";
import { Item } from "../model/Item";

export class FollowViewModel {
  private nextPageUrl: string | null = null;

  // 重置分页状态，用于下拉刷新
  resetPagination(): void {
    this.nextPageUrl = null;
  }

  // 检查是否还有更多数据
  hasMoreData(): boolean {
    return this.nextPageUrl !== null && this.nextPageUrl !== '';
  }

  async loadData(): Promise<Item[]> {
    const url = this.nextPageUrl ?? FOLLOW_URL;
    const response: AxiosResponse<string> = await get(url);
    const follow: Follow = JSON.parse(response.data);
    this.nextPageUrl = follow.nextPageUrl;
    return follow.itemList;
  }
}