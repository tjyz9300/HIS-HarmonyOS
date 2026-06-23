// pages/PatientList.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PatientApi } from '../common/api/PatientApi';
import { Patient } from '../model/Types';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

interface DialogResult {
  index: number;
}

@Entry
@Component
struct PatientList {
  @State patientList: Patient[] = [];
  @State isLoading: boolean = true;

  async aboutToAppear() {
    await this.checkLoginAndLoad();
  }

  async checkLoginAndLoad() {
    const isLoggedIn = await PreferencesUtil.isLoggedIn();
    if (!isLoggedIn) {
      router.replaceUrl({ url: 'pages/Login' });
      return;
    }
    await this.loadPatients();
  }

  async loadPatients() {
    this.isLoading = true;
    const patients = await PatientApi.getPatientList();
    this.patientList = patients;
    this.isLoading = false;
  }

  getGenderText(gender: number): string {
    if (gender === 1) {
      return '男';
    } else {
      return '女';
    }
  }

  formatIdCard(idCard: string): string {
    if (idCard.length > 10) {
      return idCard.substring(0, 6) + '********' + idCard.substring(idCard.length - 4);
    }
    return idCard;
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333')
          .onClick(() => router.back())
        Text('就诊人管理')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('+')
          .fontSize(24)
          .fontColor('#1890ff')
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddPatient' })
          })
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#ffffff')

      if (this.isLoading) {
        LoadingProgress().width(50).height(50).margin({ top: 50 })
      } else if (this.patientList.length === 0) {
        Column() {
          Text('👤')
            .fontSize(60)
            .opacity(0.3)
            .margin({ top: 80, bottom: 20 })
          Text('暂无就诊人')
            .fontSize(16)
            .fontColor('#999')
            .margin({ bottom: 10 })
          Text('点击右上角 + 添加就诊人')
            .fontSize(13)
            .fontColor('#ccc')
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.patientList, (patient: Patient) => {
            ListItem() {
              this.PatientItem(patient)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0.5, color: '#f0f0f0' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f8f8')
  }

  @Builder
  PatientItem(patient: Patient) {
    Row() {
      Column() {
        Text(patient.gender === 1 ? '👨' : '👩')
          .fontSize(40)
      }
      .margin({ right: 12 })

      Column() {
        Row() {
          Text(patient.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Text(`(${this.getGenderText(patient.gender)})`)
            .fontSize(12)
            .fontColor('#999')
            .margin({ left: 5 })
        }
        .width('100%')
        .margin({ bottom: 5 })

        Text(this.formatIdCard(patient.id_card))
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('›')
        .fontSize(20)
        .fontColor('#ccc')
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#ffffff')
  }
}