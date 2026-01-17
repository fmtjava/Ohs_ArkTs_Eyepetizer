export interface News {
  itemList: NewsItem[]
  nextPageUrl: string
}

export interface NewsItem {
  type: string
  data: NewsItemData
}

export interface NewsItemData {
  text: string
  titleList?: string[]
  backgroundImage: string
  actionUrl: string
}