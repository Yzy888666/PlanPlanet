import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { 
  getPlans, 
  getPlanDetail, 
  createPlan, 
  updatePlan, 
  deletePlan,
  updatePlanStatus,
  addPlanReview
} from '@/api/plans'

export const usePlansStore = defineStore('plans', () => {
  const plans = ref([])
  const currentPlan = ref(null)
  const loading = ref(false)
  const total = ref(0)

  // 计算属性
  const dailyPlans = computed(() => 
    plans.value.filter(plan => plan.type === 'daily')
  )
  
  const weeklyPlans = computed(() => 
    plans.value.filter(plan => plan.type === 'weekly')
  )
  
  const monthlyPlans = computed(() => 
    plans.value.filter(plan => plan.type === 'monthly')
  )

  const completedPlans = computed(() => 
    plans.value.filter(plan => plan.status === 'completed')
  )

  const inProgressPlans = computed(() => 
    plans.value.filter(plan => plan.status === 'in_progress')
  )

  // 获取计划列表
  const fetchPlans = async (params = {}) => {
    loading.value = true
    try {
      const response = await getPlans(params)
      plans.value = response.data.list
      total.value = response.data.total
    } catch (error) {
      console.error('获取计划列表失败:', error)
    } finally {
      loading.value = false
    }
  }

  // 获取计划详情
  const fetchPlanDetail = async (id) => {
    loading.value = true
    try {
      const response = await getPlanDetail(id)
      currentPlan.value = response.data
      return response.data
    } catch (error) {
      console.error('获取计划详情失败:', error)
    } finally {
      loading.value = false
    }
  }

  // 创建计划
  const createNewPlan = async (planData) => {
    try {
      const response = await createPlan(planData)
      plans.value.unshift(response.data)
      return response.data
    } catch (error) {
      console.error('创建计划失败:', error)
      throw error
    }
  }

  // 更新计划
  const updateExistingPlan = async (id, planData) => {
    try {
      const response = await updatePlan(id, planData)
      const index = plans.value.findIndex(plan => plan.id === id)
      if (index !== -1) {
        plans.value[index] = response.data
      }
      if (currentPlan.value?.id === id) {
        currentPlan.value = response.data
      }
      return response.data
    } catch (error) {
      console.error('更新计划失败:', error)
      throw error
    }
  }

  // 删除计划
  const removePlan = async (id) => {
    try {
      await deletePlan(id)
      plans.value = plans.value.filter(plan => plan.id !== id)
      if (currentPlan.value?.id === id) {
        currentPlan.value = null
      }
    } catch (error) {
      console.error('删除计划失败:', error)
      throw error
    }
  }

  // 更新计划状态
  const changePlanStatus = async (id, status) => {
    try {
      await updatePlanStatus(id, status)
      const plan = plans.value.find(p => p.id === id)
      if (plan) {
        plan.status = status
      }
      if (currentPlan.value?.id === id) {
        currentPlan.value.status = status
      }
    } catch (error) {
      console.error('更新计划状态失败:', error)
      throw error
    }
  }

  // 添加计划评价
  const addReview = async (planId, reviewData) => {
    try {
      const response = await addPlanReview(planId, reviewData)
      if (currentPlan.value?.id === planId) {
        if (!currentPlan.value.reviews) {
          currentPlan.value.reviews = []
        }
        currentPlan.value.reviews.push(response.data)
      }
      return response.data
    } catch (error) {
      console.error('添加评价失败:', error)
      throw error
    }
  }

  // 重置状态
  const resetState = () => {
    plans.value = []
    currentPlan.value = null
    loading.value = false
    total.value = 0
  }

  return {
    plans,
    currentPlan,
    loading,
    total,
    dailyPlans,
    weeklyPlans,
    monthlyPlans,
    completedPlans,
    inProgressPlans,
    fetchPlans,
    fetchPlanDetail,
    createNewPlan,
    updateExistingPlan,
    removePlan,
    changePlanStatus,
    addReview,
    resetState
  }
})
