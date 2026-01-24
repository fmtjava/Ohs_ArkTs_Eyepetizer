import { AxiosResponse } from '@ohos/axios';
import { INTELLIGENT_CHAT_URL } from '../api/Apis';
import { post } from '../common/http';
import { ChatResponse } from '../model/ChatResponse';
import { QueryChatResultParam } from '../model/dto/QueryChatParam';

export class IntelligentChatViewModel {
  async queryData(param: QueryChatResultParam, headers?: Record<string, string>): Promise<ChatResponse> {
    const response: AxiosResponse<string> = await post<QueryChatResultParam>(INTELLIGENT_CHAT_URL, param, headers);
    const chatResponse: ChatResponse = JSON.parse(response.data);
    return chatResponse
  }
}