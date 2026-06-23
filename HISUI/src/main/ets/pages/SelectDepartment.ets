// pages/SelectDepartment.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { DepartmentApi, Department } from '../common/api/DepartmentApi';

@Entry
@Component
struct SelectDepartment {
  @State departmentList: Department[] = [];
  @State filteredList: Department[] = [];
  @State searchText: string = '';
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  aboutToAppear() {
    this.loadDepartments();
  }

  async loadDepartments() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      console.log('开始获取科室列表...');
      const departments = await DepartmentApi.getAllDepartments();

      if (departments.length === 0) {
        console.log('未获取到科室数据');
        this.errorMessage = '暂无科室数据，请稍后重试';
        this.departmentList = [];
        this.filteredList = [];
      } else {
        console.log('获取到科室数量: ' + departments.length);
        this.departmentList = departments;
        this.filteredList = departments;
      }
    } catch (error) {
      console.error('加载科室失败: ' + JSON.stringify(error));
      this.errorMessage = '加载失败，请检查网络连接';
      this.departmentList = [];
      this.filteredList = [];
    } finally {
      this.isLoading = false;
    }
  }

  onSearchChange(value: string) {
    this.searchText = value;
    if (value === '') {
      this.filteredList = this.departmentList;
    } else {
      const newList: Department[] = [];
      for (let i = 0; i < this.departmentList.length; i++) {
        const dept = this.departmentList[i];
        if (dept.dept_name.indexOf(value) !== -1) {
          newList.push(dept);
        }
      }
      this.filteredList = newList;
    }
  }

  // 根据分类ID获取分类名称
  getCategoryName(categoryId: number): string {
    if (categoryId === 1) {
      return '内科';
    } else if (categoryId === 2) {
      return '外科';
    } else if (categoryId === 3) {
      return '妇产科';
    } else if (categoryId === 4) {
      return '儿科';
    } else if (categoryId === 5) {
      return '五官科';
    } else if (categoryId === 6) {
      return '皮肤科';
    } else if (categoryId === 7) {
      return '急诊科';
    } else if (categoryId === 8) {
      return '精神科';
    } else if (categoryId === 9) {
      return '医技科';
    } else if (categoryId === 10) {
      return '中医科';
    }
    return '其他';
  }

  // 根据分类ID返回对应图标
  getDepartmentIcon(categoryId: number): string {
    if (categoryId === 1) {
      return '🫀';
    } else if (categoryId === 2) {
      return '🔪';
    } else if (categoryId === 3) {
      return '👶';
    } else if (categoryId === 4) {
      return '🧒';
    } else if (categoryId === 5) {
      return '👁️';
    } else if (categoryId === 6) {
      return '🩹';
    } else if (categoryId === 7) {
      return '🚑';
    } else if (categoryId === 8) {
      return '🧠';
    } else if (categoryId === 9) {
      return '🔬';
    } else if (categoryId === 10) {
      return '🌿';
    }
    return '🏥';
  }

  // 刷新数据
  refreshData() {
    this.loadDepartments();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333')
          .onClick(() => {
            router.back();
          })
        Text('选择科室')
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
      .padding({ left: 15, right: 15, top: 12, bottom: 12 })
      .backgroundColor('#ffffff')

      // 搜索框
      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ left: 12 })
        TextInput({ placeholder: '搜索科室名称', text: this.searchText })
          .layoutWeight(1)
          .backgroundColor('transparent')
          .height(38)
          .onChange((value: string) => {
            this.onSearchChange(value);
          })
      }
      .width('90%')
      .backgroundColor('#f5f5f5')
      .borderRadius(20)
      .margin({ left: '5%', top: 15, bottom: 15 })

      // 内容区域
      if (this.isLoading) {
        // 加载中状态
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .margin({ bottom: 15 })
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMessage !== '' && this.departmentList.length === 0) {
        // 错误状态
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
          Button('重试')
            .width(100)
            .height(36)
            .fontSize(14)
            .backgroundColor('#1890ff')
            .borderRadius(18)
            .onClick(() => {
              this.refreshData();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.filteredList.length === 0) {
        // 空状态
        Column() {
          Text('📭')
            .fontSize(48)
            .opacity(0.5)
            .margin({ bottom: 15 })
          Text('未找到相关科室')
            .fontSize(15)
            .fontColor('#999')
          if (this.searchText !== '') {
            Button('清除搜索')
              .width(100)
              .height(36)
              .fontSize(14)
              .backgroundColor('#1890ff')
              .borderRadius(18)
              .margin({ top: 20 })
              .onClick(() => {
                this.searchText = '';
                this.onSearchChange('');
              })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 科室列表
        List() {
          ForEach(this.filteredList, (department: Department) => {
            ListItem() {
              this.DepartmentItem(department)
            }
          }, (department: Department) => department.dept_id.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0.5, color: '#eeeeee' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f8f8')
  }

  @Builder
  DepartmentItem(department: Department) {
    Row() {
      // 科室图标
      Text(this.getDepartmentIcon(department.category_id))
        .fontSize(32)
        .margin({ right: 12 })

      // 科室信息
      Column() {
        Text(department.dept_name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 })

        Row() {
          Text(this.getCategoryName(department.category_id))
            .fontSize(10)
            .fontColor('#ffffff')
            .backgroundColor('#1890ff')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)

          Text(department.dept_code)
            .fontSize(11)
            .fontColor('#999')
            .margin({ left: 8 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 箭头
      Text('›')
        .fontSize(20)
        .fontColor('#ccc')
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#ffffff')
    .onClick(() => {
      router.pushUrl({
        url: 'pages/SelectDoctor',
        params: {
          departmentId: department.dept_id,
          departmentName: department.dept_name
        }
      });
    })
  }
}