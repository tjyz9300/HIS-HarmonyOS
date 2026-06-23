// model/Types.ets

// 响应类型 - 风格一 Result<T>
export interface Result<T> {
  code: number;
  message: string;
  data: T | null;
}

// 响应类型 - 风格二 Map
export interface MapResponse {
  success: boolean;
  message: string;
  data: object | null;
}

// 科室
export interface Department {
  dept_id: number;
  dept_name: string;
  dept_code: string;
  category_id: number;
  sort_order: number;
  is_deleted?: number;
}

// 科室分类
export interface DeptCategory {
  category_id: number;
  category_name: string;
  sort_order: number;
}

export interface Doctor {
  doc_id: number;
  name: string;
  work_no: string;
  gender: number;
  title: number;  // 职称代码
  dept_id: number;
  phone: string;
  email: string;
  education: string;
  resume: string;
  hire_time: string;
  address: string;
  status: number;  // 1=正常，2=已删除
  type: number;    // 医生类型
}

// 排班号源接口
export interface Schedule {
  dynamic_id: number;
  doc_id: number;
  doc_name: string;
  sch_date: string;
  start_time: string;
  end_time: string;
  period: number;      // 时段：1=上午，2=下午
  total_num: number;   // 总号源数
  remain_num: number;  // 剩余号源数
  fee: number;         // 挂号费
}

// 医生详情（包含科室名称）
export interface DoctorDetail extends Doctor {
  dept_name: string;
  title_name: string;
  fee: number;
}

// 职称映射
export const TITLE_MAP: Record<number, string> = {
  1: '住院医师',
  2: '主治医师',
  3: '副主任医师',
  4: '主任医师'
};

// 时段映射
export const PERIOD_MAP: Record<number, string> = {
  1: '上午',
  2: '下午',
  3: '晚上'
};

// 时间段
export interface TimeSlot {
  id: number;
  startTime: string;
  endTime: string;
  remainingCount: number;
  isAvailable: boolean;
}


// 就诊人
export interface Patient {
  pat_id: number;
  name: string;
  gender: number;
  id_card: string;
  phone: string;
}

// 挂号记录
export interface Appointment {
  app_id: number;
  pat_id: number;
  pat_name: string;
  app_no: string;
  fee: number;
  status: number;
  statusText: string;
  create_time: string;
  sch_date?: string;
  start_time?: string;
  end_time?: string;
  dept_name?: string;
  doc_name?: string;
}

// 就诊记录
export interface Visit {
  visit_id: number;
  pat_name: string;
  visit_time: string;
  diagnosis: string;
  prescription: string;
  status: string;
  remarks: string;
}

// 登录请求
export interface LoginRequest {
  phone: string;
  password: string;
}

// 登录响应
export interface LoginResponse {
  user_id: number;
  token: string;
}

// 注册请求
export interface RegisterRequest {
  phone: string;
  password: string;
}

// 添加就诊人请求
export interface AddPatientRequest {
  name: string;
  phone: string;
  id_card: string;
}

// 创建挂号请求
export interface CreateAppointmentRequest {
  pat_id: number;
  pat_name: string;
  dynamic_id: number;
  app_type: number;
  fee: number;
}

// 常量定义
export const API_BASE_URL = 'http://www.921302.xyz:8080'; // 模拟器访问宿主机

interface GeneratedObjectLiteralInterface_1 {
  BOOKED: number;
  CANCELLED: number;
  VISITED: number;
}

export const APPOINTMENT_STATUS: GeneratedObjectLiteralInterface_1 = {
  BOOKED: 1,    // 已挂号
  CANCELLED: 2, // 已取消
  VISITED: 3    // 已就诊
};

export const APPOINTMENT_STATUS_TEXT: Record<number, string> = {
  1: '已挂号',
  2: '已取消',
  3: '已就诊'
};