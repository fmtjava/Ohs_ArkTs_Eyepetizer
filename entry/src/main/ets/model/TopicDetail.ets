import { Item } from "./Item"

export interface TopicDetail {
  headerImage: string
  brief: string
  text: string
  itemList: TopicItem[]
}

export interface TopicItem {
  data: TopicItemData
}

export interface TopicItemData {
  content: Item
}