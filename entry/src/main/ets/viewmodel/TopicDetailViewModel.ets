import { AxiosResponse } from "@ohos/axios";
import { TOPIC_DETAIL_URL } from "../api/Apis";
import { get } from "../common/http";
import { TopicDetail } from "../model/TopicDetail";

export class TopicDetailViewModel {
  async getTopicDetail(topicId: number): Promise<TopicDetail> {
    const response: AxiosResponse<string> = await get(`${TOPIC_DETAIL_URL}${topicId}`);
    const topicDetail: TopicDetail = JSON.parse(response.data);
    return topicDetail
  }
}