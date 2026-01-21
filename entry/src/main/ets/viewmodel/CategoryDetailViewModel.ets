import { AxiosResponse } from "@ohos/axios";
import { BASE_URL } from "../api/Apis";
import { get } from "../common/http";
import { Follow } from "../model/Follow";
import { Item } from "../model/Item";

export class CategoryDetailViewModel {
  private nextPageUrl: string | null = null;

  // 检查是否还有更多数据
  hasMoreData(): boolean {
    return this.nextPageUrl !== null && this.nextPageUrl !== '';
  }

  async loadData(categoryId: number): Promise<Item[]> {
    let url = this.nextPageUrl ??
      `${BASE_URL}/v4/categories/videoList?id=${categoryId}&udid=d2807c895f0348a180148c9dfa6f2feeac0781b5&deviceModel=Android`;
    if (this.nextPageUrl !== null) {
      url = `${url}&udid=d2807c895f0348a180148c9dfa6f2feeac0781b5&deviceModel=Android`
    }
    const response: AxiosResponse<string> = await get(url);
    const follow: Follow = JSON.parse(response.data);
    this.nextPageUrl = follow.nextPageUrl;
    return follow.itemList;
  }
}