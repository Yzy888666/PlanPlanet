<template>
  <div class="auth-page">
    <div class="auth-card">
      <div class="auth-header">
        <h1>注册</h1>
        <p>创建你的账号，开始你的计划之旅</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" label-position="top">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="form.confirmPassword" type="password" show-password placeholder="请再次输入密码" />
        </el-form-item>
        <div class="form-actions">
          <el-button type="primary" :loading="submitting" @click="onSubmit">注 册</el-button>
          <el-button link @click="goLogin">已有账号？去登录</el-button>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { register as registerApi } from '@/api/auth'

const router = useRouter()

const formRef = ref()
const form = reactive({ username: '', email: '', password: '', confirmPassword: '' })
const validateConfirm = (rule, value, callback) => {
  if (value !== form.password) callback(new Error('两次输入的密码不一致'))
  else callback()
}
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '邮箱格式不正确', trigger: ['blur', 'change'] }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '至少6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    { validator: validateConfirm, trigger: 'blur' }
  ]
}
const submitting = ref(false)

const onSubmit = () => {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      submitting.value = true
      await registerApi({ username: form.username, email: form.email, password: form.password })
      ElMessage.success('注册成功，请登录')
      router.push('/login')
    } catch (e) {
      // 错误提示由拦截器处理
    } finally {
      submitting.value = false
    }
  })
}

const goLogin = () => router.push('/login')
</script>

<style lang="scss" scoped>
.auth-page { display:flex; align-items:center; justify-content:center; min-height: 100vh; padding: $spacing-lg; }
.auth-card { width: 100%; max-width: 480px; background: $bg-secondary; border:1px solid $border-light; border-radius: $radius-lg; box-shadow: $shadow-md; padding: $spacing-xl; }
.auth-header { text-align:center; margin-bottom: $spacing-lg; }
.auth-header h1 { margin:0 0 $spacing-xs; color:$text-primary; }
.auth-header p { margin:0; color:$text-secondary; }
.form-actions { display:flex; align-items:center; justify-content:space-between; margin-top: $spacing-md; }
</style>
