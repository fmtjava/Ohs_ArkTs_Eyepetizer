export interface Topic {
  itemList: TopicItem[]
  nextPageUrl: string
}

export interface TopicItem {
  data: TopicItemData
}

export interface TopicItemData {
  id: number
  image: string
  actionUrl: string
}