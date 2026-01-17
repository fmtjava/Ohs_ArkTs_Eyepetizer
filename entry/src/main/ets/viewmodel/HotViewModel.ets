import { AxiosResponse } from "@ohos/axios";
import { HOT_TAB_URL } from "../api/Apis";
import { get } from "../common/http";
import { Tab, TabListInfo } from "../model/TabListInfo";

export class HotViewModel {
  async loadTabData(): Promise<Tab[]> {
    const response: AxiosResponse<string> = await get(HOT_TAB_URL);
    const tabListInfo: TabListInfo = JSON.parse(response.data);
    const tabList = tabListInfo.tabInfo.tabList;
    return tabList
  }
}