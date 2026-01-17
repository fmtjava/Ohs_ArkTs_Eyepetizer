import { AxiosResponse } from "@ohos/axios";
import { Daily_URL } from "../api/Apis";
import { get } from "../common/http";
import { Daily } from "../model/Daily";
import { Item } from "../model/Item";

export class DailyViewModel {
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
    const url = this.nextPageUrl ?? Daily_URL;
    const response: AxiosResponse<string> = await get(url);
    const daily: Daily = JSON.parse(response.data);
    this.nextPageUrl = daily.nextPageUrl;
    const itemList = daily.issueList[0].itemList;
    const itemListWithoutBanner = itemList.filter(item => item.type !== "banner2")
    return itemListWithoutBanner
  }
}