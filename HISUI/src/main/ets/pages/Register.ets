// pages/Register.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AuthApi } from '../common/api/AuthApi';

@Entry
@Component
struct Register {
  @State phone: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State showPassword: boolean = false;
  @State isLoading: boolean = false;

  isFormValid(): boolean {
    return this.phone.length === 11 &&
      this.password.length >= 6 &&
      this.password === this.confirmPassword;
  }

  async handleRegister() {
    if (!this.isFormValid()) {
      if (this.phone.length !== 11) {
        promptAction.showToast({ message: '请输入正确的手机号' });
      } else if (this.password.length < 6) {
        promptAction.showToast({ message: '密码长度不能少于6位' });
      } else if (this.password !== this.confirmPassword) {
        promptAction.showToast({ message: '两次输入的密码不一致' });
      }
      return;
    }

    this.isLoading = true;
    const result = await AuthApi.register({
      phone: this.phone,
      password: this.password
    });

    if (result.code === 200) {
      promptAction.showToast({
        message: '注册成功，请登录',
        duration: 2000
      });
      router.back();
    } else {
      promptAction.showToast({
        message: result.message || '注册失败',
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
        Text('用户注册')
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
            Text('👤')
              .fontSize(60)
              .backgroundColor('#f0f0f0')
              .width(80)
              .height(80)
              .borderRadius(40)
              .textAlign(TextAlign.Center)
              .lineHeight(80)
              .margin({ top: 20, bottom: 10 })
          }
          .width('100%')

          // 手机号
          this.InputField('📱', '请输入手机号', this.phone, (value: string) => this.phone = value, InputType.PhoneNumber)

          // 密码
          Row() {
            Text('🔒')
              .fontSize(18)
              .margin({ right: 10 })
            TextInput({ placeholder: '请输入密码（至少6位）', text: this.password })
              .layoutWeight(1)
              .backgroundColor('transparent')
              .type(this.showPassword ? InputType.Normal : InputType.Password)
              .onChange((value: string) => this.password = value)
            Text(this.showPassword ? '👁️' : '🙈')
              .fontSize(18)
              .onClick(() => this.showPassword = !this.showPassword)
          }
          .width('100%')
          .height(50)
          .padding({ left: 15, right: 15 })
          .borderWidth({ bottom: 1 })
          .borderColor('#e0e0e0')
          .margin({ bottom: 10 })

          // 确认密码
          this.InputField('🔒', '请再次输入密码', this.confirmPassword, (value: string) => this.confirmPassword = value, InputType.Password)

          // 注册按钮
          Button(this.isLoading ? '注册中...' : '注册')
            .width('90%')
            .height(48)
            .backgroundColor(this.isFormValid() ? '#1890ff' : '#ccc')
            .fontColor('#ffffff')
            .fontSize(16)
            .borderRadius(24)
            .margin({ top: 30, bottom: 20 })
            .enabled(this.isFormValid() && !this.isLoading)
            .onClick(() => this.handleRegister())

          // 登录链接
          Row() {
            Text('已有账号？')
              .fontSize(14)
              .fontColor('#999')
            Text('立即登录')
              .fontSize(14)
              .fontColor('#1890ff')
              .onClick(() => {
                router.back();
              })
          }
          .margin({ bottom: 30 })
        }
        .width('100%')
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