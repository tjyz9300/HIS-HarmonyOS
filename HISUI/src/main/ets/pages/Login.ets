// pages/Login.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AuthApi } from '../common/api/AuthApi';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

interface DialogResult {
  index: number;
}

@Entry
@Component
struct Login {
  @State phone: string = '';
  @State password: string = '';
  @State showPassword: boolean = false;
  @State isLoading: boolean = false;

  async aboutToAppear() {
    await this.checkAlreadyLoggedIn();
  }

  async checkAlreadyLoggedIn() {
    const isLoggedIn = await PreferencesUtil.isLoggedIn();
    if (isLoggedIn) {
      router.back();
    }
  }

  build() {
    Column() {
      // 返回按钮
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333')
          .onClick(() => router.back())
        Blank()
      }
      .width('100%')
      .padding(15)

      // Logo区域
      Column() {
        Text('🏥')
          .fontSize(60)
          .margin({ top: 40, bottom: 20 })
        Text('东软云医院')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1890ff')
      }
      .width('100%')
      .margin({ bottom: 50 })

      // 手机号输入
      Column() {
        Row() {
          Text('📱')
            .fontSize(18)
            .margin({ right: 10 })
          Text('+86')
            .fontSize(16)
            .fontColor('#333')
            .margin({ right: 10 })
          Divider()
            .vertical(true)
            .height(20)
            .margin({ right: 10 })
          TextInput({ placeholder: '请输入手机号', text: this.phone })
            .layoutWeight(1)
            .backgroundColor('transparent')
            .type(InputType.PhoneNumber)
            .onChange((value: string) => this.phone = value)
        }
        .width('100%')
        .height(50)
        .padding({ left: 15, right: 15 })
        .borderWidth({ bottom: 1 })
        .borderColor('#e0e0e0')
      }
      .margin({ bottom: 10 })

      // 密码输入
      Row() {
        Text('🔒')
          .fontSize(18)
          .margin({ left: 15, right: 10 })
        TextInput({ placeholder: '请输入密码', text: this.password })
          .layoutWeight(1)
          .backgroundColor('transparent')
          .type(this.showPassword ? InputType.Normal : InputType.Password)
          .onChange((value: string) => this.password = value)
        Text(this.showPassword ? '👁️' : '🙈')
          .fontSize(18)
          .margin({ right: 15 })
          .onClick(() => this.showPassword = !this.showPassword)
      }
      .width('100%')
      .height(50)
      .borderWidth({ bottom: 1 })
      .borderColor('#e0e0e0')
      .margin({ bottom: 20 })

      // 登录按钮
      Button(this.isLoading ? '登录中...' : '登录')
        .width('90%')
        .height(48)
        .backgroundColor('#1890ff')
        .fontColor('#ffffff')
        .fontSize(16)
        .borderRadius(24)
        .margin({ top: 30, bottom: 20 })
        .enabled(!this.isLoading && this.phone.length === 11 && this.password.length > 0)
        .onClick(() => this.handleLogin())

      // 注册链接
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#999')
        Text('立即注册')
          .fontSize(14)
          .fontColor('#1890ff')
          .onClick(() => {
            router.pushUrl({ url: 'pages/Register' })
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }

  async handleLogin() {
    this.isLoading = true;

    try {
      const result = await AuthApi.login({
        phone: this.phone,
        password: this.password
      });

      console.log('Login result: ' + JSON.stringify(result));

      if (result.code === 200 && result.data) {
        // 保存登录信息
        await PreferencesUtil.saveLoginInfo(
          result.data.user_id,
          result.data.token,
          '用户',
          this.phone
        );

        // 验证是否保存成功
        const savedToken = await PreferencesUtil.getToken();
        const savedUserId = await PreferencesUtil.getUserId();
        console.log(`Saved token: ${savedToken}, userId: ${savedUserId}`);

        promptAction.showToast({
          message: '登录成功',
          duration: 1500
        });

        // 延迟一下再返回，确保数据已保存
        setTimeout(() => {
          router.back();
        }, 500);
      } else {
        promptAction.showToast({
          message: result.message || '登录失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Login error: ' + error);
      promptAction.showToast({
        message: '网络错误，请稍后重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }
}