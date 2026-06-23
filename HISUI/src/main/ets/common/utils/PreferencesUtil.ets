// common/utils/PreferencesUtil.ets
import preferences from '@ohos.data.preferences';

const PREFERENCES_NAME = 'his_prefs';
const KEY_TOKEN = 'token';
const KEY_USER_ID = 'userId';
const KEY_USER_NAME = 'userName';
const KEY_USER_PHONE = 'userPhone';

export class PreferencesUtil {
  private static prefs: preferences.Preferences | null = null;

  static async init(context: Context): Promise<void> {
    if (PreferencesUtil.prefs === null) {
      PreferencesUtil.prefs = await preferences.getPreferences(context, PREFERENCES_NAME);
    }
  }

  static async put(key: string, value: string): Promise<void> {
    if (PreferencesUtil.prefs !== null) {
      await PreferencesUtil.prefs.put(key, value);
      await PreferencesUtil.prefs.flush();
    }
  }

  static async putNumber(key: string, value: number): Promise<void> {
    if (PreferencesUtil.prefs !== null) {
      await PreferencesUtil.prefs.put(key, value);
      await PreferencesUtil.prefs.flush();
    }
  }

  static async get(key: string, defaultValue: string): Promise<string> {
    if (PreferencesUtil.prefs !== null) {
      return await PreferencesUtil.prefs.get(key, defaultValue) as string;
    }
    return defaultValue;
  }

  static async getNumber(key: string, defaultValue: number): Promise<number> {
    if (PreferencesUtil.prefs !== null) {
      return await PreferencesUtil.prefs.get(key, defaultValue) as number;
    }
    return defaultValue;
  }

  static async clear(): Promise<void> {
    if (PreferencesUtil.prefs !== null) {
      await PreferencesUtil.prefs.clear();
      await PreferencesUtil.prefs.flush();
    }
  }

  static async saveLoginInfo(userId: number, token: string, userName: string, userPhone: string): Promise<void> {
    await PreferencesUtil.putNumber(KEY_USER_ID, userId);
    await PreferencesUtil.put(KEY_TOKEN, token);
    await PreferencesUtil.put(KEY_USER_NAME, userName);
    await PreferencesUtil.put(KEY_USER_PHONE, userPhone);
  }

  static async getToken(): Promise<string> {
    return await PreferencesUtil.get(KEY_TOKEN, '');
  }

  static async getUserId(): Promise<number> {
    return await PreferencesUtil.getNumber(KEY_USER_ID, 0);
  }

  static async getUserName(): Promise<string> {
    return await PreferencesUtil.get(KEY_USER_NAME, '');
  }

  static async getUserPhone(): Promise<string> {
    return await PreferencesUtil.get(KEY_USER_PHONE, '');
  }

  static async isLoggedIn(): Promise<boolean> {
    const token = await PreferencesUtil.getToken();
    return token !== '';
  }
}