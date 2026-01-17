import axios, { AxiosResponse } from '@ohos/axios'

export const get = (url: string): Promise<AxiosResponse<string>> => {
  return axios.get<string, AxiosResponse<string, null>>(url, {responseType: 'string'})
}