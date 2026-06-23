// common/api/ScheduleApi.ets
import http from '@ohos.net.http';
import { API_BASE_URL } from '../constants/Constants';
import { PreferencesUtil } from '../utils/PreferencesUtil';

// 排班号源接口 - 匹配API实际返回的字段
export interface Schedule {
  dynamic_id: number;
  doc_id: number;
  doc_name: string;
  sch_date: string;
  period: string;        // "AM" 或 "PM"
  time_slot: string;     // "08:00-09:00"
  remaining_quota: number;
  total_quota: number;
  sch_id: number;
  status: number;
  fee?: number;          // 可选，API可能没有返回
}

// 定义API响应格式
interface ScheduleListResponse {
  code: number;
  message: string;
  data: Schedule[] | null;
}

export class ScheduleApi {
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

  // 按医生和日期查询号源
  static async getSchedulesByDoctor(docId: number, schDate: string): Promise<Schedule[]> {
    const httpRequest = http.createHttp();
    try {
      const headers = await ScheduleApi.buildHeaders();

      const url = `${API_BASE_URL}/api/schedule/listByDoctor?doc_id=${docId}&sch_date=${schDate}`;
      console.log(`请求号源URL: ${url}`);

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: headers,
        connectTimeout: 15000,
        readTimeout: 15000
      });

      console.log(`Schedule API responseCode: ${response.responseCode}`);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as ScheduleListResponse;
        console.log(`Schedule API code: ${result.code}`);

        if (result.code === 200 && result.data !== null && Array.isArray(result.data)) {
          const schedules = result.data as Schedule[];
          console.log(`获取到号源数量: ${schedules.length}`);

          // 为每个号源添加默认费用（如果API没有返回fee）
          for (let i = 0; i < schedules.length; i++) {
            const slot = schedules[i];
            console.log(`号源 ${i + 1}: ${slot.time_slot}, 剩余: ${slot.remaining_quota}, 总: ${slot.total_quota}`);
            if (slot.fee === undefined) {
              slot.fee = 50; // 默认挂号费
            }
          }
          return schedules;
        }
      }
      return [];
    } catch (error) {
      console.error('获取号源异常: ' + JSON.stringify(error));
      return [];
    } finally {
      httpRequest.destroy();
    }
  }
}