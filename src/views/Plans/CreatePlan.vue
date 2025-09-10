<template>
  <div class="create-plan-page">
    <div class="page-header">
      <el-button @click="$router.back()" type="text" class="back-btn">
        <el-icon><ArrowLeft /></el-icon>
        返回
      </el-button>
      <h1>创建计划</h1>
    </div>

    <div class="form-container">
      <!-- 主要任务输入 -->
      <div class="task-input-section">
        <el-input
          v-model="planForm.title"
          placeholder="我要做什么？例如：每天阅读30分钟"
          size="large"
          class="main-input"
          maxlength="100"
          @keyup.enter="quickCreate"
        >
          <template #suffix>
            <el-button type="primary" @click="quickCreate" :loading="submitting">
              <el-icon><Plus /></el-icon>
            </el-button>
          </template>
        </el-input>
        <p class="input-tip">按回车键快速创建，或填写下方详细信息</p>
      </div>

      <!-- 详细设置（可折叠） -->
      <div class="detail-settings">
        <el-collapse v-model="activeCollapse">
          <el-collapse-item name="basic" title="📝 基本设置">
            <div class="setting-row">
              <div class="setting-item">
                <label>任务类型</label>
                <el-select v-model="planForm.type" placeholder="选择类型">
                  <el-option label="📅 单次任务" value="once" />
                  <el-option label="🔄 每日重复" value="daily" />
                  <el-option label="📆 每周重复" value="weekly" />
                  <el-option label="🗓️ 每月重复" value="monthly" />
                </el-select>
              </div>

              <div class="setting-item">
                <label>优先级</label>
                <el-select v-model="planForm.priority" placeholder="选择优先级">
                  <el-option label="🔴 高" value="high" />
                  <el-option label="🟡 中" value="medium" />
                  <el-option label="🟢 低" value="low" />
                </el-select>
              </div>
            </div>

            <div class="setting-row">
              <div class="setting-item full-width">
                <label>分类标签</label>
                <el-select v-model="planForm.category" placeholder="选择分类（可选）">
                  <el-option label="💼 工作" value="work" />
                  <el-option label="📚 学习" value="study" />
                  <el-option label="💪 健康" value="health" />
                  <el-option label="🎯 个人" value="personal" />
                  <el-option label="🏠 生活" value="life" />
                  <el-option label="🎨 兴趣" value="hobby" />
                </el-select>
              </div>
            </div>
          </el-collapse-item>

          <el-collapse-item name="time" title="⏰ 时间设置">
            <div class="setting-row">
              <div class="setting-item">
                <label>开始日期</label>
                <el-date-picker
                  v-model="planForm.startDate"
                  type="date"
                  placeholder="选择开始日期"
                  style="width: 100%"
                />
              </div>

              <div class="setting-item" v-if="planForm.type !== 'once'">
                <label>结束日期</label>
                <el-date-picker
                  v-model="planForm.endDate"
                  type="date"
                  placeholder="选择结束日期（可选）"
                  style="width: 100%"
                />
              </div>
            </div>

            <div class="setting-row" v-if="planForm.type === 'once'">
              <div class="setting-item">
                <label>截止时间</label>
                <el-date-picker
                  v-model="planForm.dueDate"
                  type="datetime"
                  placeholder="选择截止时间（可选）"
                  style="width: 100%"
                />
              </div>
            </div>

            <div class="setting-row">
              <div class="setting-item full-width">
                <label>提醒设置</label>
                <el-checkbox-group v-model="planForm.reminders" class="reminder-group">
                  <el-checkbox value="start">开始时提醒</el-checkbox>
                  <el-checkbox value="daily" v-if="planForm.type !== 'once'">每日提醒</el-checkbox>
                  <el-checkbox value="deadline">截止前提醒</el-checkbox>
                </el-checkbox-group>
              </div>
            </div>
          </el-collapse-item>

          <el-collapse-item name="details" title="📋 详细信息">
            <div class="setting-row">
              <div class="setting-item full-width">
                <label>任务描述</label>
                <el-input
                  v-model="planForm.description"
                  type="textarea"
                  :rows="3"
                  placeholder="详细描述这个任务的内容和目标（可选）"
                  maxlength="300"
                  show-word-limit
                />
              </div>
            </div>

            <div class="setting-row" v-if="planForm.type !== 'once'">
              <div class="setting-item">
                <label>目标次数</label>
                <el-input-number
                  v-model="planForm.targetCount"
                  :min="1"
                  :max="365"
                  placeholder="目标次数"
                  style="width: 100%"
                />
              </div>
              <div class="setting-item">
                <label>单位</label>
                <el-input
                  v-model="planForm.unit"
                  placeholder="例如：次、分钟、页"
                  maxlength="10"
                />
              </div>
            </div>
          </el-collapse-item>

          <el-collapse-item name="share" title="🌍 分享设置">
            <div class="setting-row">
              <div class="setting-item full-width">
                <el-switch
                  v-model="planForm.isPublic"
                  active-text="公开到任务广场，让其他人看到并学习"
                  inactive-text="仅自己可见"
                  style="width: 100%"
                />
              </div>
            </div>

            <div class="setting-row" v-if="planForm.isPublic">
              <div class="setting-item full-width">
                <label>分享说明</label>
                <el-input
                  v-model="planForm.shareDescription"
                  type="textarea"
                  :rows="2"
                  placeholder="向其他用户介绍这个任务的亮点和经验"
                  maxlength="150"
                  show-word-limit
                />
              </div>
            </div>
          </el-collapse-item>
        </el-collapse>
      </div>

      <!-- 操作按钮 -->
      <div class="form-actions">
        <el-button @click="$router.back()" size="large">取消</el-button>
        <el-button type="primary" @click="submitForm" :loading="submitting" size="large">
          创建任务
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { usePlansStore } from '@/stores/plans'
import dayjs from 'dayjs'

const router = useRouter()
const plansStore = usePlansStore()

// 表单引用
const formRef = ref()

// 表单数据
const planForm = reactive({
  title: '',
  type: 'once',
  category: '',
  description: '',
  startDate: new Date(),
  endDate: null,
  dueDate: null,
  reminders: [],
  targetCount: null,
  unit: '',
  priority: 'medium',
  isPublic: false,
  shareDescription: ''
})

// 折叠面板状态
const activeCollapse = ref(['basic'])

// 表单验证规则（简化版）
const formRules = {
  title: [
    { required: true, message: '请输入任务标题', trigger: 'blur' },
    { min: 2, max: 100, message: '标题长度在 2 到 100 个字符', trigger: 'blur' }
  ]
}

// 加载状态
const submitting = ref(false)

// 快速创建（只需要标题）
const quickCreate = async () => {
  if (!planForm.title.trim()) {
    ElMessage.warning('请输入任务标题')
    return
  }

  await submitForm(true)
}

// 提交表单
const submitForm = async (isQuick = false) => {
  // 基本验证
  if (!planForm.title.trim()) {
    ElMessage.warning('请输入任务标题')
    return
  }

  try {
    submitting.value = true

    // 准备提交数据
    const submitData = {
      ...planForm,
      title: planForm.title.trim(),
      startDate: planForm.startDate ? dayjs(planForm.startDate).format('YYYY-MM-DD') : dayjs().format('YYYY-MM-DD'),
      endDate: planForm.endDate ? dayjs(planForm.endDate).format('YYYY-MM-DD') : null,
      dueDate: planForm.dueDate ? dayjs(planForm.dueDate).format('YYYY-MM-DD HH:mm') : null,
      status: 'not_started',
      progress: 0,
      createdAt: new Date().toISOString(),
      isQuickCreate: isQuick
    }

    // 调用store创建计划
    await plansStore.createNewPlan(submitData)

    ElMessage.success(isQuick ? '任务创建成功！' : '任务创建成功！')
    router.push('/plans')

  } catch (error) {
    console.error('创建任务失败:', error)
    ElMessage.error('创建任务失败，请重试')
  } finally {
    submitting.value = false
  }
}
</script>

<style lang="scss" scoped>
.create-plan-page {
  max-width: 700px;
  margin: 0 auto;
  padding: $spacing-lg;
}

.page-header {
  display: flex;
  align-items: center;
  margin-bottom: $spacing-xl;

  .back-btn {
    margin-right: $spacing-md;
    font-size: 16px;
    color: $text-secondary;

    &:hover {
      color: $primary-color;
    }
  }

  h1 {
    color: $text-primary;
    font-size: 28px;
    font-weight: 600;
  }
}

.form-container {
  background: $bg-secondary;
  border-radius: $radius-lg;
  padding: $spacing-xl;
  box-shadow: $shadow-md;
}

.task-input-section {
  margin-bottom: $spacing-xl;

  .main-input {
    margin-bottom: $spacing-sm;

    :deep(.el-input__wrapper) {
      border-radius: $radius-lg;
      padding: $spacing-md $spacing-lg;
      font-size: 16px;
      border: 2px solid $border-light;
      transition: all 0.3s ease;

      &:hover {
        border-color: $primary-color;
      }

      &.is-focus {
        border-color: $primary-color;
        box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.1);
      }
    }

    :deep(.el-input__inner) {
      font-size: 16px;
      color: $text-primary;

      &::placeholder {
        color: $text-light;
      }
    }
  }

  .input-tip {
    color: $text-light;
    font-size: 14px;
    text-align: center;
    margin: 0;
  }
}

.detail-settings {
  margin-bottom: $spacing-xl;

  :deep(.el-collapse) {
    border: none;
  }

  :deep(.el-collapse-item__header) {
    background: $bg-primary;
    border: none;
    border-radius: $radius-md;
    padding: $spacing-md $spacing-lg;
    margin-bottom: $spacing-sm;
    font-size: 16px;
    font-weight: 500;
    color: $text-primary;

    &:hover {
      background: darken($bg-primary, 2%);
    }
  }

  :deep(.el-collapse-item__content) {
    padding: $spacing-lg;
    background: $bg-primary;
    border-radius: $radius-md;
    margin-bottom: $spacing-md;
  }

  :deep(.el-collapse-item__wrap) {
    border: none;
  }
}

.setting-row {
  display: flex;
  gap: $spacing-lg;
  margin-bottom: $spacing-lg;

  &:last-child {
    margin-bottom: 0;
  }
}

.setting-item {
  flex: 1;

  &.full-width {
    flex: 1 1 100%;
  }

  label {
    display: block;
    color: $text-primary;
    font-weight: 500;
    margin-bottom: $spacing-sm;
    font-size: 14px;
  }
}

.reminder-group {
  display: flex;
  flex-wrap: wrap;
  gap: $spacing-md;
}

.form-actions {
  display: flex;
  justify-content: center;
  gap: $spacing-md;
  padding-top: $spacing-lg;
  border-top: 1px solid $border-light;
}

// Element Plus 组件样式覆盖
:deep(.el-input__wrapper) {
  border-radius: $radius-md;
  transition: all 0.3s ease;
}

:deep(.el-textarea__inner) {
  border-radius: $radius-md;
}

:deep(.el-select) {
  width: 100%;
}

:deep(.el-date-editor) {
  width: 100%;
}

:deep(.el-switch__label) {
  font-size: 14px;
  color: $text-secondary;
}

// 响应式设计
@media (max-width: $breakpoint-md) {
  .create-plan-page {
    padding: $spacing-md;
  }

  .form-container {
    padding: $spacing-lg;
  }

  .page-header {
    h1 {
      font-size: 24px;
    }
  }

  .setting-row {
    flex-direction: column;
    gap: $spacing-md;
  }

  .form-actions {
    flex-direction: column;

    .el-button {
      width: 100%;
    }
  }

  .task-input-section .main-input {
    :deep(.el-input__wrapper) {
      padding: $spacing-md;
    }
  }
}
</style>
