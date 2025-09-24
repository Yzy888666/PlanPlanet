<template>
  <div class="square-page">
    <h1>计划广场</h1>
    <p class="page-description">发现优秀的计划，找到志同道合的伙伴</p>

    <div class="debug-info" style="background: #f0f0f0; padding: 10px; margin: 10px 0; border-radius: 5px;">
      <p>调试信息：loading={{ loading }}，publicPlans={{ publicPlans.length }}，total={{ total }}</p>
    </div>

    <div class="plans-list">
      <div v-if="loading" style="text-align: center; padding: 50px;">
        <p>加载中...</p>
      </div>

      <div v-else-if="publicPlans.length === 0" style="text-align: center; padding: 50px;">
        <p>暂无公共计划</p>
      </div>

      <div v-else class="plans-grid">
        <div
          v-for="plan in publicPlans"
          :key="plan.id"
          class="plan-card"
          @click="router.push(`/square/${plan.id}`)"
          style="border: 1px solid #ddd; padding: 20px; margin: 10px; border-radius: 8px; background: white; cursor: pointer;"
        >
          <h3 style="margin: 0 0 10px 0; color: #333;">{{ plan.title }}</h3>
          <p style="color: #666; margin: 0 0 10px 0;">{{ plan.description || '暂无描述' }}</p>
        </div>
      </div>
    </div>

    <div v-if="total > 0" style="text-align: center; margin-top: 20px;">
      <p>共 {{ total }} 个计划</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getPublicPlans } from '@/api/plans'

const router = useRouter()

// 响应式数据
const loading = ref(false)
const publicPlans = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(12)

// 筛选条件
const searchKeyword = ref('')
const filterCategory = ref('')
const filterType = ref('')
const sortBy = ref('created_at')

// 搜索防抖
let searchTimer = null
const handleSearch = () => {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    currentPage.value = 1
    fetchPublicPlans()
  }, 500)
}

// 筛选处理
const handleFilter = () => {
  currentPage.value = 1
  fetchPublicPlans()
}

// 分页处理
const handleSizeChange = (size) => {
  pageSize.value = size
  currentPage.value = 1
  fetchPublicPlans()
}

const handleCurrentChange = (page) => {
  currentPage.value = page
  fetchPublicPlans()
}

// 获取公共计划列表（真实接口）
const fetchPublicPlans = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      pageSize: pageSize.value,
      keyword: searchKeyword.value || undefined,
      category: filterCategory.value || undefined,
      type: filterType.value || undefined,
      sortBy: sortBy.value || undefined
    }

    const res = await getPublicPlans(params)
    const list = Array.isArray(res?.data?.list) ? res.data.list : []
    publicPlans.value = list.map(plan => ({
      ...plan,
      liking: false,
      favoriting: false,
      copying: false
    }))
    total.value = typeof res?.data?.total === 'number' ? res.data.total : list.length
  } catch (error) {
    ElMessage.error('获取计划列表失败')
    console.error('获取公共计划失败:', error)
  } finally {
    loading.value = false
  }
}

// 切换点赞状态（模拟版本）
const toggleLike = async (plan) => {
  plan.liking = true
  try {
    // 模拟API延迟
    await new Promise(resolve => setTimeout(resolve, 300))

    if (plan.isLiked) {
      plan.isLiked = false
      plan.likesCount = Math.max(0, (plan.likesCount || 0) - 1)
      ElMessage.success('取消点赞成功')
    } else {
      plan.isLiked = true
      plan.likesCount = (plan.likesCount || 0) + 1
      ElMessage.success('点赞成功')
    }
  } catch (error) {
    ElMessage.error(plan.isLiked ? '取消点赞失败' : '点赞失败')
  } finally {
    plan.liking = false
  }
}

// 切换收藏状态（模拟版本）
const toggleFavorite = async (plan) => {
  plan.favoriting = true
  try {
    // 模拟API延迟
    await new Promise(resolve => setTimeout(resolve, 300))

    if (plan.isFavorited) {
      plan.isFavorited = false
      plan.favoritesCount = Math.max(0, (plan.favoritesCount || 0) - 1)
      ElMessage.success('取消收藏成功')
    } else {
      plan.isFavorited = true
      plan.favoritesCount = (plan.favoritesCount || 0) + 1
      ElMessage.success('收藏成功')
    }
  } catch (error) {
    ElMessage.error(plan.isFavorited ? '取消收藏失败' : '收藏失败')
  } finally {
    plan.favoriting = false
  }
}

// 复制计划到我的计划（模拟版本）
const copyPlanToMine = async (plan) => {
  try {
    await ElMessageBox.confirm(
      `确定要复制计划"${plan.title}"到我的计划吗？`,
      '确认复制',
      {
        confirmButtonText: '复制',
        cancelButtonText: '取消',
        type: 'info'
      }
    )

    plan.copying = true
    // 模拟API延迟
    await new Promise(resolve => setTimeout(resolve, 500))
    plan.copiesCount = (plan.copiesCount || 0) + 1
    ElMessage.success('计划复制成功，已添加到我的计划')
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('复制计划失败')
    }
  } finally {
    plan.copying = false
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

// 页面加载时获取数据
onMounted(() => {
  fetchPublicPlans()
})
</script>

<style lang="scss" scoped>
.square-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: $spacing-lg;
}

.page-header {
  text-align: center;
  margin-bottom: $spacing-xl;

  h1 {
    color: $text-primary;
    font-size: 32px;
    font-weight: 600;
    margin-bottom: $spacing-sm;
  }

  .page-description {
    color: $text-secondary;
    font-size: 16px;
    margin: 0;
  }
}

.filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-xl;
  padding: $spacing-md;
  background: $bg-secondary;
  border-radius: $radius-lg;

  .filter-left {
    flex: 1;
  }

  .filter-right {
    display: flex;
    gap: $spacing-sm;
  }
}

.plans-list {
  min-height: 400px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 400px;
}

.plans-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: $spacing-lg;
  margin-bottom: $spacing-xl;
}

.plan-card {
  background: white;
  border-radius: $radius-lg;
  padding: $spacing-lg;
  box-shadow: $shadow-sm;
  border: 1px solid $border-light;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: $shadow-md;
    border-color: $primary-color;
  }
}

.plan-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: $spacing-md;

  .plan-title {
    flex: 1;
    margin-right: $spacing-sm;

    h3 {
      color: $text-primary;
      font-size: 18px;
      font-weight: 600;
      margin: 0 0 $spacing-xs 0;
      line-height: 1.4;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
  }
}

.plan-content {
  margin-bottom: $spacing-md;

  .plan-description {
    color: $text-secondary;
    font-size: 14px;
    line-height: 1.5;
    margin: 0 0 $spacing-md 0;
    display: -webkit-box;
    -webkit-line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .plan-meta {
    display: flex;
    flex-direction: column;
    gap: $spacing-xs;

    .plan-target,
    .plan-author {
      display: flex;
      align-items: center;
      gap: $spacing-xs;
      color: $text-secondary;
      font-size: 13px;

      .el-icon {
        font-size: 14px;
      }
    }
  }
}

.plan-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: $spacing-md;
  border-top: 1px solid $border-light;

  .plan-stats {
    display: flex;
    gap: $spacing-md;

    .stat-item {
      display: flex;
      align-items: center;
      gap: $spacing-xs;
      color: $text-secondary;
      font-size: 13px;

      .el-icon {
        font-size: 14px;
      }
    }
  }

  .plan-actions {
    display: flex;
    gap: $spacing-xs;

    .el-button {
      padding: 4px 8px;
      font-size: 12px;
    }
  }
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: $spacing-xl;
}

// 响应式设计
@media (max-width: 768px) {
  .square-page {
    padding: $spacing-md;
  }

  .filter-bar {
    flex-direction: column;
    gap: $spacing-md;

    .filter-left,
    .filter-right {
      width: 100%;
    }

    .filter-right {
      justify-content: space-between;
    }
  }

  .plans-grid {
    grid-template-columns: 1fr;
    gap: $spacing-md;
  }

  .plan-footer {
    flex-direction: column;
    gap: $spacing-sm;
    align-items: stretch;

    .plan-actions {
      justify-content: center;
    }
  }
}
</style>
