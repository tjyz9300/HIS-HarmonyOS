// pages/Profile.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppointmentApi } from '../common/api/AppointmentApi';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';
import { Appointment, APPOINTMENT_STATUS_TEXT } from '../model/Types';

interface DialogResult {
  index: number;
}

@Entry
@Component
struct Profile {
  @State userName: string = '';
  @State userPhone: string = '';
  @State appointmentList: Appointment[] = [];
  @State isLoading: boolean = true;
  @State selectedTab: number = 0;
  private tabs: string[] = ['全部', '已挂号', '已取消', '已就诊'];

  async aboutToAppear() {
    await this.checkLoginAndLoad();
  }

  async checkLoginAndLoad() {
    const isLoggedIn = await PreferencesUtil.isLoggedIn();
    if (!isLoggedIn) {
      router.replaceUrl({ url: 'pages/Login' });
      return;
    }
    this.userName = await PreferencesUtil.getUserName();
    this.userPhone = await PreferencesUtil.getUserPhone();
    await this.loadAppointments();
  }

  async loadAppointments() {
    this.isLoading = true;
    const appointments = await AppointmentApi.getUserAppointments();
    this.appointmentList = appointments;
    this.isLoading = false;
  }

  getFilteredList(): Appointment[] {
    if (this.selectedTab === 0) {
      return this.appointmentList;
    }
    const targetStatus = this.selectedTab;
    const filteredList: Appointment[] = [];
    for (let i = 0; i < this.appointmentList.length; i++) {
      if (this.appointmentList[i].status === targetStatus) {
        filteredList.push(this.appointmentList[i]);
      }
    }
    return filteredList;
  }

  getStatusEmoji(status: number): string {
    if (status === 1) {
      return '✅';
    } else if (status === 2) {
      return '❌';
    } else {
      return '📋';
    }
  }

  getStatusColor(status: number): string {
    if (status === 1) {
      return '#52c41a';
    } else if (status === 2) {
      return '#ff4d4f';
    } else {
      return '#999';
    }
  }

  async handleCancelAppointment(appId: number) {
    promptAction.showDialog({
      title: '取消预约',
      message: '确定要取消本次预约吗？',
      buttons: [
        { text: '确定', color: '#ff4d4f' },
        { text: '取消', color: '#999' }
      ]
    }).then(async (result: DialogResult) => {
      if (result.index === 0) {
        const res = await AppointmentApi.cancelAppointment(appId);
        if (res.code === 200) {
          promptAction.showToast({ message: '取消成功' });
          await this.loadAppointments();
        } else {
          promptAction.showToast({ message: res.message || '取消失败' });
        }
      }
    });
  }

  getCountByStatus(status: number): number {
    let count = 0;
    for (let i = 0; i < this.appointmentList.length; i++) {
      if (this.appointmentList[i].status === status) {
        count++;
      }
    }
    return count;
  }

  build() {
    Column() {
      // 头部用户信息卡片
      Column() {
        Row() {
          Text('👤')
            .fontSize(50)
            .backgroundColor('#e6f7ff')
            .width(60)
            .height(60)
            .borderRadius(30)
            .textAlign(TextAlign.Center)
            .lineHeight(60)

          Column() {
            Text(this.userName || '用户')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Row() {
              Text('📱')
                .fontSize(12)
                .margin({ right: 4 })
              Text(this.userPhone || '绑定手机号')
                .fontSize(12)
                .fontColor('#999')
            }
            .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 15 })
          .layoutWeight(1)

          Row() {
            Text('✏️')
              .fontSize(14)
              .margin({ right: 4 })
            Text('编辑')
              .fontSize(14)
          }
          .height(30)
          .padding({ left: 12, right: 12 })
          .backgroundColor('transparent')
          .borderRadius(15)
          .border({ width: 1, color: '#1890ff' })
        }
        .width('100%')
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#ffffff')
      .margin({ bottom: 10 })

      // 统计卡片
      Row() {
        this.StatItem('📋', '已挂号', this.getCountByStatus(1))
        this.StatItem('✅', '已就诊', this.getCountByStatus(3))
        this.StatItem('📊', '总挂号', this.appointmentList.length)
      }
      .width('94%')
      .padding(15)
      .backgroundColor('#f8f9fa')
      .borderRadius(12)
      .margin({ bottom: 15 })
      .alignSelf(ItemAlign.Center)

      // Tab切换
      Row() {
        ForEach(this.tabs, (tab: string, index: number) => {
          Text(tab)
            .fontSize(15)
            .fontWeight(this.selectedTab === index ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selectedTab === index ? '#1890ff' : '#666')
            .padding({ left: 15, right: 15, bottom: 10 })
            .borderWidth({ bottom: this.selectedTab === index ? 2 : 0 })
            .borderColor('#1890ff')
            .onClick(() => {
              this.selectedTab = index;
            })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor('#ffffff')
      .padding({ top: 12, bottom: 12 })

      if (this.isLoading) {
        LoadingProgress().width(50).height(50).margin({ top: 50 })
      } else if (this.getFilteredList().length === 0) {
        Column() {
          Text('📭')
            .fontSize(60)
            .opacity(0.3)
            .margin({ top: 60, bottom: 15 })
          Text('暂无挂号记录')
            .fontSize(15)
            .fontColor('#999')
            .margin({ bottom: 8 })
          Text('点击首页"预约挂号"开始就诊')
            .fontSize(12)
            .fontColor('#ccc')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.getFilteredList(), (record: Appointment) => {
            ListItem() {
              this.AppointmentItem(record)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0.5, color: '#f0f0f0' })
      }

      Row() {
        Text('🚪')
          .fontSize(16)
          .margin({ right: 8 })
        Text('退出登录')
          .fontSize(16)
      }
      .width('90%')
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('transparent')
      .borderRadius(22)
      .border({ width: 1, color: '#ff4d4f' })
      .margin({ bottom: 30 })
      .onClick(() => {
        promptAction.showDialog({
          title: '提示',
          message: '确定要退出登录吗？',
          buttons: [
            { text: '确定', color: '#ff4d4f' },
            { text: '取消', color: '#999' }
          ]
        }).then(async (result: DialogResult) => {
          if (result.index === 0) {
            await PreferencesUtil.clear();
            router.replaceUrl({ url: 'pages/Login' });
          }
        });
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f8f8')
  }

  @Builder
  StatItem(emoji: string, title: string, count: number) {
    Column() {
      Text(emoji)
        .fontSize(24)
        .margin({ bottom: 5 })
      Text(count.toString())
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
      Text(title)
        .fontSize(12)
        .fontColor('#999')
        .margin({ top: 5 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  AppointmentItem(record: Appointment) {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('🏥')
              .fontSize(14)
              .margin({ right: 5 })
            Text(record.dept_name || '科室')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 6 })

          Row() {
            Text('👨‍⚕️')
              .fontSize(12)
              .margin({ right: 5 })
            Text(record.doc_name || '医生')
              .fontSize(13)
              .fontColor('#666')
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Row() {
          Text(this.getStatusEmoji(record.status))
            .fontSize(12)
            .margin({ right: 4 })
          Text(record.statusText)
            .fontSize(13)
            .fontColor(this.getStatusColor(record.status))
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(`${this.getStatusColor(record.status)}15`)
        .borderRadius(12)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('📅')
          .fontSize(12)
          .opacity(0.6)
          .margin({ right: 5 })
        Text(record.sch_date || record.create_time)
          .fontSize(12)
          .fontColor('#999')
      }
      .margin({ bottom: 8 })

      Row() {
        Text('👤')
          .fontSize(12)
          .opacity(0.6)
          .margin({ right: 5 })
        Text(record.pat_name)
          .fontSize(12)
          .fontColor('#999')
      }

      Row() {
        Text('💰')
          .fontSize(12)
          .opacity(0.6)
          .margin({ right: 5 })
        Text(`¥${record.fee}`)
          .fontSize(12)
          .fontColor('#faad14')
      }
      .margin({ top: 8 })

      Row() {
        Text('🎫')
          .fontSize(12)
          .opacity(0.6)
          .margin({ right: 5 })
        Text(`挂号单号: ${record.app_no}`)
          .fontSize(11)
          .fontColor('#999')
      }
      .margin({ top: 4 })

      if (record.status === 1) {
        Row() {
          Row() {
            Text('🗑️')
              .fontSize(12)
              .margin({ right: 4 })
            Text('取消预约')
              .fontSize(13)
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#fff1f0')
          .borderRadius(15)
          .onClick(() => {
            this.handleCancelAppointment(record.app_id);
          })
        }
        .width('100%')
        .margin({ top: 12 })
        .justifyContent(FlexAlign.End)
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#ffffff')
    .margin({ bottom: 1 })
  }
}