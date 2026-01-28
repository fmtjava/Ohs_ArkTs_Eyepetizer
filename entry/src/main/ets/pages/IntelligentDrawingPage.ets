import { PromptAction } from '@kit.ArkUI';
import hilog from '@ohos.hilog';
import { INTELLIGENT_IMAGE_SYNTHESIS_URL, INTELLIGENT_IMAGE_TASK_QUERY_URL } from '../api/Apis';
import { TaskPollingUtil } from '../common/AliYunTaskPollingUtil';
import { QueryResult } from '../model/AliYunQueryTaskResponse';
import { ImagePromptInput, ImageSynthesisParam } from '../model/dto/ImageSynthesisParam';
import { Message } from '../model/dto/QueryChatParam';
import { ChatLineDrawingWidget } from '../view/ChatLineDrawingWidget';
import nativeModule from 'libentry.so';

const TAG = "IntelligentDrawingPage";

@Entry
@Component
struct IntelligentDrawingPage {
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  // 尺寸下拉选项
  private sizeArray: Array<SelectOption> = [
    { value: '512*1024' },
    { value: '768*512' },
    { value: '768*1024' },
    { value: '1024*576' },
    { value: '576*1024' },
    { value: '1024*1024' },
  ];
  // 消息列表
  @State msgList: Message[] = [];
  // 尺寸下拉选项选中的值
  @State sizeStr: string = '512*1024';
  // 按钮的透明度
  @State sendButtonOpacity: number = 0.3;
  // 输入的主题内容
  @State inputSubject: string = ''
  // 显示加载框
  @State isShowLoading: boolean = false;
  // 发送给AI助手的对话
  @State chatInput: string = ''

  aboutToDisappear(): void {
    TaskPollingUtil.cancelAllTasks();
  }

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
      Text($r('app.string.intelligent_drawing'))
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
          ChatLineDrawingWidget({ msg: message });
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
      Row() {
        Text($r('app.string.image_size')).margin({ right: 10 })

        Select(this.sizeArray)
          .selected(0)
          .value(this.sizeStr)
          .font({ size: 16 })
          .fontColor($r('sys.color.black'))
          .selectedOptionFont({ size: 16 })
          .optionWidth(200)
          .optionHeight(300)
          .onSelect((_index: number, value: string) => {
            this.sizeStr = value;
          })
      }
      .width('100%')
      .height(50)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 4, top: 4 })

      // 主题
      // 对话输入框
      Row() {
        TextInput({ text: this.inputSubject, placeholder: $r('app.string.input_image_topic') })
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
              this.chatInput = `帮我画一张关于${this.inputSubject}的图片，尺寸${this.sizeStr}`;
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
            // 写入到消息列表
            const message: Message = new Message('user', this.chatInput);
            this.msgList = [...this.msgList, message];

            // 构建请求体
            const promptInput = new ImagePromptInput(this.chatInput);
            const imageSynthesisParam = new ImageSynthesisParam('wanx-v1', promptInput);
            // 构建请求头
            const executeHeaders: Record<string, string> = {
              "X-DashScope-Async": 'enable',
              "Authorization": `Bearer ${nativeModule.getAliYunAPIPassword()}`,
              "Content-Type": "application/json"
            }
            const queryHeaders: Record<string, string> = {
              "Authorization": `Bearer ${nativeModule.getAliYunAPIPassword()}`,
            }
            // 提交任务
            const pollResult =
              await TaskPollingUtil.submitAndPoll<ImageSynthesisParam, QueryResult[]>(INTELLIGENT_IMAGE_SYNTHESIS_URL,
                INTELLIGENT_IMAGE_TASK_QUERY_URL,
                imageSynthesisParam, executeHeaders, queryHeaders)
            // 判断请求结果
            if (pollResult.success) {
              const queryResults: QueryResult[] | undefined = pollResult.data;
              if (queryResults && queryResults.length > 0) {
                const responseMessage = new Message('assistant', queryResults[0].url)
                this.msgList = [...this.msgList, responseMessage];
              }
              // 清空对话框
              this.chatInput = '';
              this.inputSubject = '';
            } else {
              // 提示错误原因
              this.promptAction.openToast({
                message: pollResult.error
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
      .backgroundColor(Color.White)
      .margin({
        left: 4,
        top: 4,
        right: 4,
        bottom: 4
      })

    }
    .width('100%')
    .height(100)
    .margin({
      left: 4,
      top: 4,
      right: 4,
      bottom: 4
    })
    .backgroundColor(Color.White)
  }
}