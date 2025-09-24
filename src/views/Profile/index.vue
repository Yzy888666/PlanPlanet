<template>
  <div class="profile-page">
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card class="profile-card">
          <div class="profile-header">
            <el-avatar :size="80" :src="userStore.avatar || defaultAvatar" />
            <div class="profile-meta">
              <div class="name">{{ userStore.username || '未命名用户' }}</div>
              <div class="email">{{ userStore.email || '-' }}</div>
            </div>
          </div>
          <el-divider>编辑资料</el-divider>
          <el-form :model="profileForm" :rules="profileRules" ref="profileFormRef" label-width="90px">
            <el-form-item label="用户名" prop="username"><el-input v-model="profileForm.username" /></el-form-item>
            <el-form-item label="邮箱" prop="email"><el-input v-model="profileForm.email" /></el-form-item>
            <el-form-item label="头像URL" prop="avatar"><el-input v-model="profileForm.avatar" placeholder="https://..." /></el-form-item>
            <el-form-item>
              <el-button type="primary" :loading="savingProfile" @click="onSaveProfile">保存</el-button>
              <el-button @click="onResetProfile">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <el-card class="password-card" style="margin-top: 20px;">
          <template #header><span>修改密码</span></template>
          <el-form :model="passwordForm" :rules="passwordRules" ref="passwordFormRef" label-width="90px">
            <el-form-item label="当前密码" prop="currentPassword"><el-input v-model="passwordForm.currentPassword" type="password" show-password /></el-form-item>
            <el-form-item label="新密码" prop="newPassword"><el-input v-model="passwordForm.newPassword" type="password" show-password /></el-form-item>
            <el-form-item label="确认新密码" prop="confirmPassword"><el-input v-model="passwordForm.confirmPassword" type="password" show-password /></el-form-item>
            <el-form-item>
              <el-button type="warning" :loading="changingPassword" @click="onChangePassword">更新密码</el-button>
              <el-button @click="onResetPassword">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>

      <el-col :span="16">
        <el-card class="stats-card">
          <template #header>
            <span>我的计划统计</span>
            <div style="float:right;"><el-button type="success" link @click="goMyPlans">查看我的计划</el-button></div>
          </template>
          <div class="stats-grid">
            <div class="stat-item">
              <div class="stat-label">总计划数</div>
              <div class="stat-value">{{ totalPlans }}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">最近更新</div>
              <div class="stat-value">{{ lastUpdatedDisplay }}</div>
            </div>
          </div>
          <el-skeleton v-if="loadingPlans" :rows="4" animated />
          <div v-else>
            <div class="recent-title">最近计划</div>
            <el-empty v-if="recentPlans.length===0" description="暂无数据" />
            <el-timeline v-else>
              <el-timeline-item v-for="p in recentPlans" :key="p.id" :timestamp="formatDate(extractDate(p)) || ''">
                <router-link :to="`/plans/${p.id}`">{{ p.title || `计划 #${p.id}` }}</router-link>
              </el-timeline-item>
            </el-timeline>
          </div>
        </el-card>

        <el-card class="account-card" style="margin-top: 20px;">
          <template #header><span>账号操作</span></template>
          <el-button type="danger" @click="onLogout">退出登录</el-button>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { updateUserInfo, changePassword } from '@/api/auth'
import { getPlans } from '@/api/plans'
import dayjs from 'dayjs'

const router = useRouter()
const userStore = useUserStore()
const defaultAvatar = 'https://avatars.githubusercontent.com/u/0?v=4'

const profileForm = reactive({ username: '', email: '', avatar: '' })
const savingProfile = ref(false)
const profileFormRef = ref()
const profileRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '邮箱格式不正确', trigger: ['blur', 'change'] }
  ],
  avatar: [{ type: 'url', message: '请输入有效的URL', trigger: ['blur', 'change'] }]
}
const initProfileForm = () => {
  profileForm.username = userStore.username || ''
  profileForm.email = userStore.email || ''
  profileForm.avatar = userStore.avatar || ''
}
onMounted(async () => {
  if (!userStore.username) await userStore.fetchUserInfo()
  initProfileForm()
  await fetchPlans()
})
const onSaveProfile = () => {
  profileFormRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      savingProfile.value = true
      await updateUserInfo({ username: profileForm.username, email: profileForm.email, avatar: profileForm.avatar })
      ElMessage.success('资料已更新')
      await userStore.fetchUserInfo()
      initProfileForm()
    } finally {
      savingProfile.value = false
    }
  })
}
const onResetProfile = () => initProfileForm()

const passwordForm = reactive({ currentPassword: '', newPassword: '', confirmPassword: '' })
const changingPassword = ref(false)
const passwordFormRef = ref()
const validateConfirm = (rule, value, callback) => {
  if (value !== passwordForm.newPassword) callback(new Error('两次输入的密码不一致'))
  else callback()
}
const passwordRules = {
  currentPassword: [{ required: true, message: '请输入当前密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '至少6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { validator: validateConfirm, trigger: 'blur' }
  ]
}
const onChangePassword = () => {
  passwordFormRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      changingPassword.value = true
      await changePassword({ currentPassword: passwordForm.currentPassword, newPassword: passwordForm.newPassword })
      ElMessage.success('密码已更新')
      onResetPassword()
    } finally {
      changingPassword.value = false
    }
  })
}
const onResetPassword = () => {
  passwordForm.currentPassword = ''
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
}

const plans = ref([])
const loadingPlans = ref(false)
const fetchPlans = async () => {
  try {
    loadingPlans.value = true
    const res = await getPlans({})
    const list = Array.isArray(res.data) ? res.data : (res.data?.items || [])
    plans.value = list
  } catch (e) {
    plans.value = []
  } finally {
    loadingPlans.value = false
  }
}
const totalPlans = computed(() => plans.value.length)
const extractDate = (p) => {
  const fields = ['updatedAt','updated_at','updated','updateTime','modifiedAt','modified_at','createdAt','created_at','created','createTime']
  for (const k of fields) if (p && p[k]) return p[k]
  return null
}
const lastUpdated = computed(() => {
  let maxTs = 0
  plans.value.forEach(p => {
    const d = extractDate(p)
    if (d) {
      const ts = dayjs(d).valueOf()
      if (!isNaN(ts)) maxTs = Math.max(maxTs, ts)
    }
  })
  return maxTs ? new Date(maxTs) : null
})
const lastUpdatedDisplay = computed(() => lastUpdated.value ? dayjs(lastUpdated.value).format('YYYY-MM-DD HH:mm') : '—')
const recentPlans = computed(() => plans.value.map(p => ({ p, ts: dayjs(extractDate(p)).valueOf() || 0 })).sort((a,b) => b.ts - a.ts).slice(0, 5).map(x => x.p))
const formatDate = (d) => {
  if (!d) return ''
  const ts = dayjs(d)
  return ts.isValid() ? ts.format('YYYY-MM-DD HH:mm') : ''
}
const goMyPlans = () => router.push('/plans')
const onLogout = async () => { await userStore.logout(); router.push('/login') }
</script>

<style lang="scss" scoped>
.profile-page { padding: $spacing-lg; }
.profile-card .profile-header { display:flex; gap: $spacing-md; align-items:center; margin-bottom: $spacing-md; }
.profile-card .profile-meta .name { font-size: 18px; font-weight: 600; color: $text-primary; }
.profile-card .profile-meta .email { color: $text-light; font-size: 13px; }
.stats-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: $spacing-lg; margin-bottom: $spacing-lg; }
.stat-item { background: $bg-secondary; border: 1px solid $border-light; border-radius: $radius-md; padding: $spacing-md; box-shadow: $shadow-sm; }
.stat-label { color: $text-light; margin-bottom: $spacing-sm; }
.stat-value { font-size: 24px; font-weight: 700; color: $text-primary; }
.recent-title { font-weight: 600; margin-bottom: $spacing-md; color: $text-secondary; }
</style>
