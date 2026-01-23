import { PromptAction } from '@kit.ArkUI';
import { inputMethod } from '@kit.IMEKit';
import { Choice } from '../model/ChatResponse';
import { Message, QueryChatResultParam } from '../model/dto/QueryChatResultParam';
import { ChatLineWidget } from '../view/ChatLineWidget';
import { IntelligentChatViewModel } from '../viewmodel/IntelligentChatViewModel';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = "IntelligentWritingPage";

@Entry
@Component
struct IntelligentWritingPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private viewModel: IntelligentChatViewModel = new IntelligentChatViewModel();
  // 消息列表
  @State msgList: Message[] = [];
  // 文章类型
  @State articleType: string = '文案'
  // 文章字数
  @State wordNumberStr: string = '100'
  // 字数下拉选择菜单
  @State wordNumberArray: Array<SelectOption> = [
    { value: '100' },
    { value: '200' },
    { value: '300' },
    { value: '400' },
    { value: '500' },
    { value: '600' },
    { value: '700' },
    { value: '800' },
    { value: '900' },
  ];
  // 文章主题
  @State inputSubject: string = ''
  // 按钮的可见度
  @State sendButtonOpacity: number = 0.3;
  // 显示加载框
  @State isShowLoading: boolean = false;
  // 发送给AI助手的消息
  @State
  chatInput: string = ''

  build() {
    Column() {
      this.TitleBar()
      this.ChatListView()
      this.ChatInputView()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private TitleBar() {
    Flex({ wrap: FlexWrap.NoWrap, alignItems: ItemAlign.Center }) {
      Image($r('app.media.ic_chevron_left'))
        .width(24)
        .height(24)
        .margin({ left: 15 })
        .onClick(() => {
          this.uiContext.getRouter().back();
        })
      Text($r('app.string.intelligent_writing'))
        .fontSize(24)
        .width('100%')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .align(Alignment.Center)
      Blank()
        .width(24)
        .height(24)
        .margin({ right: 15 })
    }
    .width('100%')
    .height(48)
    .shadow({
      radius: 4,
      color: 0x33000000,
      offsetX: 0,
      offsetY: 4
    })
    .expandSafeArea([SafeAreaType.KEYBOARD], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  private ChatListView() {
    Scroll() {
      Column() {
        ForEach(this.msgList, (message: Message) => {
          ChatLineWidget({ msg: message });
        }, (_message: Message, index: number) => `chat-list-key-${index}`)
      }
      .width('100%')
      .padding({
        left: 10,
        top: 10,
        right: 10,
        bottom: 10
      })
      .alignItems(HorizontalAlign.Start)
    }
    .align(Alignment.TopStart)
    .layoutWeight(1)
    .backgroundColor('#F8F7F8')
    .scrollBar(BarState.Off)
    .expandSafeArea([SafeAreaType.KEYBOARD], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  private ChatInputView() {
    Column() {
      // 类型
      Row() {
        Text($r('app.string.article_type'))
          .margin({ right: 10 })

        Radio({ group: 'radioGroup', value: '文案' })
          .checked(true)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.articleType = '文案';
            }
          })

        Text('文案')
          .margin({ right: 10 })

        Radio({ group: 'radioGroup', value: '报告' })
          .checked(false)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.articleType = '报告';
            }
          })

        Text('报告')
          .margin({ right: 4 })

        Radio({ group: 'radioGroup', value: '日记' })
          .checked(false)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.articleType = '日记';
            }
          })

        Text('日记')
          .margin({ right: 4 })

        Radio({ group: 'radioGroup', value: '代码' })
          .checked(false)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.articleType = '代码';
            }
          })

        Text('代码')
          .margin({ right: 4 })

      }
      .width('100%')
      .height(50)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 4, top: 4 })

      // 字数
      Row() {
        Text($r('app.string.word_count'))
          .margin({ right: 10 })

        Select(this.wordNumberArray)
          .selected(0)
          .font({ size: 16, weight: FontWeight.Medium })
          .fontColor($r('sys.color.black'))
          .selectedOptionFont({ size: 16, weight: FontWeight.Medium })
          .optionWidth(200)
          .optionHeight(300)
          .value(this.wordNumberStr)
          .onSelect((_index: number, value: string) => {
            this.wordNumberStr = value;
          })
      }
      .width('100%')
      .height(50)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 4, top: 4 })

      // 对话输入框
      Row() {
        TextInput({ text: this.inputSubject, placeholder: $r('app.string.input_article_topic') })
          .height(40)
          .layoutWeight(1)
          .borderRadius(4)
          .margin({ right: 5 })
          .fontColor($r('sys.color.black'))
          .onChange((value: string) => {
            this.inputSubject = value;
            if (this.inputSubject === '') {
              this.sendButtonOpacity = 0.3;
            } else {
              this.sendButtonOpacity = 1.0;
              // 组装消息
              this.chatInput = `帮我写关于${this.inputSubject}的${this.articleType}，字数${this.wordNumberStr}`;
              hilog.info(0, TAG, `chatInput: ${this.chatInput}`);
            }
          })
        Button() {
          Text($r('app.string.send'))
            .fontColor(Color.White)
            .fontSize(16)
        }
        .type(ButtonType.Capsule)
        .width(70)
        .height(40)
        .backgroundColor('#4397F7')
        .margin({ right: 5 })
        .opacity(this.sendButtonOpacity)
        .onClick(async () => {
          try {
            if (this.chatInput === '') {
              return
            }
            // 显示加载框
            this.isShowLoading = true;
            // 隐藏软键盘
            await inputMethod.getController().stopInputSession();
            // 写入到消息列表
            const message: Message = new Message('user', this.chatInput);
            this.msgList = [...this.msgList, message];

            // 构建请求体
            const requestMessageList = new Array<Message>();
            requestMessageList.push(new Message('user', this.chatInput));
            const param: QueryChatResultParam = new QueryChatResultParam("spark-x", "user_id", requestMessageList);
            const headers: Record<string, string> = {
              "Authorization": "Bearer DoCBjyODmXmuLjjkLLBY:tWGmRRiQffYWACxMvjxf",
              "content-type": "application/json"
            }
            // 发起请求
            const chatResponse = await this.viewModel.queryData(param, headers)
            // 处理请求结果
            if (chatResponse.code === 0) {
              const choices: Choice[] = chatResponse.choices;
              const responseMessageList = new Array<Message>();
              for (const choicesElement of choices) {
                responseMessageList.push(new Message(choicesElement.message.role, choicesElement.message.content))
              }
              this.msgList = [...this.msgList, ...responseMessageList];

              // 清空对话框
              this.chatInput = '';
              this.inputSubject = '';
            } else {
              // 提示错误原因
              this.promptAction.openToast({
                message: chatResponse.message
              }).catch(() => {
              })
            }
          } catch (error) {
            console.log(JSON.stringify(error));
            const errorMsg: string = error?.message || String(error) || '未知错误';
            this.promptAction.openToast({
              message: errorMsg
            }).catch(() => {
            })
          } finally {
            this.isShowLoading = false;
          }
        })
        .visibility(this.isShowLoading ? Visibility.None : Visibility.Visible)

        // 加载框
        LoadingProgress()
          .width(48)
          .height(48)
          .color('#999999')
          .visibility(this.isShowLoading ? Visibility.Visible : Visibility.None)
      }
      .height(50)
      .margin({
        left: 4,
        top: 4,
        right: 4,
        bottom: 4
      })
    }
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}