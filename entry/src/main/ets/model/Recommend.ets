import { Item } from "./Item"

export interface Recommend {
  itemList: RecommendItem[]
  nextPageUrl: string
}

export interface RecommendItem {
  type: string
  data: RecommendItemData
}

export interface RecommendItemData {
  content: Item
}