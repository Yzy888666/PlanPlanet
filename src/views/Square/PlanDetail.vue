<template>
  <div class="square-plan-detail-page" v-loading="loading">
    <div v-if="plan" class="plan-detail-container">
      <!-- 返回按钮 -->
      <div class="back-button">
        <el-button @click="router.back()" type="text">
          <el-icon><ArrowLeft /></el-icon>
          返回广场
        </el-button>
      </div>

      <!-- 计划基本信息 -->
      <div class="plan-header">
        <div class="plan-title-section">
          <h1>{{ plan.title }}</h1>
          <div class="plan-tags">
            <el-tag :type="getPlanTypeColor(plan.type)" size="large">
              {{ getPlanTypeText(plan.type) }}
            </el-tag>
            <el-tag :type="getCategoryColor(plan.category)" size="large">
              {{ getCategoryText(plan.category) }}
            </el-tag>
            <el-tag :type="getPriorityColor(plan.priority)" size="large">
              {{ getPriorityText(plan.priority) }}
            </el-tag>
          </div>
        </div>

        <div class="plan-actions">
          <el-button
            :type="plan.isLiked ? 'primary' : 'default'"
            @click="toggleLike"
            :loading="liking"
          >
            <el-icon><Star /></el-icon>
            {{ plan.isLiked ? '已点赞' : '点赞' }} ({{ plan.likesCount || 0 }})
          </el-button>

          <el-button
            :type="plan.isFavorited ? 'warning' : 'default'"
            @click="toggleFavorite"
            :loading="favoriting"
          >
            <el-icon><Collection /></el-icon>
            {{ plan.isFavorited ? '已收藏' : '收藏' }} ({{ plan.favoritesCount || 0 }})
          </el-button>

          <el-button
            type="success"
            @click="copyPlanToMine"
            :loading="copying"
          >
            <el-icon><CopyDocument /></el-icon>
            复制到我的计划
          </el-button>
        </div>
      </div>

      <!-- 计划详细信息 -->
      <div class="plan-content">
        <div class="content-main">
          <!-- 计划描述 -->
          <div class="plan-description">
            <h3>计划描述</h3>
            <p>{{ plan.description || '暂无描述' }}</p>
          </div>

          <!-- 计划目标 -->
          <div class="plan-target" v-if="plan.targetCount">
            <h3>计划目标</h3>
            <div class="target-info">
              <div class="target-item">
                <span class="label">目标数量:</span>
                <span class="value">{{ plan.targetCount }}{{ plan.unit || '次' }}</span>
              </div>
              <div class="target-item" v-if="plan.startDate">
                <span class="label">开始时间:</span>
                <span class="value">{{ formatDate(plan.startDate) }}</span>
              </div>
              <div class="target-item" v-if="plan.endDate">
                <span class="label">结束时间:</span>
                <span class="value">{{ formatDate(plan.endDate) }}</span>
              </div>
            </div>
          </div>

          <!-- 分享说明 -->
          <div class="share-description" v-if="plan.shareDescription">
            <h3>分享说明</h3>
            <p>{{ plan.shareDescription }}</p>
          </div>

          <!-- 计划统计 -->
          <div class="plan-statistics">
            <h3>计划统计</h3>
            <div class="stats-grid">
              <div class="stat-card">
                <div class="stat-icon">
                  <el-icon><Star /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ plan.likesCount || 0 }}</div>
                  <div class="stat-label">点赞数</div>
                </div>
              </div>

              <div class="stat-card">
                <div class="stat-icon">
                  <el-icon><Collection /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ plan.favoritesCount || 0 }}</div>
                  <div class="stat-label">收藏数</div>
                </div>
              </div>

              <div class="stat-card">
                <div class="stat-icon">
                  <el-icon><CopyDocument /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ plan.copiesCount || 0 }}</div>
                  <div class="stat-label">复制数</div>
                </div>
              </div>

              <div class="stat-card">
                <div class="stat-icon">
                  <el-icon><View /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ plan.viewsCount || 0 }}</div>
                  <div class="stat-label">浏览数</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="content-sidebar">
          <!-- 作者信息 -->
          <div class="author-card">
            <h3>作者信息</h3>
            <div class="author-info">
              <div class="author-avatar">
                <el-avatar :size="60" :src="plan.author?.avatar">
                  {{ plan.author?.nickname?.[0] || plan.author?.username?.[0] || 'U' }}
                </el-avatar>
              </div>
              <div class="author-details">
                <div class="author-name">{{ plan.author?.nickname || plan.author?.username || '匿名用户' }}</div>
                <div class="author-meta">
                  <div>发布时间: {{ formatDate(plan.createdAt) }}</div>
                  <div v-if="plan.updatedAt !== plan.createdAt">
                    更新时间: {{ formatDate(plan.updatedAt) }}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 相关推荐 -->
          <div class="related-plans" v-if="relatedPlans.length > 0">
            <h3>相关推荐</h3>
            <div class="related-list">
              <div
                v-for="relatedPlan in relatedPlans"
                :key="relatedPlan.id"
                class="related-item"
                @click="router.push(`/square/${relatedPlan.id}`)"
              >
                <div class="related-title">{{ relatedPlan.title }}</div>
                <div class="related-meta">
                  <el-tag :type="getCategoryColor(relatedPlan.category)" size="small">
                    {{ getCategoryText(relatedPlan.category) }}
                  </el-tag>
                  <span class="related-stats">
                    <el-icon><Star /></el-icon>
                    {{ relatedPlan.likesCount || 0 }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="!loading" class="error-state">
      <el-result
        icon="warning"
        title="计划不存在"
        sub-title="该计划可能已被删除或设为私有"
      >
        <template #extra>
          <el-button type="primary" @click="router.push('/square')">
            返回广场
          </el-button>
        </template>
      </el-result>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  ArrowLeft,
  Star,
  Collection,
  CopyDocument,
  View
} from '@element-plus/icons-vue'
import {
  getSquarePlanDetail,
  getPublicPlans,
  likePlan,
  unlikePlan,
  favoritePlan,
  unfavoritePlan,
  copyPlan
} from '@/api/plans'
import dayjs from 'dayjs'

const route = useRoute()
const router = useRouter()

// 响应式数据
const loading = ref(false)
const plan = ref(null)
const relatedPlans = ref([])

// 操作状态
const liking = ref(false)
const favoriting = ref(false)
const copying = ref(false)

// 获取计划详情
const fetchPlanDetail = async () => {
  loading.value = true
  try {
    const planId = route.params.id
    const response = await getSquarePlanDetail(planId)
    plan.value = response.data

    // 获取相关推荐
    await fetchRelatedPlans()
  } catch (error) {
    ElMessage.error('获取计划详情失败')
    console.error('获取广场计划详情失败:', error)
  } finally {
    loading.value = false
  }
}

// 获取相关推荐
const fetchRelatedPlans = async () => {
  try {
    const params = {
      category: plan.value.category,
      type: plan.value.type,
      pageSize: 5,
      exclude: plan.value.id
    }
    const response = await getPublicPlans(params)
    relatedPlans.value = response.data.list || []
  } catch (error) {
    console.error('获取相关推荐失败:', error)
  }
}

// 切换点赞状态
const toggleLike = async () => {
  liking.value = true
  try {
    if (plan.value.isLiked) {
      await unlikePlan(plan.value.id)
      plan.value.isLiked = false
      plan.value.likesCount = Math.max(0, (plan.value.likesCount || 0) - 1)
      ElMessage.success('取消点赞成功')
    } else {
      await likePlan(plan.value.id)
      plan.value.isLiked = true
      plan.value.likesCount = (plan.value.likesCount || 0) + 1
      ElMessage.success('点赞成功')
    }
  } catch (error) {
    ElMessage.error(plan.value.isLiked ? '取消点赞失败' : '点赞失败')
  } finally {
    liking.value = false
  }
}

// 切换收藏状态
const toggleFavorite = async () => {
  favoriting.value = true
  try {
    if (plan.value.isFavorited) {
      await unfavoritePlan(plan.value.id)
      plan.value.isFavorited = false
      plan.value.favoritesCount = Math.max(0, (plan.value.favoritesCount || 0) - 1)
      ElMessage.success('取消收藏成功')
    } else {
      await favoritePlan(plan.value.id)
      plan.value.isFavorited = true
      plan.value.favoritesCount = (plan.value.favoritesCount || 0) + 1
      ElMessage.success('收藏成功')
    }
  } catch (error) {
    ElMessage.error(plan.value.isFavorited ? '取消收藏失败' : '收藏失败')
  } finally {
    favoriting.value = false
  }
}

// 复制计划到我的计划
const copyPlanToMine = async () => {
  try {
    await ElMessageBox.confirm(
      `确定要复制计划"${plan.value.title}"到我的计划吗？`,
      '确认复制',
      {
        confirmButtonText: '复制',
        cancelButtonText: '取消',
        type: 'info'
      }
    )

    copying.value = true
    await copyPlan(plan.value.id)
    plan.value.copiesCount = (plan.value.copiesCount || 0) + 1
    ElMessage.success('计划复制成功，已添加到我的计划')
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('复制计划失败')
    }
  } finally {
    copying.value = false
  }
}

// 工具函数
const getPlanTypeText = (type) => {
  const texts = {
    daily: '每日',
    weekly: '每周',
    monthly: '每月',
    once: '一次性'
  }
  return texts[type] || '未知'
}

const getPlanTypeColor = (type) => {
  const colors = {
    daily: 'success',
    weekly: 'primary',
    monthly: 'warning',
    once: 'info'
  }
  return colors[type] || ''
}

const getCategoryText = (category) => {
  const texts = {
    study: '学习',
    health: '健康',
    work: '工作',
    life: '生活',
    hobby: '兴趣'
  }
  return texts[category] || '其他'
}

const getCategoryColor = (category) => {
  const colors = {
    study: 'primary',
    health: 'success',
    work: 'warning',
    life: 'info',
    hobby: 'danger'
  }
  return colors[category] || ''
}

const getPriorityText = (priority) => {
  const texts = {
    low: '低优先级',
    medium: '中优先级',
    high: '高优先级'
  }
  return texts[priority] || '未知'
}

const getPriorityColor = (priority) => {
  const colors = {
    low: 'info',
    medium: 'warning',
    high: 'danger'
  }
  return colors[priority] || ''
}

const formatDate = (date) => {
  return dayjs(date).format('YYYY-MM-DD')
}

// 页面加载时获取数据
onMounted(() => {
  fetchPlanDetail()
})
</script>

<style lang="scss" scoped>
.square-plan-detail-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: $spacing-lg;
}

.plan-detail-container {
  background: white;
  border-radius: $radius-lg;
  overflow: hidden;
}

.back-button {
  padding: $spacing-md $spacing-lg;
  border-bottom: 1px solid $border-light;

  .el-button {
    color: $text-secondary;

    &:hover {
      color: $primary-color;
    }
  }
}

.plan-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: $spacing-xl $spacing-lg;
  border-bottom: 1px solid $border-light;

  .plan-title-section {
    flex: 1;
    margin-right: $spacing-lg;

    h1 {
      color: $text-primary;
      font-size: 28px;
      font-weight: 600;
      margin: 0 0 $spacing-md 0;
      line-height: 1.3;
    }

    .plan-tags {
      display: flex;
      gap: $spacing-sm;
      flex-wrap: wrap;
    }
  }

  .plan-actions {
    display: flex;
    gap: $spacing-sm;
    flex-shrink: 0;
  }
}

.plan-content {
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: $spacing-xl;
  padding: $spacing-xl $spacing-lg;

  .content-main {
    > div {
      margin-bottom: $spacing-xl;

      &:last-child {
        margin-bottom: 0;
      }
    }

    h3 {
      color: $text-primary;
      font-size: 18px;
      font-weight: 600;
      margin: 0 0 $spacing-md 0;
    }
  }

  .content-sidebar {
    > div {
      margin-bottom: $spacing-lg;

      &:last-child {
        margin-bottom: 0;
      }
    }

    h3 {
      color: $text-primary;
      font-size: 16px;
      font-weight: 600;
      margin: 0 0 $spacing-md 0;
    }
  }
}

.plan-description {
  p {
    color: $text-secondary;
    line-height: 1.6;
    margin: 0;
    white-space: pre-wrap;
  }
}

.plan-target {
  .target-info {
    display: flex;
    flex-direction: column;
    gap: $spacing-sm;

    .target-item {
      display: flex;
      justify-content: space-between;
      padding: $spacing-sm $spacing-md;
      background: $bg-secondary;
      border-radius: $radius-md;

      .label {
        color: $text-secondary;
        font-weight: 500;
      }

      .value {
        color: $text-primary;
        font-weight: 600;
      }
    }
  }
}

.share-description {
  p {
    color: $text-secondary;
    line-height: 1.6;
    margin: 0;
    padding: $spacing-md;
    background: $bg-secondary;
    border-radius: $radius-md;
    border-left: 4px solid $primary-color;
  }
}

.plan-statistics {
  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
    gap: $spacing-md;

    .stat-card {
      display: flex;
      align-items: center;
      gap: $spacing-sm;
      padding: $spacing-md;
      background: $bg-secondary;
      border-radius: $radius-md;
      border: 1px solid $border-light;

      .stat-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 40px;
        height: 40px;
        background: $primary-color;
        color: white;
        border-radius: 50%;

        .el-icon {
          font-size: 18px;
        }
      }

      .stat-info {
        .stat-value {
          color: $text-primary;
          font-size: 20px;
          font-weight: 600;
          line-height: 1;
        }

        .stat-label {
          color: $text-secondary;
          font-size: 12px;
          margin-top: 2px;
        }
      }
    }
  }
}

.author-card {
  padding: $spacing-lg;
  background: $bg-secondary;
  border-radius: $radius-md;
  border: 1px solid $border-light;

  .author-info {
    display: flex;
    gap: $spacing-md;

    .author-avatar {
      flex-shrink: 0;
    }

    .author-details {
      flex: 1;

      .author-name {
        color: $text-primary;
        font-size: 16px;
        font-weight: 600;
        margin-bottom: $spacing-xs;
      }

      .author-meta {
        color: $text-secondary;
        font-size: 13px;
        line-height: 1.4;

        > div {
          margin-bottom: 2px;

          &:last-child {
            margin-bottom: 0;
          }
        }
      }
    }
  }
}

.related-plans {
  padding: $spacing-lg;
  background: $bg-secondary;
  border-radius: $radius-md;
  border: 1px solid $border-light;

  .related-list {
    display: flex;
    flex-direction: column;
    gap: $spacing-sm;

    .related-item {
      padding: $spacing-md;
      background: white;
      border-radius: $radius-md;
      border: 1px solid $border-light;
      cursor: pointer;
      transition: all 0.3s ease;

      &:hover {
        border-color: $primary-color;
        transform: translateX(4px);
      }

      .related-title {
        color: $text-primary;
        font-size: 14px;
        font-weight: 500;
        margin-bottom: $spacing-xs;
        line-height: 1.4;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
      }

      .related-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;

        .related-stats {
          display: flex;
          align-items: center;
          gap: 2px;
          color: $text-secondary;
          font-size: 12px;

          .el-icon {
            font-size: 12px;
          }
        }
      }
    }
  }
}

.error-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

// 响应式设计
@media (max-width: 768px) {
  .square-plan-detail-page {
    padding: $spacing-md;
  }

  .plan-header {
    flex-direction: column;
    gap: $spacing-md;

    .plan-title-section {
      margin-right: 0;

      h1 {
        font-size: 24px;
      }
    }

    .plan-actions {
      width: 100%;
      justify-content: center;
    }
  }

  .plan-content {
    grid-template-columns: 1fr;
    gap: $spacing-lg;

    .content-sidebar {
      order: -1;
    }
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr) !important;
  }

  .author-info {
    flex-direction: column;
    text-align: center;

    .author-details {
      text-align: center;
    }
  }
}
</style>
