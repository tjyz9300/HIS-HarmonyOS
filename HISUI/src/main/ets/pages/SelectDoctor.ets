// pages/SelectDoctor.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { DoctorApi, Doctor } from '../common/api/DoctorApi';
import { ScheduleApi, Schedule } from '../common/api/ScheduleApi';

interface WeekDay {
  dateStr: string;
  weekDay: string;
  fullDate: string;
}

@Entry
@Component
struct SelectDoctor {
  @State currentDate: Date = new Date();
  @State weekDays: WeekDay[] = [];
  @State selectedDate: string = '';
  @State doctorList: Doctor[] = [];
  @State scheduleMap: Record<string, Schedule[]> = {};
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  private departmentId: number = 0;
  private departmentName: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.departmentId = params['departmentId'] as number;
    this.departmentName = params['departmentName'] as string;
    console.log(`进入选择医生页面 - 科室ID: ${this.departmentId}, 科室名称: ${this.departmentName}`);
    this.initWeekDays();
    this.loadDoctors();
  }

  initWeekDays() {
    const newWeekDays: WeekDay[] = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(this.currentDate);
      date.setDate(date.getDate() + i);
      const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;
      const weekDay = this.getWeekDay(date.getDay());
      const fullDate = this.formatDate(date);
      newWeekDays.push({ dateStr, weekDay, fullDate });
    }
    this.weekDays = newWeekDays;
    this.selectedDate = this.weekDays[0].fullDate;
    console.log(`初始化日期 - 选中日期: ${this.selectedDate}`);
  }

  getWeekDay(day: number): string {
    const weekMap = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekMap[day];
  }

  formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const monthStr = month < 10 ? '0' + month : '' + month;
    const dayStr = day < 10 ? '0' + day : '' + day;
    return `${year}-${monthStr}-${dayStr}`;
  }

  async loadDoctors() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      console.log(`开始获取科室 ${this.departmentId} 的医生列表`);
      const doctors = await DoctorApi.getDoctorsByDepartment(this.departmentId);
      console.log(`获取到医生数量: ${doctors.length}`);

      if (doctors.length === 0) {
        this.errorMessage = '该科室暂无医生数据';
        this.doctorList = [];
        this.isLoading = false;
        return;
      }

      this.doctorList = doctors;

      // 加载每个医生的号源
      await this.loadSchedulesForDoctors(doctors);

    } catch (error) {
      console.error('加载医生列表失败: ' + JSON.stringify(error));
      this.errorMessage = '加载失败，请检查网络连接';
    } finally {
      this.isLoading = false;
    }
  }

  async loadSchedulesForDoctors(doctors: Doctor[]) {
    const newScheduleMap: Record<string, Schedule[]> = {};

    for (let i = 0; i < doctors.length; i++) {
      const doctor = doctors[i];
      console.log(`获取医生 ${doctor.name} 在 ${this.selectedDate} 的号源`);
      const schedules = await ScheduleApi.getSchedulesByDoctor(doctor.doc_id, this.selectedDate);
      newScheduleMap[doctor.doc_id.toString()] = schedules;
      console.log(`医生 ${doctor.name} 号源数量: ${schedules.length}`);
    }

    this.scheduleMap = newScheduleMap;
  }

  async onDateChange(index: number) {
    this.selectedDate = this.weekDays[index].fullDate;
    console.log(`切换日期: ${this.selectedDate}`);
    this.isLoading = true;

    if (this.doctorList.length > 0) {
      await this.loadSchedulesForDoctors(this.doctorList);
    }

    this.isLoading = false;
  }

  // 修复：安全获取号源列表
  getSchedulesForDoctor(doctorId: number): Schedule[] {
    const schedules = this.scheduleMap[doctorId.toString()];
    if (schedules !== undefined && schedules !== null) {
      return schedules;
    }
    return [];
  }

  // 修复：判断是否有号源
  hasSchedule(doctorId: number): boolean {
    const schedules = this.getSchedulesForDoctor(doctorId);
    return schedules.length > 0;
  }

  // 修复：获取挂号费
  getScheduleFee(doctorId: number): number {
    const schedules = this.getSchedulesForDoctor(doctorId);
    if (schedules.length > 0 && schedules[0] && schedules[0].fee !== undefined) {
      return schedules[0].fee;
    }
    return 50; // 默认挂号费
  }

  getTitleName(title: number): string {
    return DoctorApi.getTitleName(title);
  }

  formatDateForDisplay(dateStr: string): string {
    const parts = dateStr.split('-');
    if (parts.length === 3) {
      return `${parts[1]}月${parts[2]}日`;
    }
    return dateStr;
  }

  refreshData() {
    this.loadDoctors();
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333')
          .onClick(() => router.back())
        Text('选择医生')
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

      // 科室名称
      Text(this.departmentName)
        .fontSize(14)
        .fontColor('#1890ff')
        .padding(10)
        .backgroundColor('#e6f7ff')
        .borderRadius(15)
        .margin({ left: 15, top: 10, bottom: 10 })

      // 日期选择器
      Scroll() {
        Row() {
          ForEach(this.weekDays, (day: WeekDay, index: number) => {
            Column() {
              Text(day.weekDay)
                .fontSize(12)
                .fontColor(this.selectedDate === day.fullDate ? '#ffffff' : '#666')
              Text(day.dateStr)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 5 })
                .fontColor(this.selectedDate === day.fullDate ? '#ffffff' : '#333')
            }
            .width(50)
            .height(60)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedDate === day.fullDate ? '#1890ff' : '#f5f5f5')
            .borderRadius(10)
            .margin({ left: 8, right: 8 })
            .onClick(() => this.onDateChange(index))
          })
        }
        .padding({ left: 10, right: 10 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(80)
      .margin({ top: 10, bottom: 20 })

      // 内容区域
      if (this.isLoading) {
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
      } else if (this.errorMessage !== '' && this.doctorList.length === 0) {
        Column() {
          Text('⚠️')
            .fontSize(48)
            .opacity(0.5)
            .margin({ bottom: 15 })
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#999')
            .margin({ bottom: 20 })
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
      } else if (this.doctorList.length === 0) {
        Column() {
          Text('📋')
            .fontSize(48)
            .opacity(0.5)
            .margin({ bottom: 15 })
          Text('暂无医生数据')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.doctorList, (doctor: Doctor) => {
            ListItem() {
              this.DoctorItem(doctor)
            }
          }, (doctor: Doctor) => doctor.doc_id.toString())
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
  DoctorItem(doctor: Doctor) {
    Row() {
      Column() {
        Text(doctor.gender === 1 ? '👨‍⚕️' : '👩‍⚕️')
          .fontSize(40)
      }
      .margin({ right: 12 })

      Column() {
        Row() {
          Text(doctor.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Text(this.getTitleName(doctor.title))
            .fontSize(12)
            .fontColor('#1890ff')
            .backgroundColor('#e6f7ff')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(10)
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 5 })

        Text(doctor.resume || '擅长：常见病诊治')
          .fontSize(12)
          .fontColor('#999')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text('📚')
            .fontSize(10)
            .margin({ right: 2 })
          Text(doctor.education || '本科')
            .fontSize(11)
            .fontColor('#666')
          Text('  ')
          Text('📞')
            .fontSize(10)
            .margin({ right: 2 })
          Text(doctor.phone || '')
            .fontSize(11)
            .fontColor('#666')
        }
        .margin({ top: 4 })

        if (this.hasSchedule(doctor.doc_id)) {
          Row() {
            Text('💰')
              .fontSize(10)
              .margin({ right: 2 })
            Text(`挂号费: ¥${this.getScheduleFee(doctor.doc_id)}`)
              .fontSize(11)
              .fontColor('#faad14')
          }
          .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.hasSchedule(doctor.doc_id)) {
        Column() {
          Text('✓')
            .fontSize(14)
            .fontColor('#52c41a')
            .fontWeight(FontWeight.Bold)
          Text('有号')
            .fontSize(11)
            .fontColor('#52c41a')
        }
        .margin({ right: 10 })
      } else {
        Column() {
          Text('✗')
            .fontSize(14)
            .fontColor('#ff4d4f')
            .fontWeight(FontWeight.Bold)
          Text('无号')
            .fontSize(11)
            .fontColor('#ff4d4f')
        }
        .margin({ right: 10 })
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#ffffff')
    .onClick(() => {
      if (this.hasSchedule(doctor.doc_id)) {
        console.log(`选择医生: ${doctor.name}, ID: ${doctor.doc_id}`);
        router.pushUrl({
          url: 'pages/SelectTimeSlot',
          params: {
            doctorId: doctor.doc_id,
            doctorName: doctor.name,
            doctorTitle: this.getTitleName(doctor.title),
            departmentName: this.departmentName,
            selectedDate: this.selectedDate
          }
        });
      } else {
        promptAction.showToast({
          message: '该医生当天无号源',
          duration: 1500
        });
      }
    })
  }
}