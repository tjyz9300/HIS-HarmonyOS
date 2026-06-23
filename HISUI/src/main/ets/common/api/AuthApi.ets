// common/api/AuthApi.ets
import http from '@ohos.net.http';
import { API_BASE_URL, Result, LoginRequest, LoginResponse, RegisterRequest } from '../../model/Types';

export class AuthApi {
  static async login(request: LoginRequest): Promise<Result<LoginResponse>> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(`${API_BASE_URL}/api/auth/login`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(request)
      });
      const result = JSON.parse(response.result as string) as Result<LoginResponse>;
      return result;
    } catch (error) {
      return { code: 500, message: '网络错误', data: null };
    } finally {
      httpRequest.destroy();
    }
  }

  static async register(request: RegisterRequest): Promise<Result<null>> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(`${API_BASE_URL}/api/auth/register`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(request)
      });
      const result = JSON.parse(response.result as string) as Result<null>;
      return result;
    } catch (error) {
      return { code: 500, message: '网络错误', data: null };
    } finally {
      httpRequest.destroy();
    }
  }
}