// common/api/AppointmentApi.ets
import http from '@ohos.net.http';
import { API_BASE_URL } from '../constants/Constants';
import { Appointment, Result, CreateAppointmentRequest } from '../../model/Types';
import { PreferencesUtil } from '../utils/PreferencesUtil';

export class AppointmentApi {
  static async getUserAppointments(): Promise<Appointment[]> {
    const userId = await PreferencesUtil.getUserId();
    const token = await PreferencesUtil.getToken();

    if (!userId || !token) {
      console.log('用户未登录，无法获取挂号记录');
      return [];
    }

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(`${API_BASE_URL}/api/appointment/list/${userId}`, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'authorization': token,
          'userId': userId.toString()
        },
        connectTimeout: 10000,
        readTimeout: 10000
      });

      console.log('Appointment API responseCode: ' + response.responseCode);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as Result<Appointment[]>;
        if (result.code === 200 && result.data) {
          console.log('获取到挂号记录数量: ' + result.data.length);
          return result.data;
        }
      }
      return [];
    } catch (error) {
      console.error('获取挂号记录异常: ' + JSON.stringify(error));
      return [];
    } finally {
      httpRequest.destroy();
    }
  }

  static async createAppointment(request: CreateAppointmentRequest): Promise<Result<null>> {
    const userId = await PreferencesUtil.getUserId();
    const token = await PreferencesUtil.getToken();

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(`${API_BASE_URL}/api/appointment/create/${userId}`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'authorization': token,
          'userId': userId.toString()
        },
        extraData: JSON.stringify(request),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      console.log('Create Appointment responseCode: ' + response.responseCode);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as Result<null>;
        return result;
      }
      return { code: 500, message: '请求失败', data: null };
    } catch (error) {
      console.error('创建挂号异常: ' + JSON.stringify(error));
      return { code: 500, message: '网络错误', data: null };
    } finally {
      httpRequest.destroy();
    }
  }

  static async cancelAppointment(appId: number): Promise<Result<null>> {
    const userId = await PreferencesUtil.getUserId();
    const token = await PreferencesUtil.getToken();

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(`${API_BASE_URL}/api/appointment/cancel/${userId}/${appId}`, {
        method: http.RequestMethod.PUT,
        header: {
          'Content-Type': 'application/json',
          'authorization': token,
          'userId': userId.toString()
        },
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as Result<null>;
        return result;
      }
      return { code: 500, message: '请求失败', data: null };
    } catch (error) {
      console.error('取消挂号异常: ' + JSON.stringify(error));
      return { code: 500, message: '网络错误', data: null };
    } finally {
      httpRequest.destroy();
    }
  }
}