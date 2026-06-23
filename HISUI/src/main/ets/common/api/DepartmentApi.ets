// common/api/DepartmentApi.ets
import http from '@ohos.net.http';
import { API_BASE_URL } from '../constants/Constants';
import { PreferencesUtil } from '../utils/PreferencesUtil';

export interface Department {
  dept_id: number;
  dept_name: string;
  dept_code: string;
  category_id: number;
  sort_order: number;
  is_deleted?: number;
}

interface DepartmentResponse {
  success: boolean;
  data: Department[] | null;
  message?: string;
}

export class DepartmentApi {
  // 获取所有科室 - 添加认证头
  static async getAllDepartments(): Promise<Department[]> {
    const httpRequest = http.createHttp();
    try {
      // 获取token和userId
      const token = await PreferencesUtil.getToken();
      const userId = await PreferencesUtil.getUserId();

      console.log('Department API - userId: ' + userId);
      console.log('Department API - token exists: ' + (token !== ''));

      // 构建请求头
      const headers: Record<string, string> = {
        'Connection': 'keep-alive',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br',
        'Content-Type': 'application/json'
      };

      // 如果有token，添加Authorization头
      if (token !== '') {
        headers['Authorization'] = token;
      }

      // 如果有userId，添加userId头
      if (userId !== 0) {
        headers['userId'] = userId.toString();
      }

      const response = await httpRequest.request(`${API_BASE_URL}/api/department/all`, {
        method: http.RequestMethod.GET,
        header: headers,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      console.log('Department API responseCode: ' + response.responseCode);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as DepartmentResponse;
        console.log('Department API success: ' + result.success);

        if (result.success && result.data) {
          console.log('获取到科室数量: ' + result.data.length);
          return result.data;
        }
      }
      return [];
    } catch (error) {
      console.error('获取科室列表异常: ' + JSON.stringify(error));
      return [];
    } finally {
      httpRequest.destroy();
    }
  }

  // 按名称搜索科室 - 添加认证头
  static async searchDepartments(deptName: string): Promise<Department[]> {
    const httpRequest = http.createHttp();
    try {
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

      const response = await httpRequest.request(`${API_BASE_URL}/api/department/search?dept_name=${encodeURIComponent(deptName)}`, {
        method: http.RequestMethod.GET,
        header: headers,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as DepartmentResponse;
        if (result.success && result.data) {
          return result.data;
        }
      }
      return [];
    } catch (error) {
      console.error('搜索科室异常: ' + JSON.stringify(error));
      return [];
    } finally {
      httpRequest.destroy();
    }
  }
}