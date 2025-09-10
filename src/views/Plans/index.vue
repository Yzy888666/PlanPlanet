<template>
  <div class="plans-page">
    <div class="page-header">
      <h1>我的计划</h1>
      <el-button type="primary" @click="$router.push('/plans/create')">
        <el-icon><Plus /></el-icon>
        创建计划
      </el-button>
    </div>

    <!-- 筛选和搜索 -->
    <div class="filter-bar">
      <div class="filter-left">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索计划..."
          style="width: 300px"
          clearable
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
      </div>

      <div class="filter-right">
        <el-select v-model="filterType" placeholder="计划类型" style="width: 120px">
          <el-option label="全部" value="" />
          <el-option label="每日" value="daily" />
          <el-option label="每周" value="weekly" />
          <el-option label="每月" value="monthly" />
        </el-select>

        <el-select v-model="filterStatus" placeholder="状态" style="width: 120px">
          <el-option label="全部" value="" />
          <el-option label="未开始" value="not_started" />
          <el-option label="进行中" value="in_progress" />
          <el-option label="已完成" value="completed" />
          <el-option label="已暂停" value="paused" />
        </el-select>
      </div>
    </div>

    <!-- 计划列表 -->
    <div class="plans-list" v-loading="plansStore.loading">
      <div v-if="filteredPlans.length === 0" class="empty-state">
        <el-empty description="暂无计划">
          <el-button type="primary" @click="$router.push('/plans/create')">
            创建第一个计划
          </el-button>
        </el-empty>
      </div>

      <div v-else class="plans-grid">
        <div
          v-for="plan in filteredPlans"
          :key="plan.id"
          class="plan-card"
          @click="$router.push(`/plans/${plan.id}`)"
        >
          <div class="plan-header">
            <h3>{{ plan.title }}</h3>
            <el-dropdown @command="handlePlanAction">
              <el-button type="text" size="small">
                <el-icon><MoreFilled /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item :command="`edit-${plan.id}`">编辑</el-dropdown-item>
                  <el-dropdown-item :command="`share-${plan.id}`" v-if="!plan.isPublic">分享</el-dropdown-item>
                  <el-dropdown-item :command="`unshare-${plan.id}`" v-else>取消分享</el-dropdown-item>
                  <el-dropdown-item :command="`delete-${plan.id}`" divided>删除</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>

          <div class="plan-meta">
            <el-tag :type="getTypeColor(plan.type)" size="small">
              {{ getTypeText(plan.type) }}
            </el-tag>
            <el-tag :type="getStatusColor(plan.status)" size="small">
              {{ getStatusText(plan.status) }}
            </el-tag>
            <el-tag :type="getPriorityColor(plan.priority)" size="small">
              {{ getPriorityText(plan.priority) }}
            </el-tag>
          </div>

          <p class="plan-description">{{ plan.description }}</p>

          <div class="plan-progress">
            <div class="progress-info">
              <span>进度</span>
              <span>{{ plan.progress || 0 }}%</span>
            </div>
            <el-progress :percentage="plan.progress || 0" :stroke-width="6" />
          </div>

          <div class="plan-dates">
            <span class="date-item">
              <el-icon><Calendar /></el-icon>
              {{ formatDate(plan.startDate) }} - {{ formatDate(plan.endDate) }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { usePlansStore } from '@/stores/plans'
import dayjs from 'dayjs'

const router = useRouter()
const plansStore = usePlansStore()

// 搜索和筛选
const searchKeyword = ref('')
const filterType = ref('')
const filterStatus = ref('')

// 过滤后的计划列表
const filteredPlans = computed(() => {
  let plans = plansStore.plans

  // 搜索过滤
  if (searchKeyword.value) {
    plans = plans.filter(plan =>
      plan.title.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      plan.description.toLowerCase().includes(searchKeyword.value.toLowerCase())
    )
  }

  // 类型过滤
  if (filterType.value) {
    plans = plans.filter(plan => plan.type === filterType.value)
  }

  // 状态过滤
  if (filterStatus.value) {
    plans = plans.filter(plan => plan.status === filterStatus.value)
  }

  return plans
})

// 处理计划操作
const handlePlanAction = async (command) => {
  const [action, planId] = command.split('-')

  switch (action) {
    case 'edit':
      router.push(`/plans/${planId}/edit`)
      break
    case 'share':
      try {
        // 调用分享API
        ElMessage.success('计划已分享到广场')
      } catch (error) {
        ElMessage.error('分享失败')
      }
      break
    case 'unshare':
      try {
        // 调用取消分享API
        ElMessage.success('已取消分享')
      } catch (error) {
        ElMessage.error('取消分享失败')
      }
      break
    case 'delete':
      try {
        await ElMessageBox.confirm('确定要删除这个计划吗？', '确认删除', {
          confirmButtonText: '删除',
          cancelButtonText: '取消',
          type: 'warning'
        })

        await plansStore.removePlan(planId)
        ElMessage.success('计划已删除')
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('删除失败')
        }
      }
      break
  }
}

// 工具函数
const getTypeColor = (type) => {
  const colors = {
    daily: 'primary',
    weekly: 'success',
    monthly: 'warning'
  }
  return colors[type] || 'info'
}

const getTypeText = (type) => {
  const texts = {
    daily: '每日',
    weekly: '每周',
    monthly: '每月'
  }
  return texts[type] || '未知'
}

const getStatusColor = (status) => {
  const colors = {
    not_started: 'info',
    in_progress: 'warning',
    completed: 'success',
    paused: 'danger'
  }
  return colors[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    not_started: '未开始',
    in_progress: '进行中',
    completed: '已完成',
    paused: '已暂停'
  }
  return texts[status] || '未知'
}

const getPriorityColor = (priority) => {
  const colors = {
    low: 'info',
    medium: 'warning',
    high: 'danger'
  }
  return colors[priority] || 'info'
}

const getPriorityText = (priority) => {
  const texts = {
    low: '低优先级',
    medium: '中优先级',
    high: '高优先级'
  }
  return texts[priority] || '未知'
}

const formatDate = (date) => {
  return dayjs(date).format('MM-DD')
}

// 页面加载时获取计划列表
onMounted(() => {
  plansStore.fetchPlans()
})
</script>

<style lang="scss" scoped>
.plans-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: $spacing-lg;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-xl;

  h1 {
    color: $text-primary;
    font-size: 28px;
    font-weight: 600;
  }
}

.filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-lg;
  padding: $spacing-lg;
  background: $bg-secondary;
  border-radius: $radius-lg;
  box-shadow: $shadow-sm;

  .filter-right {
    display: flex;
    gap: $spacing-md;
  }
}

.plans-list {
  min-height: 400px;
}

.plans-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: $spacing-lg;
}

.plan-card {
  background: $bg-secondary;
  border-radius: $radius-lg;
  padding: $spacing-lg;
  box-shadow: $shadow-md;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: $shadow-lg;
  }

  .plan-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: $spacing-md;

    h3 {
      color: $text-primary;
      font-size: 18px;
      font-weight: 600;
      flex: 1;
      margin-right: $spacing-sm;
    }
  }

  .plan-meta {
    display: flex;
    gap: $spacing-sm;
    margin-bottom: $spacing-md;
    flex-wrap: wrap;
  }

  .plan-description {
    color: $text-secondary;
    font-size: 14px;
    line-height: 1.5;
    margin-bottom: $spacing-md;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .plan-progress {
    margin-bottom: $spacing-md;

    .progress-info {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: $spacing-sm;
      font-size: 12px;
      color: $text-light;
    }
  }

  .plan-dates {
    .date-item {
      display: flex;
      align-items: center;
      gap: $spacing-xs;
      font-size: 12px;
      color: $text-light;
    }
  }
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 300px;
}

// 响应式设计
@media (max-width: $breakpoint-md) {
  .plans-page {
    padding: $spacing-md;
  }

  .page-header {
    flex-direction: column;
    gap: $spacing-md;
    align-items: stretch;

    h1 {
      font-size: 24px;
    }
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
  }
}
</style>
