// pages/SelectPatient.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PatientApi } from '../common/api/PatientApi';
import { Patient, Schedule } from '../model/Types';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';
import { AppointmentApi } from '../common/api/AppointmentApi';
@Entry
@Component
struct SelectPatient {
  @State patientList: Patient[] = [];
  @State selectedPatientId: number = 0;
  @State isLoading: boolean = true;
  private doctorId: number = 0;
  private doctorName: string = '';
  private departmentName: string = '';
  private selectedDate: string = '';
  private timeSlot: Schedule | null = null;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.doctorId = params['doctorId'] as number;
    this.doctorName = params['doctorName'] as string;
    this.departmentName = params['departmentName'] as string;
    this.selectedDate = params['selectedDate'] as string;
    this.timeSlot = params['timeSlot'] as Schedule;
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
    if (patients.length > 0) {
      this.selectedPatientId = patients[0].pat_id;
    }
    this.isLoading = false;
  }

  getSelectedPatient(): Patient | null {
    for (let i = 0; i < this.patientList.length; i++) {
      if (this.patientList[i].pat_id === this.selectedPatientId) {
        return this.patientList[i];
      }
    }
    return null;
  }

  async handleConfirm() {
    const selectedPatient = this.getSelectedPatient();
    if (!selectedPatient || !this.timeSlot) {
      return;
    }

    const result = await AppointmentApi.createAppointment({
      pat_id: selectedPatient.pat_id,
      pat_name: selectedPatient.name,
      dynamic_id: this.timeSlot.dynamic_id,
      app_type: 1,
      fee: this.timeSlot.fee
    });

    if (result.code === 200) {
      promptAction.showToast({ message: '挂号成功！', duration: 2000 });
      router.replaceUrl({ url: 'pages/Index' });
    } else {
      promptAction.showToast({ message: result.message || '挂号失败', duration: 2000 });
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333')
          .onClick(() => router.back())
        Text('选择就诊人')
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

      // 医生信息卡片
      Column() {
        Row() {
          Text('👨‍⚕️')
            .fontSize(40)
          Column() {
            Text(this.doctorName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Text(this.departmentName)
              .fontSize(12)
              .fontColor('#999')
          }
          .margin({ left: 12 })
          .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Text(`📅 ${this.selectedDate} ${this.timeSlot?.start_time || ''}-${this.timeSlot?.end_time || ''}`)
          .fontSize(12)
          .fontColor('#666')

        Text(`💰 挂号费: ¥${this.timeSlot?.fee || 0}`)
          .fontSize(12)
          .fontColor('#faad14')
          .margin({ top: 4 })
      }
      .width('90%')
      .padding(15)
      .backgroundColor('#f5f9ff')
      .borderRadius(12)
      .margin({ top: 10, bottom: 20 })
      .alignSelf(ItemAlign.Center)

      // 就诊人列表标题
      Row() {
        Text('👥 选择就诊人')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text(`共${this.patientList.length}人`)
          .fontSize(12)
          .fontColor('#999')
      }
      .width('90%')
      .margin({ bottom: 15 })

      if (this.isLoading) {
        LoadingProgress().width(50).height(50).margin({ top: 50 })
      } else if (this.patientList.length === 0) {
        Column() {
          Text('👤')
            .fontSize(60)
            .opacity(0.3)
            .margin({ bottom: 15 })
          Text('暂无就诊人')
            .fontSize(15)
            .fontColor('#999')
            .margin({ bottom: 10 })
          Button('立即添加')
            .width(120)
            .height(40)
            .backgroundColor('#1890ff')
            .fontColor('#ffffff')
            .borderRadius(20)
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddPatient' })
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
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

          // 确认按钮
          Button('确认挂号')
            .width('90%')
            .height(48)
            .backgroundColor('#1890ff')
            .fontColor('#ffffff')
            .fontSize(16)
            .borderRadius(24)
            .margin({ bottom: 30, top: 20 })
            .onClick(() => this.handleConfirm())
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f8f8')
  }

  @Builder
  PatientItem(patient: Patient) {
    Row() {
      Radio({ value: patient.pat_id.toString(), group: 'patientGroup' })
        .checked(this.selectedPatientId === patient.pat_id)
        .onChange((isChecked: boolean) => {
          if (isChecked) {
            this.selectedPatientId = patient.pat_id;
          }
        })
        .margin({ right: 12 })

      Column() {
        Text(patient.gender === 1 ? '👨' : '👩')
          .fontSize(36)
      }
      .margin({ right: 12 })

      Column() {
        Row() {
          Text(patient.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Text(`(${patient.gender === 1 ? '男' : '女'})`)
            .fontSize(12)
            .fontColor('#999')
            .margin({ left: 5 })
        }
        .width('100%')
        .margin({ bottom: 4 })

        Text(this.formatIdCard(patient.id_card))
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#ffffff')
  }

  formatIdCard(idCard: string): string {
    if (idCard.length > 10) {
      return idCard.substring(0, 6) + '********' + idCard.substring(idCard.length - 4);
    }
    return idCard;
  }
}

