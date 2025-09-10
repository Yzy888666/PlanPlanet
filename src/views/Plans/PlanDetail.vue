<template>
  <div class="plan-detail-page" v-loading="loading">
    <!-- 页面头部 -->
    <div class="page-header">
      <el-button @click="$router.back()" type="text" class="back-btn">
        <el-icon><ArrowLeft /></el-icon>
        返回
      </el-button>

      <div class="header-actions">
        <el-button v-if="!plan?.isPublic" @click="sharePlan" :loading="sharing">
          <el-icon><Share /></el-icon>
          分享
        </el-button>
        <el-button v-else @click="unsharePlan" :loading="sharing">
          <el-icon><Hide /></el-icon>
          取消分享
        </el-button>

        <el-dropdown @command="handleAction">
          <el-button type="primary">
            <el-icon><MoreFilled /></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="edit">编辑任务</el-dropdown-item>
              <el-dropdown-item command="duplicate">复制任务</el-dropdown-item>
              <el-dropdown-item divided command="delete">删除任务</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <!-- 任务信息卡片 -->
    <div class="task-info-card" v-if="plan">
      <div class="task-header">
        <div class="task-title-section">
          <h1 class="task-title">{{ plan.title }}</h1>
          <div class="task-meta">
            <el-tag :type="getTypeColor(plan.type)" size="small">
              {{ getTypeText(plan.type) }}
            </el-tag>
            <el-tag :type="getCategoryColor(plan.category)" size="small" v-if="plan.category">
              {{ getCategoryText(plan.category) }}
            </el-tag>
            <el-tag :type="getPriorityColor(plan.priority)" size="small">
              {{ getPriorityText(plan.priority) }}
            </el-tag>
          </div>
        </div>

        <div class="task-status">
          <el-select v-model="plan.status" @change="updateStatus" class="status-select">
            <el-option label="未开始" value="not_started" />
            <el-option label="进行中" value="in_progress" />
            <el-option label="已完成" value="completed" />
            <el-option label="已暂停" value="paused" />
          </el-select>
        </div>
      </div>

      <div class="task-description" v-if="plan.description">
        <h3>任务描述</h3>
        <p>{{ plan.description }}</p>
      </div>

      <!-- 进度展示 -->
      <div class="progress-section">
        <div class="progress-header">
          <h3>执行进度</h3>
          <span class="progress-text">{{ plan.progress || 0 }}%</span>
        </div>
        <el-progress
          :percentage="plan.progress || 0"
          :stroke-width="12"
          :color="getProgressColor(plan.progress || 0)"
        />

        <div class="progress-details" v-if="plan.targetCount">
          <div class="count-info">
            <span class="current">{{ plan.currentCount || 0 }}</span>
            <span class="separator">/</span>
            <span class="target">{{ plan.targetCount }}</span>
            <span class="unit">{{ plan.unit || '次' }}</span>
          </div>

          <el-button
            v-if="plan.status === 'in_progress'"
            type="primary"
            @click="markComplete"
            :loading="updating"
          >
            <el-icon><Check /></el-icon>
            完成一次
          </el-button>
        </div>
      </div>

      <!-- 时间信息 -->
      <div class="time-section">
        <h3>时间安排</h3>
        <div class="time-grid">
          <div class="time-item">
            <label>开始时间</label>
            <span>{{ formatDate(plan.startDate) }}</span>
          </div>
          <div class="time-item" v-if="plan.endDate">
            <label>结束时间</label>
            <span>{{ formatDate(plan.endDate) }}</span>
          </div>
          <div class="time-item" v-if="plan.dueDate">
            <label>截止时间</label>
            <span>{{ formatDateTime(plan.dueDate) }}</span>
          </div>
          <div class="time-item">
            <label>创建时间</label>
            <span>{{ formatDateTime(plan.createdAt) }}</span>
          </div>
        </div>
      </div>

      <!-- 提醒设置 -->
      <div class="reminder-section" v-if="plan.reminders && plan.reminders.length > 0">
        <h3>提醒设置</h3>
        <div class="reminder-list">
          <el-tag
            v-for="reminder in plan.reminders"
            :key="reminder"
            type="info"
            size="small"
          >
            {{ getReminderText(reminder) }}
          </el-tag>
        </div>
      </div>
    </div>

    <!-- 执行记录 -->
    <div class="execution-records" v-if="plan && plan.type !== 'once'">
      <div class="section-header">
        <h3>执行记录</h3>
        <el-button @click="showAddRecord = true" type="primary" size="small">
          <el-icon><Plus /></el-icon>
          添加记录
        </el-button>
      </div>

      <div class="records-list">
        <div
          v-for="record in executionRecords"
          :key="record.id"
          class="record-item"
        >
          <div class="record-date">{{ formatDate(record.executionDate) }}</div>
          <div class="record-content">
            <span class="record-count">完成 {{ record.countCompleted }} {{ plan.unit || '次' }}</span>
            <span class="record-duration" v-if="record.durationMinutes">
              耗时 {{ record.durationMinutes }} 分钟
            </span>
          </div>
          <div class="record-notes" v-if="record.notes">{{ record.notes }}</div>
        </div>

        <el-empty v-if="executionRecords.length === 0" description="暂无执行记录" />
      </div>
    </div>

    <!-- 评价区域 -->
    <div class="review-section">
      <h3>我的评价</h3>
      <div class="review-form" v-if="!userReview">
        <el-rate v-model="newReview.rating" size="large" />
        <el-input
          v-model="newReview.content"
          type="textarea"
          :rows="3"
          placeholder="分享你的执行心得和体验..."
          maxlength="500"
          show-word-limit
        />
        <el-button type="primary" @click="submitReview" :loading="submittingReview">
          提交评价
        </el-button>
      </div>

      <div class="review-display" v-else>
        <div class="review-header">
          <el-rate v-model="userReview.rating" disabled />
          <span class="review-date">{{ formatDate(userReview.createdAt) }}</span>
        </div>
        <p class="review-content">{{ userReview.content }}</p>
        <el-button type="text" @click="editReview">编辑评价</el-button>
      </div>
    </div>

    <!-- 添加执行记录弹窗 -->
    <el-dialog v-model="showAddRecord" title="添加执行记录" width="500px">
      <el-form :model="newRecord" label-width="100px">
        <el-form-item label="执行日期">
          <el-date-picker
            v-model="newRecord.executionDate"
            type="date"
            placeholder="选择执行日期"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="完成数量">
          <el-input-number
            v-model="newRecord.countCompleted"
            :min="1"
            :max="100"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="执行时长">
          <el-input-number
            v-model="newRecord.durationMinutes"
            :min="1"
            placeholder="分钟"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="备注">
          <el-input
            v-model="newRecord.notes"
            type="textarea"
            :rows="2"
            placeholder="记录执行过程中的想法..."
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showAddRecord = false">取消</el-button>
        <el-button type="primary" @click="addExecutionRecord" :loading="addingRecord">
          添加记录
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  ArrowLeft,
  Share,
  Hide,
  MoreFilled,
  Check,
  Plus
} from '@element-plus/icons-vue'
import { usePlansStore } from '@/stores/plans'
import dayjs from 'dayjs'

const route = useRoute()
const router = useRouter()
const plansStore = usePlansStore()

// 响应式数据
const loading = ref(false)
const sharing = ref(false)
const updating = ref(false)
const submittingReview = ref(false)
const addingRecord = ref(false)
const showAddRecord = ref(false)

// 计划数据
const plan = ref(null)
const executionRecords = ref([])
const userReview = ref(null)

// 新评价表单
const newReview = reactive({
  rating: 5,
  content: ''
})

// 新执行记录表单
const newRecord = reactive({
  executionDate: new Date(),
  countCompleted: 1,
  durationMinutes: null,
  notes: ''
})

// 获取计划详情
const fetchPlanDetail = async () => {
  loading.value = true
  try {
    const planId = route.params.id
    const planData = await plansStore.fetchPlanDetail(planId)
    plan.value = planData

    // 获取执行记录（模拟数据）
    if (plan.value.type !== 'once') {
      executionRecords.value = [
        {
          id: 1,
          executionDate: '2024-01-15',
          countCompleted: 1,
          durationMinutes: 30,
          notes: '今天状态不错，完成得很顺利'
        },
        {
          id: 2,
          executionDate: '2024-01-14',
          countCompleted: 1,
          durationMinutes: 25,
          notes: ''
        }
      ]
    }

    // 获取用户评价（模拟数据）
    // userReview.value = {
    //   rating: 4,
    //   content: '这个计划帮助我养成了很好的习惯',
    //   createdAt: '2024-01-10'
    // }

  } catch (error) {
    ElMessage.error('获取计划详情失败')
    router.back()
  } finally {
    loading.value = false
  }
}

// 更新状态
const updateStatus = async (newStatus) => {
  updating.value = true
  try {
    await plansStore.changePlanStatus(plan.value.id, newStatus)
    ElMessage.success('状态更新成功')
  } catch (error) {
    ElMessage.error('状态更新失败')
    // 恢复原状态
    plan.value.status = plan.value.status
  } finally {
    updating.value = false
  }
}

// 标记完成一次
const markComplete = async () => {
  updating.value = true
  try {
    // 更新完成次数
    const newCount = (plan.value.currentCount || 0) + 1
    const newProgress = Math.min((newCount / plan.value.targetCount) * 100, 100)

    plan.value.currentCount = newCount
    plan.value.progress = newProgress

    // 如果达到目标，自动标记为完成
    if (newCount >= plan.value.targetCount) {
      plan.value.status = 'completed'
    }

    ElMessage.success('完成记录已更新')
  } catch (error) {
    ElMessage.error('更新失败')
  } finally {
    updating.value = false
  }
}

// 分享计划
const sharePlan = async () => {
  sharing.value = true
  try {
    // 调用分享API
    plan.value.isPublic = true
    ElMessage.success('计划已分享到广场')
  } catch (error) {
    ElMessage.error('分享失败')
  } finally {
    sharing.value = false
  }
}

// 取消分享
const unsharePlan = async () => {
  sharing.value = true
  try {
    // 调用取消分享API
    plan.value.isPublic = false
    ElMessage.success('已取消分享')
  } catch (error) {
    ElMessage.error('取消分享失败')
  } finally {
    sharing.value = false
  }
}

// 处理操作菜单
const handleAction = async (command) => {
  switch (command) {
    case 'edit':
      router.push(`/plans/${plan.value.id}/edit`)
      break
    case 'duplicate':
      try {
        const duplicateData = {
          ...plan.value,
          title: `${plan.value.title} (副本)`,
          status: 'not_started',
          progress: 0,
          currentCount: 0
        }
        delete duplicateData.id
        await plansStore.createNewPlan(duplicateData)
        ElMessage.success('计划已复制')
      } catch (error) {
        ElMessage.error('复制失败')
      }
      break
    case 'delete':
      try {
        await ElMessageBox.confirm('确定要删除这个计划吗？', '确认删除', {
          confirmButtonText: '删除',
          cancelButtonText: '取消',
          type: 'warning'
        })

        await plansStore.removePlan(plan.value.id)
        ElMessage.success('计划已删除')
        router.push('/plans')
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('删除失败')
        }
      }
      break
  }
}

// 提交评价
const submitReview = async () => {
  if (!newReview.rating) {
    ElMessage.warning('请选择评分')
    return
  }

  submittingReview.value = true
  try {
    // 调用评价API
    userReview.value = {
      rating: newReview.rating,
      content: newReview.content,
      createdAt: new Date().toISOString()
    }

    // 重置表单
    newReview.rating = 5
    newReview.content = ''

    ElMessage.success('评价提交成功')
  } catch (error) {
    ElMessage.error('评价提交失败')
  } finally {
    submittingReview.value = false
  }
}

// 编辑评价
const editReview = () => {
  newReview.rating = userReview.value.rating
  newReview.content = userReview.value.content
  userReview.value = null
}

// 添加执行记录
const addExecutionRecord = async () => {
  if (!newRecord.executionDate) {
    ElMessage.warning('请选择执行日期')
    return
  }

  addingRecord.value = true
  try {
    // 调用添加记录API
    const record = {
      id: Date.now(),
      executionDate: dayjs(newRecord.executionDate).format('YYYY-MM-DD'),
      countCompleted: newRecord.countCompleted,
      durationMinutes: newRecord.durationMinutes,
      notes: newRecord.notes
    }

    executionRecords.value.unshift(record)

    // 更新计划进度
    const totalCompleted = (plan.value.currentCount || 0) + newRecord.countCompleted
    plan.value.currentCount = totalCompleted
    if (plan.value.targetCount) {
      plan.value.progress = Math.min((totalCompleted / plan.value.targetCount) * 100, 100)
    }

    // 重置表单
    newRecord.executionDate = new Date()
    newRecord.countCompleted = 1
    newRecord.durationMinutes = null
    newRecord.notes = ''

    showAddRecord.value = false
    ElMessage.success('执行记录添加成功')
  } catch (error) {
    ElMessage.error('添加记录失败')
  } finally {
    addingRecord.value = false
  }
}

// 工具函数
const formatDate = (date) => {
  return dayjs(date).format('YYYY-MM-DD')
}

const formatDateTime = (date) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

const getTypeText = (type) => {
  const typeMap = {
    once: '单次任务',
    daily: '每日重复',
    weekly: '每周重复',
    monthly: '每月重复'
  }
  return typeMap[type] || type
}

const getTypeColor = (type) => {
  const colorMap = {
    once: '',
    daily: 'success',
    weekly: 'warning',
    monthly: 'danger'
  }
  return colorMap[type] || ''
}

const getCategoryText = (category) => {
  const categoryMap = {
    work: '💼 工作',
    study: '📚 学习',
    health: '💪 健康',
    personal: '👤 个人',
    life: '🏠 生活',
    hobby: '🎨 爱好'
  }
  return categoryMap[category] || category
}

const getCategoryColor = (category) => {
  return 'info'
}

const getPriorityText = (priority) => {
  const priorityMap = {
    low: '低优先级',
    medium: '中优先级',
    high: '高优先级'
  }
  return priorityMap[priority] || priority
}

const getPriorityColor = (priority) => {
  const colorMap = {
    low: 'info',
    medium: 'warning',
    high: 'danger'
  }
  return colorMap[priority] || 'info'
}

const getProgressColor = (progress) => {
  if (progress < 30) return '#f56c6c'
  if (progress < 70) return '#e6a23c'
  return '#67c23a'
}

const getReminderText = (reminder) => {
  const reminderMap = {
    start: '开始提醒',
    daily: '每日提醒',
    deadline: '截止提醒'
  }
  return reminderMap[reminder] || reminder
}

// 生命周期
onMounted(() => {
  fetchPlanDetail()
})
</script>

<style lang="scss" scoped>
.plan-detail-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: $spacing-lg;

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: $spacing-xl;

    .back-btn {
      font-size: 16px;
      color: var(--el-text-color-regular);

      &:hover {
        color: var(--el-color-primary);
      }
    }

    .header-actions {
      display: flex;
      gap: $spacing-sm;
    }
  }

  .task-info-card {
    background: white;
    border-radius: 12px;
    padding: $spacing-xl;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
    margin-bottom: $spacing-xl;

    .task-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: $spacing-lg;

      .task-title-section {
        flex: 1;

        .task-title {
          font-size: 28px;
          font-weight: 600;
          color: var(--el-text-color-primary);
          margin: 0 0 $spacing-md 0;
          line-height: 1.3;
        }

        .task-meta {
          display: flex;
          gap: $spacing-sm;
          flex-wrap: wrap;
        }
      }

      .task-status {
        .status-select {
          width: 120px;
        }
      }
    }

    .task-description {
      margin-bottom: $spacing-lg;

      h3 {
        font-size: 18px;
        font-weight: 600;
        margin: 0 0 $spacing-md 0;
        color: var(--el-text-color-primary);
      }

      p {
        color: var(--el-text-color-regular);
        line-height: 1.6;
        margin: 0;
      }
    }

    .progress-section {
      margin-bottom: $spacing-lg;

      .progress-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: $spacing-md;

        h3 {
          font-size: 18px;
          font-weight: 600;
          margin: 0;
          color: var(--el-text-color-primary);
        }

        .progress-text {
          font-size: 20px;
          font-weight: 600;
          color: var(--el-color-primary);
        }
      }

      .progress-details {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: $spacing-md;

        .count-info {
          font-size: 16px;

          .current {
            font-weight: 600;
            color: var(--el-color-primary);
          }

          .separator {
            margin: 0 4px;
            color: var(--el-text-color-placeholder);
          }

          .target {
            color: var(--el-text-color-regular);
          }

          .unit {
            margin-left: 4px;
            color: var(--el-text-color-secondary);
          }
        }
      }
    }

    .time-section {
      margin-bottom: $spacing-lg;

      h3 {
        font-size: 18px;
        font-weight: 600;
        margin: 0 0 $spacing-md 0;
        color: var(--el-text-color-primary);
      }

      .time-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: $spacing-md;

        .time-item {
          display: flex;
          flex-direction: column;
          gap: 4px;

          label {
            font-size: 14px;
            color: var(--el-text-color-secondary);
            font-weight: 500;
          }

          span {
            color: var(--el-text-color-primary);
            font-weight: 500;
          }
        }
      }
    }

    .reminder-section {
      h3 {
        font-size: 18px;
        font-weight: 600;
        margin: 0 0 $spacing-md 0;
        color: var(--el-text-color-primary);
      }

      .reminder-list {
        display: flex;
        gap: $spacing-sm;
        flex-wrap: wrap;
      }
    }
  }

  .execution-records {
    background: white;
    border-radius: 12px;
    padding: $spacing-xl;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
    margin-bottom: $spacing-xl;

    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: $spacing-lg;

      h3 {
        font-size: 18px;
        font-weight: 600;
        margin: 0;
        color: var(--el-text-color-primary);
      }
    }

    .records-list {
      .record-item {
        padding: $spacing-md;
        border: 1px solid var(--el-border-color-light);
        border-radius: 8px;
        margin-bottom: $spacing-md;
        transition: all 0.3s ease;

        &:hover {
          border-color: var(--el-color-primary);
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        &:last-child {
          margin-bottom: 0;
        }

        .record-date {
          font-size: 14px;
          color: var(--el-color-primary);
          font-weight: 600;
          margin-bottom: 4px;
        }

        .record-content {
          display: flex;
          gap: $spacing-md;
          margin-bottom: 4px;

          .record-count {
            color: var(--el-text-color-primary);
            font-weight: 500;
          }

          .record-duration {
            color: var(--el-text-color-secondary);
            font-size: 14px;
          }
        }

        .record-notes {
          color: var(--el-text-color-regular);
          font-size: 14px;
          line-height: 1.5;
        }
      }
    }
  }

  .review-section {
    background: white;
    border-radius: 12px;
    padding: $spacing-xl;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);

    h3 {
      font-size: 18px;
      font-weight: 600;
      margin: 0 0 $spacing-lg 0;
      color: var(--el-text-color-primary);
    }

    .review-form {
      display: flex;
      flex-direction: column;
      gap: $spacing-md;

      .el-rate {
        margin-bottom: $spacing-sm;
      }
    }

    .review-display {
      .review-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: $spacing-md;

        .review-date {
          color: var(--el-text-color-secondary);
          font-size: 14px;
        }
      }

      .review-content {
        color: var(--el-text-color-regular);
        line-height: 1.6;
        margin: 0 0 $spacing-md 0;
      }
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .plan-detail-page {
    padding: $spacing-md;

    .page-header {
      flex-direction: column;
      gap: $spacing-md;
      align-items: stretch;

      .header-actions {
        justify-content: center;
      }
    }

    .task-info-card {
      padding: $spacing-lg;

      .task-header {
        flex-direction: column;
        gap: $spacing-md;

        .task-title {
          font-size: 24px;
        }
      }

      .time-section .time-grid {
        grid-template-columns: 1fr;
      }

      .progress-details {
        flex-direction: column;
        gap: $spacing-md;
        align-items: stretch;
      }
    }

    .execution-records,
    .review-section {
      padding: $spacing-lg;
    }
  }
}
</style>
