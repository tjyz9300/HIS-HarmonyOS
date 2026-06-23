// pages/Index.ets
import router from '@ohos.router';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

interface DialogResult {
  index: number;
}

@Entry
@Component
struct Index {
  @State currentDate: string = '';
  @State hospitalName: string = '东软云医院';
  @State isLoggedIn: boolean = false;

  async aboutToAppear() {
    this.updateDate();
    await this.checkLoginStatus();
  }

  onPageShow() {
    this.checkLoginStatus();
  }

  updateDate() {
    const date = new Date();
    this.currentDate = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
  }

  async checkLoginStatus() {
    this.isLoggedIn = await PreferencesUtil.isLoggedIn();
  }

  navigateTo(page: string) {
    router.pushUrl({
      url: `pages/${page}`
    }).catch((err: Error) => {
      console.error(`页面跳转失败: ${page}`);
    });
  }

  build() {
    Column() {
      // 顶部状态栏区域
      Row() {
        Text(this.currentDate)
          .fontSize(14)
          .fontColor('#666')
        Text('...')
          .fontSize(14)
          .fontColor('#666')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10 })
      .justifyContent(FlexAlign.SpaceBetween)

      // 医院名称
      Column() {
        Text(this.hospitalName)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })
        Text('三甲综合医院')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 5 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 30 })

      // 搜索栏
      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ left: 12 })
        Text('搜索科室或医生')
          .fontSize(14)
          .fontColor('#ccc')
          .margin({ left: 10 })
      }
      .width('90%')
      .height(45)
      .backgroundColor('#f5f5f5')
      .borderRadius(22.5)
      .margin({ bottom: 20 })

      // 功能入口
      Grid() {
        GridItem() {
          this.FunctionItem('🏥', '预约挂号', '#1890ff', () => {
            this.navigateTo('SelectDepartment');
          })
        }
        GridItem() {
          this.FunctionItem('📋', '挂号记录', '#52c41a', () => {
            if (this.isLoggedIn) {
              this.navigateTo('Profile');
            } else {
              this.navigateTo('Login');
            }
          })
        }
        GridItem() {
          this.FunctionItem('👤', '就诊人管理', '#faad14', () => {
            if (this.isLoggedIn) {
              this.navigateTo('PatientList');
            } else {
              this.navigateTo('Login');
            }
          })
        }
        GridItem() {
          this.FunctionItem('⚙️', '个人中心', '#722ed1', () => {
            if (this.isLoggedIn) {
              this.navigateTo('Profile');
            } else {
              this.navigateTo('Login');
            }
          })
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .width('90%')
      .height(200)

      // 公告区域
      Column() {
        Row() {
          Text('公告')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Blank()
          Text('更多 >')
            .fontSize(12)
            .fontColor('#1890ff')
        }
        .width('100%')
        .margin({ bottom: 10 })

        Text('1. 预约挂号需提前15分钟到达医院取号')
          .fontSize(13)
          .fontColor('#666')
          .margin({ bottom: 8 })
        Text('2. 如需取消预约，请提前一天操作')
          .fontSize(13)
          .fontColor('#666')
      }
      .width('90%')
      .padding(15)
      .backgroundColor('#fafafa')
      .borderRadius(12)
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }

  @Builder
  FunctionItem(emoji: string, title: string, color: string, action: () => void) {
    Column() {
      Text(emoji)
        .fontSize(32)
        .margin({ bottom: 8 })
      Text(title)
        .fontSize(14)
        .fontColor('#333')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(action)
  }
}