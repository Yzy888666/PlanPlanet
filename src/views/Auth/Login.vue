<template>
  <div class="auth-page">
    <div class="auth-card">
      <div class="auth-header">
        <h1>登录</h1>
        <p>欢迎回来，请输入账号和密码</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" label-position="top">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" @keyup.enter="onSubmit" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" @keyup.enter="onSubmit" />
        </el-form-item>
        <div class="form-actions">
          <el-button type="primary" :loading="submitting" @click="onSubmit">登 录</el-button>
          <el-button link @click="goRegister">没有账号？去注册</el-button>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const formRef = ref()
const form = reactive({ username: '', password: '' })
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}
const submitting = ref(false)

const onSubmit = () => {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      submitting.value = true
      await userStore.login({ username: form.username, password: form.password })
      ElMessage.success('登录成功')
      router.push('/dashboard')
    } catch (e) {
      // 错误提示由拦截器处理
    } finally {
      submitting.value = false
    }
  })
}

const goRegister = () => router.push('/register')
</script>

<style lang="scss" scoped>
.auth-page { display:flex; align-items:center; justify-content:center; min-height: 100vh; padding: $spacing-lg; }
.auth-card { width: 100%; max-width: 420px; background: $bg-secondary; border:1px solid $border-light; border-radius: $radius-lg; box-shadow: $shadow-md; padding: $spacing-xl; }
.auth-header { text-align:center; margin-bottom: $spacing-lg; }
.auth-header h1 { margin:0 0 $spacing-xs; color:$text-primary; }
.auth-header p { margin:0; color:$text-secondary; }
.form-actions { display:flex; align-items:center; justify-content:space-between; margin-top: $spacing-md; }
</style>
