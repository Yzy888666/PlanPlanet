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

// ========== 计划广场相关API ==========

// 获取公共计划列表（计划广场）
export const getPublicPlans = (params) => {
  return request({
    url: '/square/plans',
    method: 'get',
    params
  })
}

// 获取广场计划详情
export const getSquarePlanDetail = (id) => {
  return request({
    url: `/square/plans/${id}`,
    method: 'get'
  })
}

// 点赞计划
export const likePlan = (id) => {
  return request({
    url: `/square/plans/${id}/like`,
    method: 'post'
  })
}

// 取消点赞计划
export const unlikePlan = (id) => {
  return request({
    url: `/square/plans/${id}/unlike`,
    method: 'post'
  })
}

// 收藏计划
export const favoritePlan = (id) => {
  return request({
    url: `/square/plans/${id}/favorite`,
    method: 'post'
  })
}

// 取消收藏计划
export const unfavoritePlan = (id) => {
  return request({
    url: `/square/plans/${id}/unfavorite`,
    method: 'post'
  })
}

// 复制计划到我的计划
export const copyPlan = (id) => {
  return request({
    url: `/square/plans/${id}/copy`,
    method: 'post'
  })
}
