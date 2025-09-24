<template>
  <div class="layout">
    <!-- 侧边栏 -->
    <aside class="sidebar" :class="{ collapsed: sidebarCollapsed }">
      <div class="logo">
        <div class="logo-icon" v-if="!sidebarCollapsed">🌍</div>
        <span v-if="!sidebarCollapsed">PlanPlanet</span>
        <div class="logo-icon" v-else>🌍</div>
      </div>
      
      <nav class="nav-menu">
        <router-link
          v-for="item in menuItems"
          :key="item.path"
          :to="item.path"
          class="nav-item"
          :class="{ active: $route.path === item.path }"
        >
          <el-icon><component :is="item.icon" /></el-icon>
          <span v-if="!sidebarCollapsed">{{ item.title }}</span>
        </router-link>
      </nav>
    </aside>

    <!-- 主内容区 -->
    <div class="main-content">
      <!-- 顶部导航 -->
      <header class="header">
        <div class="header-left">
          <el-button
            type="text"
            @click="toggleSidebar"
            class="sidebar-toggle"
          >
            <el-icon><Expand v-if="sidebarCollapsed" /><Fold v-else /></el-icon>
          </el-button>
          
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-if="$route.meta.title">{{ $route.meta.title }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>

        <div class="header-right">
          <el-dropdown @command="handleUserCommand">
            <div class="user-info">
              <el-avatar :size="32" :src="userStore.avatar">
                <el-icon><User /></el-icon>
              </el-avatar>
              <span class="username">{{ userStore.username || '用户' }}</span>
              <el-icon><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                <el-dropdown-item command="settings">设置</el-dropdown-item>
                <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <!-- 页面内容 -->
      <main class="content">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import {
  House,
  Calendar,
  Grid,
  User,
  ArrowDown,
  Expand,
  Fold
} from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()

const sidebarCollapsed = ref(false)

const menuItems = computed(() => [
  { path: '/dashboard', title: '仪表盘', icon: 'House' },
  { path: '/plans', title: '我的计划', icon: 'Calendar' },
  { path: '/square', title: '计划广场', icon: 'Grid' },
  { path: '/profile', title: '个人中心', icon: 'User' }
])

const toggleSidebar = () => {
  sidebarCollapsed.value = !sidebarCollapsed.value
}

const handleUserCommand = (command) => {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'settings':
      // 打开设置弹窗
      break
    case 'logout':
      userStore.logout()
      router.push('/login')
      break
  }
}
</script>

<style lang="scss" scoped>
.layout {
  display: flex;
  height: 100vh;
  background: $bg-primary;
}

.sidebar {
  width: 240px;
  background: $bg-secondary;
  box-shadow: $shadow-md;
  transition: width 0.3s ease;
  z-index: 1000;

  &.collapsed {
    width: 64px;
  }

  .logo {
    display: flex;
    align-items: center;
    padding: $spacing-lg;
    border-bottom: 1px solid $border-light;

    .logo-icon {
      width: 32px;
      height: 32px;
      margin-right: $spacing-sm;
      font-size: 24px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    span {
      font-size: 18px;
      font-weight: 600;
      color: $primary-color;
    }
  }

  .nav-menu {
    padding: $spacing-md 0;
  }

  .nav-item {
    display: flex;
    align-items: center;
    padding: $spacing-md $spacing-lg;
    color: $text-secondary;
    text-decoration: none;
    transition: all 0.3s ease;

    &:hover {
      background: $bg-primary;
      color: $primary-color;
    }

    &.active {
      background: linear-gradient(90deg, rgba(102, 126, 234, 0.1), transparent);
      color: $primary-color;
      border-right: 3px solid $primary-color;
    }

    .el-icon {
      margin-right: $spacing-sm;
      font-size: 18px;
    }
  }
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 60px;
  padding: 0 $spacing-lg;
  background: $bg-secondary;
  border-bottom: 1px solid $border-light;
  box-shadow: $shadow-sm;

  .header-left {
    display: flex;
    align-items: center;
    gap: $spacing-md;
  }

  .sidebar-toggle {
    font-size: 18px;
  }

  .user-info {
    display: flex;
    align-items: center;
    gap: $spacing-sm;
    cursor: pointer;
    padding: $spacing-sm;
    border-radius: $radius-md;
    transition: background 0.3s ease;

    &:hover {
      background: $bg-primary;
    }

    .username {
      font-size: 14px;
      color: $text-primary;
    }
  }
}

.content {
  flex: 1;
  padding: $spacing-lg;
  overflow-y: auto;
}

// 页面切换动画
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

// 响应式设计
@media (max-width: $breakpoint-md) {
  .sidebar {
    position: fixed;
    left: 0;
    top: 0;
    height: 100vh;
    transform: translateX(-100%);
    
    &:not(.collapsed) {
      transform: translateX(0);
    }
  }
  
  .main-content {
    margin-left: 0;
  }
}
</style>
