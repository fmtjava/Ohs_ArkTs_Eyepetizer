import { AxiosResponse } from '@ohos/axios';
import { CATEGORY_URL } from '../api/Apis';
import { get } from '../common/http';
import { Category } from '../model/Category';

export class CategoryViewModel {
  async loadData(): Promise<Category[]> {
    const response: AxiosResponse<string> = await get(CATEGORY_URL);
    const categoryList: Category[] = JSON.parse(response.data);
    return categoryList
  }
}