import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Layout',
    component: () => import('@/layout/index.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: '/dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard/index.vue'),
        meta: { title: '仪表盘', icon: 'House' }
      },
      {
        path: '/plans',
        name: 'Plans',
        component: () => import('@/views/Plans/index.vue'),
        meta: { title: '我的计划', icon: 'Calendar' }
      },
      {
        path: '/plans/create',
        name: 'CreatePlan',
        component: () => import('@/views/Plans/CreatePlan.vue'),
        meta: { title: '创建计划', icon: 'Plus' }
      },
      {
        path: '/plans/:id',
        name: 'PlanDetail',
        component: () => import('@/views/Plans/PlanDetail.vue'),
        meta: { title: '计划详情', icon: 'Document' }
      },
      {
        path: '/square',
        name: 'Square',
        component: () => import('@/views/Square/index.vue'),
        meta: { title: '计划广场', icon: 'Grid' }
      },
      {
        path: '/square/:id',
        name: 'SquarePlanDetail',
        component: () => import('@/views/Square/PlanDetail.vue'),
        meta: { title: '广场计划详情', icon: 'View' }
      },
      {
        path: '/profile',
        name: 'Profile',
        component: () => import('@/views/Profile/index.vue'),
        meta: { title: '个人中心', icon: 'User' }
      }
    ]
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Auth/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Auth/Register.vue'),
    meta: { title: '注册' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
