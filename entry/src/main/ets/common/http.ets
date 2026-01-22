import axios, { AxiosResponse } from '@ohos/axios'

export const get = (url: string): Promise<AxiosResponse<string>> => {
  return axios.get<string, AxiosResponse<string, null>>(url, { responseType: 'string' })
}

export const post = <T>(url: string, params: T, headers?: Record<string, string>): Promise<AxiosResponse<string>> => {
  return axios.post<string, AxiosResponse<string, T>>(url, params, { responseType: 'string', headers: headers })
}