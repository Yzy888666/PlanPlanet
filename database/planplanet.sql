-- PlanPlanet 数据库建表语句
-- 创建数据库
CREATE DATABASE IF NOT EXISTS planplanet CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE planplanet;

-- 用户表
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    avatar VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
    nickname VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    bio TEXT DEFAULT NULL COMMENT '个人简介',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active' COMMENT '用户状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB COMMENT='用户表';

-- 计划/任务表
CREATE TABLE plans (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    title VARCHAR(100) NOT NULL COMMENT '任务标题',
    description TEXT DEFAULT NULL COMMENT '任务描述',
    type ENUM('once', 'daily', 'weekly', 'monthly') NOT NULL DEFAULT 'once' COMMENT '任务类型',
    category ENUM('work', 'study', 'health', 'personal', 'life', 'hobby') DEFAULT NULL COMMENT '任务分类',
    priority ENUM('low', 'medium', 'high') NOT NULL DEFAULT 'medium' COMMENT '优先级',
    status ENUM('not_started', 'in_progress', 'completed', 'paused', 'cancelled') NOT NULL DEFAULT 'not_started' COMMENT '任务状态',
    start_date DATE NOT NULL COMMENT '开始日期',
    end_date DATE DEFAULT NULL COMMENT '结束日期',
    due_date DATETIME DEFAULT NULL COMMENT '截止时间（单次任务）',
    target_count INT DEFAULT NULL COMMENT '目标次数',
    current_count INT DEFAULT 0 COMMENT '当前完成次数',
    unit VARCHAR(10) DEFAULT NULL COMMENT '单位（次、分钟、页等）',
    progress DECIMAL(5,2) DEFAULT 0.00 COMMENT '进度百分比',
    reminders JSON DEFAULT NULL COMMENT '提醒设置',
    is_public BOOLEAN DEFAULT FALSE COMMENT '是否公开',
    share_description VARCHAR(200) DEFAULT NULL COMMENT '分享说明',
    is_quick_create BOOLEAN DEFAULT FALSE COMMENT '是否快速创建',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_category (category),
    INDEX idx_priority (priority),
    INDEX idx_status (status),
    INDEX idx_start_date (start_date),
    INDEX idx_is_public (is_public),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB COMMENT='计划任务表';

-- 任务执行记录表
CREATE TABLE plan_executions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    plan_id BIGINT NOT NULL COMMENT '计划ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    execution_date DATE NOT NULL COMMENT '执行日期',
    count_completed INT DEFAULT 1 COMMENT '完成数量',
    notes TEXT DEFAULT NULL COMMENT '执行备注',
    duration_minutes INT DEFAULT NULL COMMENT '执行时长（分钟）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
    FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_plan_date (plan_id, execution_date),
    INDEX idx_plan_id (plan_id),
    INDEX idx_user_id (user_id),
    INDEX idx_execution_date (execution_date)
) ENGINE=InnoDB COMMENT='任务执行记录表';

-- 计划评价表
CREATE TABLE plan_reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    plan_id BIGINT NOT NULL COMMENT '计划ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    rating TINYINT NOT NULL COMMENT '评分(1-5)',
    content TEXT DEFAULT NULL COMMENT '评价内容',
    review_type ENUM('self', 'public') NOT NULL DEFAULT 'self' COMMENT '评价类型：自评/公开评价',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_plan_id (plan_id),
    INDEX idx_user_id (user_id),
    INDEX idx_rating (rating),
    INDEX idx_review_type (review_type)
) ENGINE=InnoDB COMMENT='计划评价表';

-- 计划点赞表
CREATE TABLE plan_likes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    plan_id BIGINT NOT NULL COMMENT '计划ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_plan_user (plan_id, user_id),
    INDEX idx_plan_id (plan_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB COMMENT='计划点赞表';

-- 计划跟随表（用户复制他人计划）
CREATE TABLE plan_follows (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    original_plan_id BIGINT NOT NULL COMMENT '原计划ID',
    new_plan_id BIGINT NOT NULL COMMENT '新计划ID',
    follower_user_id BIGINT NOT NULL COMMENT '跟随者用户ID',
    original_user_id BIGINT NOT NULL COMMENT '原作者用户ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '跟随时间',
    FOREIGN KEY (original_plan_id) REFERENCES plans(id) ON DELETE CASCADE,
    FOREIGN KEY (new_plan_id) REFERENCES plans(id) ON DELETE CASCADE,
    FOREIGN KEY (follower_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (original_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_original_plan (original_plan_id),
    INDEX idx_follower_user (follower_user_id),
    INDEX idx_original_user (original_user_id)
) ENGINE=InnoDB COMMENT='计划跟随表';

-- 计划评论表
CREATE TABLE plan_comments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    plan_id BIGINT NOT NULL COMMENT '计划ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    parent_id BIGINT DEFAULT NULL COMMENT '父评论ID（回复）',
    content TEXT NOT NULL COMMENT '评论内容',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES plan_comments(id) ON DELETE CASCADE,
    INDEX idx_plan_id (plan_id),
    INDEX idx_user_id (user_id),
    INDEX idx_parent_id (parent_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB COMMENT='计划评论表';

-- 用户关注表
CREATE TABLE user_follows (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    follower_id BIGINT NOT NULL COMMENT '关注者ID',
    following_id BIGINT NOT NULL COMMENT '被关注者ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
    FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_follower_following (follower_id, following_id),
    INDEX idx_follower (follower_id),
    INDEX idx_following (following_id)
) ENGINE=InnoDB COMMENT='用户关注表';

-- 系统通知表
CREATE TABLE notifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    type ENUM('plan_reminder', 'plan_like', 'plan_comment', 'plan_follow', 'user_follow') NOT NULL COMMENT '通知类型',
    title VARCHAR(100) NOT NULL COMMENT '通知标题',
    content TEXT DEFAULT NULL COMMENT '通知内容',
    related_id BIGINT DEFAULT NULL COMMENT '关联ID（计划ID、评论ID等）',
    is_read BOOLEAN DEFAULT FALSE COMMENT '是否已读',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB COMMENT='系统通知表';

-- 插入示例数据
INSERT INTO users (username, email, password_hash, nickname) VALUES 
('demo_user', 'demo@planplanet.com', '$2b$10$example_hash', '演示用户'),
('test_user', 'test@planplanet.com', '$2b$10$example_hash', '测试用户');

INSERT INTO plans (user_id, title, description, type, category, priority, start_date, target_count, unit, is_public) VALUES 
(1, '每天阅读30分钟', '培养阅读习惯，提升知识储备', 'daily', 'study', 'high', CURDATE(), 30, '分钟', TRUE),
(1, '完成项目文档', '整理并完善项目相关文档', 'once', 'work', 'medium', CURDATE(), NULL, NULL, FALSE),
(2, '每周跑步3次', '保持身体健康，提高体能', 'weekly', 'health', 'high', CURDATE(), 3, '次', TRUE);
