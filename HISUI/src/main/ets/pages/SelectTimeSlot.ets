// pages/SelectTimeSlot.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ScheduleApi, Schedule } from '../common/api/ScheduleApi';

interface DialogResult {
  index: number;
}

@Entry
@Component
struct SelectTimeSlot {
  @State timeSlots: Schedule[] = [];
  @State selectedTimeSlot: Schedule | null = null;
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  private doctorId: number = 0;
  private doctorName: string = '';
  private doctorTitle: string = '';
  private departmentName: string = '';
  private selectedDate: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.doctorId = params['doctorId'] as number;
    this.doctorName = params['doctorName'] as string;
    this.doctorTitle = params['doctorTitle'] as string;
    this.departmentName = params['departmentName'] as string;
    this.selectedDate = params['selectedDate'] as string;

    console.log('========== 选择时段页面参数 ==========');
    console.log(`医生ID: ${this.doctorId}`);
    console.log(`医生姓名: ${this.doctorName}`);
    console.log(`就诊日期: ${this.selectedDate}`);
    console.log('=====================================');

    this.loadTimeSlots();
  }

  async loadTimeSlots() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      console.log(`开始获取医生 ${this.doctorId} 在 ${this.selectedDate} 的号源`);
      const schedules = await ScheduleApi.getSchedulesByDoctor(this.doctorId, this.selectedDate);
      console.log(`获取到号源数量: ${schedules.length}`);

      if (schedules.length === 0) {
        this.errorMessage = '该医生当天暂无号源，请选择其他日期';
        this.timeSlots = [];
      } else {
        this.timeSlots = schedules;
      }
    } catch (error) {
      console.error('加载号源失败: ' + JSON.stringify(error));
      this.errorMessage = '加载失败，请检查网络连接';
      this.timeSlots = [];
    } finally {
      this.isLoading = false;
    }
  }

  // 将 period 字符串转换为中文
  getPeriodText(period: string): string {
    if (period === 'AM') {
      return '上午';
    } else if (period === 'PM') {
      return '下午';
    }
    return '';
  }

  // 从 time_slot 中提取开始时间和结束时间
  getStartTime(timeSlot: string): string {
    if (!timeSlot) {
      return '';
    }
    const parts = timeSlot.split('-');
    if (parts.length === 2) {
      return parts[0];
    }
    return timeSlot;
  }

  getEndTime(timeSlot: string): string {
    if (!timeSlot) {
      return '';
    }
    const parts = timeSlot.split('-');
    if (parts.length === 2) {
      return parts[1];
    }
    return '';
  }

  formatDateForDisplay(dateStr: string): string {
    if (!dateStr) {
      return '';
    }
    const parts = dateStr.split('-');
    if (parts.length === 3) {
      return `${parts[1]}月${parts[2]}日`;
    }
    return dateStr;
  }

  refreshData() {
    this.loadTimeSlots();
  }

  goBack() {
    router.back();
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333')
          .onClick(() => this.goBack())
        Text('选择时段')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('🔄')
          .fontSize(20)
          .fontColor('#1890ff')
          .onClick(() => {
            this.refreshData();
          })
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#ffffff')

      // 医生信息卡片
      Column() {
        Row() {
          Text('👨‍⚕️')
            .fontSize(40)
          Column() {
            Text(this.doctorName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Text(this.doctorTitle)
              .fontSize(12)
              .fontColor('#999')
          }
          .margin({ left: 12 })
          .layoutWeight(1)
          Text(this.departmentName)
            .fontSize(12)
            .fontColor('#1890ff')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#e6f7ff')
            .borderRadius(12)
        }
        .width('100%')
        .margin({ bottom: 10 })

        Text(`📅 ${this.formatDateForDisplay(this.selectedDate)} 就诊`)
          .fontSize(12)
          .fontColor('#666')
      }
      .width('90%')
      .padding(15)
      .backgroundColor('#f5f9ff')
      .borderRadius(12)
      .margin({ top: 15, bottom: 20 })
      .alignSelf(ItemAlign.Center)

      // 时段标题
      Row() {
        Text('⏰ 请选择就诊时段')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(`共${this.timeSlots.length}个时段`)
          .fontSize(12)
          .fontColor('#999')
          .margin({ left: 10 })
      }
      .width('90%')
      .margin({ bottom: 15 })

      // 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .margin({ bottom: 15 })
          Text('加载号源中...')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMessage !== '' && this.timeSlots.length === 0) {
        Column() {
          Text('⚠️')
            .fontSize(48)
            .opacity(0.5)
            .margin({ bottom: 15 })
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#999')
            .margin({ bottom: 20 })
            .textAlign(TextAlign.Center)
          Row() {
            Button('返回')
              .width(100)
              .height(36)
              .fontSize(14)
              .backgroundColor('#ccc')
              .borderRadius(18)
              .margin({ right: 15 })
              .onClick(() => this.goBack())

            Button('刷新')
              .width(100)
              .height(36)
              .fontSize(14)
              .backgroundColor('#1890ff')
              .borderRadius(18)
              .onClick(() => this.refreshData())
          }
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.timeSlots.length === 0) {
        Column() {
          Text('⏰')
            .fontSize(48)
            .opacity(0.5)
            .margin({ bottom: 15 })
          Text('暂无可用时段')
            .fontSize(16)
            .fontColor('#999')
          Text('请选择其他日期')
            .fontSize(13)
            .fontColor('#ccc')
            .margin({ top: 5 })
          Button('返回')
            .width(100)
            .height(36)
            .fontSize(14)
            .backgroundColor('#1890ff')
            .borderRadius(18)
            .margin({ top: 20 })
            .onClick(() => this.goBack())
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.timeSlots, (slot: Schedule) => {
              ListItem() {
                this.TimeSlotItem(slot)
              }
            }, (slot: Schedule) => slot.dynamic_id.toString())
          }
          .width('90%')
          .padding({ bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // 确认按钮
      Button(this.selectedTimeSlot ? '确认挂号' : '请选择时段')
        .width('90%')
        .height(48)
        .backgroundColor(this.selectedTimeSlot ? '#1890ff' : '#ccc')
        .fontColor('#ffffff')
        .fontSize(16)
        .borderRadius(24)
        .margin({ bottom: 30 })
        .enabled(this.selectedTimeSlot !== null)
        .onClick(() => {
          if (this.selectedTimeSlot) {
            console.log('确认挂号 - 选中时段:', JSON.stringify(this.selectedTimeSlot));
            router.pushUrl({
              url: 'pages/SelectPatient',
              params: {
                doctorId: this.doctorId,
                doctorName: this.doctorName,
                departmentName: this.departmentName,
                selectedDate: this.selectedDate,
                timeSlot: this.selectedTimeSlot
              }
            });
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }

  @Builder
  TimeSlotItem(slot: Schedule) {
    Row() {
      Column() {
        Row() {
          Text(this.getPeriodText(slot.period))
            .fontSize(12)
            .fontColor('#ffffff')
            .backgroundColor('#1890ff')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(10)
          Text(` ${this.getStartTime(slot.time_slot)} - ${this.getEndTime(slot.time_slot)}`)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 8 })
        }
        .margin({ bottom: 8 })

        Row() {
          Text(`📊 总号源: ${slot.total_quota}`)
            .fontSize(11)
            .fontColor('#666')
          Text(`  |  剩余: ${slot.remaining_quota}`)
            .fontSize(11)
            .fontColor(slot.remaining_quota > 0 ? '#52c41a' : '#ff4d4f')
        }

        Text(`💰 挂号费: ¥${slot.fee || 50}`)
          .fontSize(12)
          .fontColor('#faad14')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.selectedTimeSlot?.dynamic_id === slot.dynamic_id) {
        Column() {
          Text('✓')
            .fontSize(24)
            .fontColor('#1890ff')
            .fontWeight(FontWeight.Bold)
        }
        .margin({ right: 10 })
      } else if (slot.remaining_quota > 0) {
        Column() {
          Text('○')
            .fontSize(24)
            .fontColor('#ccc')
        }
        .margin({ right: 10 })
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor(this.selectedTimeSlot?.dynamic_id === slot.dynamic_id ? '#e6f7ff' : '#f8f8f8')
    .borderRadius(12)
    .margin({ bottom: 10 })
    .opacity(slot.remaining_quota > 0 ? 1 : 0.5)
    .onClick(() => {
      if (slot.remaining_quota > 0) {
        console.log(`选中时段: ${slot.time_slot}, dynamic_id: ${slot.dynamic_id}`);
        this.selectedTimeSlot = slot;
      } else {
        promptAction.showToast({
          message: '该时段号源已满',
          duration: 1500
        });
      }
    })
  }
}