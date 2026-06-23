// common/api/DoctorApi.ets
import http from '@ohos.net.http';
import { API_BASE_URL } from '../constants/Constants';
import { PreferencesUtil } from '../utils/PreferencesUtil';

// 医生接口 - 匹配API返回的实际字段
export interface Doctor {
  doc_id: number;
  name: string;
  work_no: string;
  gender: number;
  title: number;
  dept_id: number;
  phone: string;
  email: string;
  education: string;
  resume: string;
  hire_time: string;
  address: string;
  status: number;
  type: number;
}

// 职称映射
const TITLE_MAP: Record<number, string> = {
  1: '住院医师',
  2: '主治医师',
  3: '副主任医师',
  4: '主任医师'
};

// 定义API响应格式 - 根据实际返回
interface DoctorListResponse {
  success: boolean;
  data: Doctor[] | null;
  message?: string;
}

export class DoctorApi {
  // 构建通用请求头
  private static async buildHeaders(): Promise<Record<string, string>> {
    const token = await PreferencesUtil.getToken();
    const userId = await PreferencesUtil.getUserId();

    const headers: Record<string, string> = {
      'Connection': 'keep-alive',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Content-Type': 'application/json'
    };

    if (token !== '') {
      headers['Authorization'] = token;
    }

    if (userId !== 0) {
      headers['userId'] = userId.toString();
    }

    return headers;
  }

  // 按科室获取医生
  static async getDoctorsByDepartment(deptId: number): Promise<Doctor[]> {
    const httpRequest = http.createHttp();
    try {
      const headers = await DoctorApi.buildHeaders();

      console.log(`请求医生列表 - 科室ID: ${deptId}`);
      console.log(`请求URL: ${API_BASE_URL}/api/doctor/dept/${deptId}`);

      const response = await httpRequest.request(`${API_BASE_URL}/api/doctor/dept/${deptId}`, {
        method: http.RequestMethod.GET,
        header: headers,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      console.log(`Doctor API responseCode: ${response.responseCode}`);
      console.log(`Doctor API response: ${response.result}`);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as DoctorListResponse;
        console.log(`Doctor API success: ${result.success}`);

        if (result.success && result.data) {
          const doctors = result.data as Doctor[];
          console.log(`获取到医生数量: ${doctors.length}`);
          if (doctors.length > 0) {
            console.log(`第一个医生: ${JSON.stringify(doctors[0])}`);
          }
          return doctors;
        }
      }
      console.log('未获取到医生数据');
      return [];
    } catch (error) {
      console.error('按科室获取医生异常: ' + JSON.stringify(error));
      return [];
    } finally {
      httpRequest.destroy();
    }
  }

  // 获取职称名称
  static getTitleName(title: number): string {
    if (title === 1) {
      return '住院医师';
    } else if (title === 2) {
      return '主治医师';
    } else if (title === 3) {
      return '副主任医师';
    } else if (title === 4) {
      return '主任医师';
    }
    return '医师';
  }

  // 获取性别文本
  static getGenderText(gender: number): string {
    return gender === 1 ? '男' : '女';
  }
}