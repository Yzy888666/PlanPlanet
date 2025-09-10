import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login, logout, getUserInfo } from '@/api/auth'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref({})
  const username = ref('')
  const avatar = ref('')
  const email = ref('')

  // 登录
  const loginUser = async (loginForm) => {
    try {
      const response = await login(loginForm)
      token.value = response.data.token
      localStorage.setItem('token', token.value)
      
      // 获取用户信息
      await fetchUserInfo()
      
      return response
    } catch (error) {
      throw error
    }
  }

  // 获取用户信息
  const fetchUserInfo = async () => {
    try {
      const response = await getUserInfo()
      userInfo.value = response.data
      username.value = response.data.username
      avatar.value = response.data.avatar
      email.value = response.data.email
    } catch (error) {
      console.error('获取用户信息失败:', error)
    }
  }

  // 登出
  const logoutUser = async () => {
    try {
      await logout()
    } catch (error) {
      console.error('登出失败:', error)
    } finally {
      token.value = ''
      userInfo.value = {}
      username.value = ''
      avatar.value = ''
      email.value = ''
      localStorage.removeItem('token')
    }
  }

  // 检查是否已登录
  const isLoggedIn = computed(() => !!token.value)

  return {
    token,
    userInfo,
    username,
    avatar,
    email,
    isLoggedIn,
    login: loginUser,
    logout: logoutUser,
    fetchUserInfo
  }
})
