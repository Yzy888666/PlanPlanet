<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <h1 class="page-title">仪表盘</h1>
      <p class="page-subtitle">欢迎回来，{{ userStore.username }}！</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">
          <el-icon><Calendar /></el-icon>
        </div>
        <div class="stat-content">
          <h3>{{ plansStore.plans.length }}</h3>
          <p>总计划数</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon completed">
          <el-icon><Check /></el-icon>
        </div>
        <div class="stat-content">
          <h3>{{ plansStore.completedPlans.length }}</h3>
          <p>已完成</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon in-progress">
          <el-icon><Clock /></el-icon>
        </div>
        <div class="stat-content">
          <h3>{{ plansStore.inProgressPlans.length }}</h3>
          <p>进行中</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <el-icon><TrendCharts /></el-icon>
        </div>
        <div class="stat-content">
          <h3>{{ completionRate }}%</h3>
          <p>完成率</p>
        </div>
      </div>
    </div>

    <!-- 快速操作 -->
    <div class="quick-actions">
      <h2>快速操作</h2>
      <div class="action-buttons">
        <el-button type="primary" size="large" @click="$router.push('/plans/create')">
          <el-icon><Plus /></el-icon>
          创建新计划
        </el-button>
        <el-button size="large" @click="$router.push('/square')">
          <el-icon><Grid /></el-icon>
          浏览计划广场
        </el-button>
        <el-button size="large" @click="$router.push('/plans')">
          <el-icon><Document /></el-icon>
          查看我的计划
        </el-button>
      </div>
    </div>

    <!-- 最近的计划 -->
    <div class="recent-plans">
      <div class="section-header">
        <h2>最近的计划</h2>
        <el-button type="text" @click="$router.push('/plans')">查看全部</el-button>
      </div>
      
      <div class="plans-grid" v-if="recentPlans.length > 0">
        <div 
          v-for="plan in recentPlans" 
          :key="plan.id" 
          class="plan-card"
          @click="$router.push(`/plans/${plan.id}`)"
        >
          <div class="plan-header">
            <h3>{{ plan.title }}</h3>
            <el-tag :type="getStatusType(plan.status)">{{ getStatusText(plan.status) }}</el-tag>
          </div>
          <p class="plan-description">{{ plan.description }}</p>
          <div class="plan-meta">
            <span class="plan-type">{{ getTypeText(plan.type) }}</span>
            <span class="plan-date">{{ formatDate(plan.createdAt) }}</span>
          </div>
          <div class="plan-progress">
            <el-progress 
              :percentage="plan.progress || 0" 
              :stroke-width="6"
              :show-text="false"
            />
          </div>
        </div>
      </div>
      
      <el-empty v-else description="暂无计划，快去创建一个吧！" />
    </div>

    <!-- 进度图表 -->
    <div class="progress-chart">
      <h2>本月进度统计</h2>
      <div class="chart-container">
        <v-chart :option="chartOption" style="height: 300px;" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import dayjs from 'dayjs'
import { useUserStore } from '@/stores/user'
import { usePlansStore } from '@/stores/plans'

use([CanvasRenderer, LineChart, GridComponent, TooltipComponent, LegendComponent])

const userStore = useUserStore()
const plansStore = usePlansStore()

// 计算完成率
const completionRate = computed(() => {
  const total = plansStore.plans.length
  const completed = plansStore.completedPlans.length
  return total > 0 ? Math.round((completed / total) * 100) : 0
})

// 最近的计划（最多显示6个）
const recentPlans = computed(() => {
  return plansStore.plans
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .slice(0, 6)
})

// 图表配置
const chartOption = computed(() => ({
  tooltip: {
    trigger: 'axis'
  },
  legend: {
    data: ['计划创建', '计划完成']
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '3%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: getLast7Days()
  },
  yAxis: {
    type: 'value'
  },
  series: [
    {
      name: '计划创建',
      type: 'line',
      data: getCreatedData(),
      smooth: true,
      itemStyle: { color: '#667eea' }
    },
    {
      name: '计划完成',
      type: 'line',
      data: getCompletedData(),
      smooth: true,
      itemStyle: { color: '#67c23a' }
    }
  ]
}))

// 获取最近7天的日期
const getLast7Days = () => {
  const days = []
  for (let i = 6; i >= 0; i--) {
    days.push(dayjs().subtract(i, 'day').format('MM/DD'))
  }
  return days
}

// 获取创建数据（模拟数据）
const getCreatedData = () => {
  return [2, 3, 1, 4, 2, 5, 3]
}

// 获取完成数据（模拟数据）
const getCompletedData = () => {
  return [1, 2, 1, 3, 1, 4, 2]
}

// 工具函数
const getStatusType = (status) => {
  const types = {
    'not_started': 'info',
    'in_progress': 'warning',
    'completed': 'success',
    'paused': 'danger'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    'not_started': '未开始',
    'in_progress': '进行中',
    'completed': '已完成',
    'paused': '已暂停'
  }
  return texts[status] || '未知'
}

const getTypeText = (type) => {
  const texts = {
    'daily': '每日计划',
    'weekly': '每周计划',
    'monthly': '每月计划'
  }
  return texts[type] || '未知'
}

const formatDate = (date) => {
  return dayjs(date).format('YYYY-MM-DD')
}

onMounted(() => {
  plansStore.fetchPlans()
})
</script>

<style lang="scss" scoped>
.dashboard {
  max-width: 1200px;
  margin: 0 auto;
}

.dashboard-header {
  margin-bottom: $spacing-xl;
  
  .page-title {
    font-size: 32px;
    font-weight: 700;
    color: $text-primary;
    margin-bottom: $spacing-sm;
  }
  
  .page-subtitle {
    font-size: 16px;
    color: $text-secondary;
  }
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: $spacing-lg;
  margin-bottom: $spacing-xl;
}

.stat-card {
  background: $bg-secondary;
  border-radius: $radius-lg;
  padding: $spacing-lg;
  box-shadow: $shadow-md;
  display: flex;
  align-items: center;
  gap: $spacing-md;
  transition: transform 0.3s ease;

  &:hover {
    transform: translateY(-2px);
  }

  .stat-icon {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: linear-gradient(135deg, $primary-color, $secondary-color);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 24px;

    &.completed {
      background: linear-gradient(135deg, $success-color, #85ce61);
    }

    &.in-progress {
      background: linear-gradient(135deg, $warning-color, #ebb563);
    }
  }

  .stat-content {
    h3 {
      font-size: 28px;
      font-weight: 700;
      color: $text-primary;
      margin-bottom: $spacing-xs;
    }

    p {
      color: $text-secondary;
      font-size: 14px;
    }
  }
}

.quick-actions {
  margin-bottom: $spacing-xl;

  h2 {
    margin-bottom: $spacing-lg;
    color: $text-primary;
  }

  .action-buttons {
    display: flex;
    gap: $spacing-md;
    flex-wrap: wrap;
  }
}

.recent-plans {
  margin-bottom: $spacing-xl;

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: $spacing-lg;

    h2 {
      color: $text-primary;
    }
  }

  .plans-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
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
        font-size: 16px;
        font-weight: 600;
        flex: 1;
        margin-right: $spacing-sm;
      }
    }

    .plan-description {
      color: $text-secondary;
      font-size: 14px;
      margin-bottom: $spacing-md;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .plan-meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: $spacing-md;
      font-size: 12px;
      color: $text-light;
    }

    .plan-progress {
      margin-top: $spacing-sm;
    }
  }
}

.progress-chart {
  background: $bg-secondary;
  border-radius: $radius-lg;
  padding: $spacing-lg;
  box-shadow: $shadow-md;

  h2 {
    margin-bottom: $spacing-lg;
    color: $text-primary;
  }
}

@media (max-width: $breakpoint-md) {
  .stats-grid {
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .plans-grid {
    grid-template-columns: 1fr;
  }
}
</style>
