import request from './request'

// 获取计划列表
export const getPlans = (params) => {
  return request({
    url: '/plans',
    method: 'get',
    params
  })
}

// 获取计划详情
export const getPlanDetail = (id) => {
  return request({
    url: `/plans/${id}`,
    method: 'get'
  })
}

// 创建计划
export const createPlan = (data) => {
  return request({
    url: '/plans',
    method: 'post',
    data
  })
}

// 更新计划
export const updatePlan = (id, data) => {
  return request({
    url: `/plans/${id}`,
    method: 'put',
    data
  })
}

// 删除计划
export const deletePlan = (id) => {
  return request({
    url: `/plans/${id}`,
    method: 'delete'
  })
}

// 更新计划状态
export const updatePlanStatus = (id, status) => {
  return request({
    url: `/plans/${id}/status`,
    method: 'put',
    data: { status }
  })
}

// 添加计划评价
export const addPlanReview = (planId, data) => {
  return request({
    url: `/plans/${planId}/reviews`,
    method: 'post',
    data
  })
}

// 获取计划评价列表
export const getPlanReviews = (planId) => {
  return request({
    url: `/plans/${planId}/reviews`,
    method: 'get'
  })
}

// 分享计划
export const sharePlan = (id) => {
  return request({
    url: `/plans/${id}/share`,
    method: 'post'
  })
}

// 取消分享计划
export const unsharePlan = (id) => {
  return request({
    url: `/plans/${id}/unshare`,
    method: 'post'
  })
}
