// pages/AddPatient.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PatientApi } from '../common/api/PatientApi';

@Entry
@Component
struct AddPatient {
  @State patientName: string = '';
  @State phone: string = '';
  @State idCard: string = '';
  @State gender: number = 1;
  @State isLoading: boolean = false;

  isFormValid(): boolean {
    return this.patientName.length >= 2 &&
      this.phone.length === 11 &&
      this.idCard.length >= 15;
  }

  async handleSubmit() {
    if (!this.isFormValid()) {
      promptAction.showToast({ message: '请填写完整正确的信息' });
      return;
    }

    this.isLoading = true;
    const result = await PatientApi.addPatient({
      name: this.patientName,
      phone: this.phone,
      id_card: this.idCard
    });

    if (result.code === 200) {
      promptAction.showToast({
        message: '添加成功',
        duration: 2000
      });
      router.back();
    } else {
      promptAction.showToast({
        message: result.message || '添加失败',
        duration: 2000
      });
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333')
          .onClick(() => router.back())
        Text('添加就诊人')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(24)
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#ffffff')

      Scroll() {
        Column() {
          // 头像
          Column() {
            Text(this.gender === 1 ? '👨' : '👩')
              .fontSize(50)
              .backgroundColor('#f0f0f0')
              .width(80)
              .height(80)
              .borderRadius(40)
              .textAlign(TextAlign.Center)
              .lineHeight(80)
              .margin({ top: 20, bottom: 20 })
          }
          .width('100%')

          // 姓名
          this.InputField('👨‍💼', '请输入姓名', this.patientName, (value: string) => this.patientName = value)

          // 手机号
          this.InputField('📱', '请输入手机号', this.phone, (value: string) => this.phone = value, InputType.PhoneNumber)

          // 身份证号
          this.InputField('🆔', '请输入身份证号', this.idCard, (value: string) => this.idCard = value)

          // 性别选择
          Row() {
            Text('⚥')
              .fontSize(18)
              .margin({ right: 10 })
            Text('性别')
              .fontSize(15)
              .fontColor('#333')
              .width(60)

            Row() {
              Radio({ value: '1', group: 'genderGroup' })
                .checked(this.gender === 1)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.gender = 1;
                  }
                })
              Text('男')
                .fontSize(14)
                .margin({ right: 20 })

              Radio({ value: '2', group: 'genderGroup' })
                .checked(this.gender === 2)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.gender = 2;
                  }
                })
              Text('女')
                .fontSize(14)
            }
            .layoutWeight(1)
          }
          .width('100%')
          .height(50)
          .padding({ left: 15, right: 15 })
          .borderWidth({ bottom: 1 })
          .borderColor('#e0e0e0')
          .margin({ bottom: 40 })

          // 提交按钮
          Button(this.isLoading ? '保存中...' : '保存')
            .width('90%')
            .height(48)
            .backgroundColor(this.isFormValid() ? '#1890ff' : '#ccc')
            .fontColor('#ffffff')
            .fontSize(16)
            .borderRadius(24)
            .margin({ bottom: 30 })
            .enabled(this.isFormValid() && !this.isLoading)
            .onClick(() => this.handleSubmit())
        }
        .width('100%')
        .padding({ bottom: 30 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }

  @Builder
  InputField(emoji: string, placeholder: string, value: string, onChange: (value: string) => void, inputType?: InputType) {
    Row() {
      Text(emoji)
        .fontSize(18)
        .margin({ right: 10 })
      TextInput({ placeholder: placeholder, text: value })
        .layoutWeight(1)
        .backgroundColor('transparent')
        .type(inputType || InputType.Normal)
        .onChange(onChange)
    }
    .width('100%')
    .height(50)
    .padding({ left: 15, right: 15 })
    .borderWidth({ bottom: 1 })
    .borderColor('#e0e0e0')
    .margin({ bottom: 10 })
  }
}