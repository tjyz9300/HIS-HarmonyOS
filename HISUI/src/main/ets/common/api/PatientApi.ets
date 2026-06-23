// common/api/PatientApi.ets
import http from '@ohos.net.http';
import { API_BASE_URL } from '../constants/Constants';
import { Patient, Result, AddPatientRequest } from '../../model/Types';
import { PreferencesUtil } from '../utils/PreferencesUtil';

export class PatientApi {
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

    console.log('PatientApi headers - userId: ' + userId);
    console.log('PatientApi headers - token exists: ' + (token !== ''));

    return headers;
  }

  // 获取就诊人列表
  static async getPatientList(): Promise<Patient[]> {
    const userId = await PreferencesUtil.getUserId();
    const token = await PreferencesUtil.getToken();

    if (!userId || !token) {
      console.log('用户未登录，无法获取就诊人列表');
      return [];
    }

    const httpRequest = http.createHttp();
    try {
      const headers = await PatientApi.buildHeaders();

      const response = await httpRequest.request(`${API_BASE_URL}/api/patient/list/${userId}`, {
        method: http.RequestMethod.GET,
        header: headers,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      console.log('Patient API responseCode: ' + response.responseCode);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as Result<Patient[]>;
        console.log('Patient API result code: ' + result.code);

        if (result.code === 200 && result.data) {
          console.log('获取到就诊人数量: ' + result.data.length);
          return result.data;
        } else {
          console.log('获取就诊人失败: ' + result.message);
        }
      }
      return [];
    } catch (error) {
      console.error('获取就诊人列表异常: ' + JSON.stringify(error));
      return [];
    } finally {
      httpRequest.destroy();
    }
  }

  // 添加就诊人
  static async addPatient(request: AddPatientRequest): Promise<Result<null>> {
    const userId = await PreferencesUtil.getUserId();
    const token = await PreferencesUtil.getToken();

    if (!userId || !token) {
      console.log('用户未登录，无法添加就诊人');
      return { code: 401, message: '请先登录', data: null };
    }

    const httpRequest = http.createHttp();
    try {
      const headers = await PatientApi.buildHeaders();

      console.log('添加就诊人请求: ' + JSON.stringify(request));

      const response = await httpRequest.request(`${API_BASE_URL}/api/patient/add/${userId}`, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: JSON.stringify(request),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      console.log('Add Patient API responseCode: ' + response.responseCode);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as Result<null>;
        console.log('Add Patient API result code: ' + result.code);
        console.log('Add Patient API message: ' + result.message);
        return result;
      }
      return { code: response.responseCode, message: '请求失败', data: null };
    } catch (error) {
      console.error('添加就诊人异常: ' + JSON.stringify(error));
      return { code: 500, message: '网络错误', data: null };
    } finally {
      httpRequest.destroy();
    }
  }
}