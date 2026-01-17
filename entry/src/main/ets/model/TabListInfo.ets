export interface TabListInfo {
  tabInfo: TabInfo
}

export interface TabInfo {
  tabList: Tab[]
}

export interface Tab {
  name: string
  apiUrl: string
}