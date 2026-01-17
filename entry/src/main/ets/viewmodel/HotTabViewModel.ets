import { AxiosResponse } from "@ohos/axios";
import { HOT_TAB_URL } from "../api/Apis";
import { get } from "../common/http";
import { Issue } from "../model/Issue";
import { Item } from "../model/Item";

export class HotTabViewModel {
  async loadTabListData(apiUrl: string): Promise<Item[]> {
    const response: AxiosResponse<string> = await get(apiUrl);
    const issue: Issue = JSON.parse(response.data);
    const itemList = issue.itemList;
    return itemList
  }
}