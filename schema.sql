-- 健身房管理系统 数据库建表语句（MySQL 8）
-- 字符集：utf8mb4
-- 引擎：InnoDB
-- 临时关闭外键检查，避免建表/插入顺序导致约束报错
SET FOREIGN_KEY_CHECKS = 0;

-- ============================
-- 通用：系统与权限
-- ============================

CREATE TABLE IF NOT EXISTS sys_user (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    username     VARCHAR(50) NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,
    nickname     VARCHAR(50),
    phone        VARCHAR(20),
    email        VARCHAR(100),
    avatar       VARCHAR(255),
    status       TINYINT NOT NULL DEFAULT 1, -- 1启用 0禁用
    user_type    TINYINT NOT NULL DEFAULT 1, -- 1会员 2教练 3管理员等
    last_login_at DATETIME,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted      TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_role (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    code        VARCHAR(50) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted     TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_user_role (
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id    BIGINT NOT NULL,
    role_id    BIGINT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted    TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT uk_user_role UNIQUE (user_id, role_id),
    INDEX idx_user_role_user (user_id),
    INDEX idx_user_role_role (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_permission (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    code        VARCHAR(100) NOT NULL UNIQUE, -- 如 api:member:list
    name        VARCHAR(100) NOT NULL,
    type        TINYINT NOT NULL, -- 1菜单 2按钮 3接口
    path        VARCHAR(255),     -- 前端路由/后端接口路径
    method      VARCHAR(10),      -- GET/POST等(接口类)
    parent_id   BIGINT DEFAULT NULL,
    sort        INT DEFAULT 0,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted     TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_role_permission (
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_id        BIGINT NOT NULL,
    permission_id  BIGINT NOT NULL,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted        TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT uk_role_perm UNIQUE (role_id, permission_id),
    INDEX idx_role_perm_role (role_id),
    INDEX idx_role_perm_perm (permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================
-- 会员模块
-- ============================

CREATE TABLE IF NOT EXISTS gym_member (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id      BIGINT NOT NULL UNIQUE,
    gender       TINYINT,           -- 1男 2女
    birthday     DATE,
    height_cm    INT,
    weight_kg    DECIMAL(5,2),
    join_date    DATE,
    level        TINYINT DEFAULT 1, -- 1普通 2高级 3VIP等
    remark       VARCHAR(255),
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted      TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_member_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS gym_member_wallet (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id    BIGINT NOT NULL UNIQUE,
    balance      DECIMAL(10,2) NOT NULL DEFAULT 0,
    points       INT NOT NULL DEFAULT 0,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted      TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_wallet_member (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS gym_member_wallet_tx (
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id     BIGINT NOT NULL,
    type          TINYINT NOT NULL,        -- 1充值 2消费 3退款
    amount        DECIMAL(10,2) NOT NULL,
    balance_after DECIMAL(10,2) NOT NULL,
    channel       VARCHAR(50),             -- 支付宝/微信/现金等
    biz_type      VARCHAR(50),             -- 业务类型: 课程预约等
    biz_id        BIGINT,                  -- 关联业务ID
    remark        VARCHAR(255),
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted       TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_wallet_tx_member_time (member_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================
-- 教练模块
-- ============================

CREATE TABLE IF NOT EXISTS gym_coach (
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id       BIGINT NOT NULL UNIQUE,
    title         VARCHAR(100),   -- 头衔: 私教/高级教练等
    intro         TEXT,
    years_exp     INT,
    specialty     VARCHAR(255),   -- 擅长：减脂/增肌等
    rating        DECIMAL(3,2) DEFAULT 5.00,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted       TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_coach_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS gym_coach_schedule (
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    coach_id      BIGINT NOT NULL,
    work_date     DATE NOT NULL,
    start_time    TIME NOT NULL,
    end_time      TIME NOT NULL,
    status        TINYINT NOT NULL DEFAULT 1, -- 1可约 2已满 3休息
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted       TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_coach_schedule (coach_id, work_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================
-- 课程/预约模块
-- ============================

CREATE TABLE IF NOT EXISTS gym_course (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(100) NOT NULL,
    cover_url    VARCHAR(255),
    description  TEXT,
    max_participants INT NOT NULL,
    duration_min INT NOT NULL,
    difficulty   TINYINT,            -- 1-初级 2-中级 3-高级
    coach_id     BIGINT,             -- 课程主教练(可选)
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted      TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_course_coach (coach_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS gym_course_schedule (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    course_id       BIGINT NOT NULL,
    coach_id        BIGINT NOT NULL,
    room            VARCHAR(100),
    start_time      DATETIME NOT NULL,
    end_time        DATETIME NOT NULL,
    capacity        INT NOT NULL,
    booked_count    INT NOT NULL DEFAULT 0,
    status          TINYINT NOT NULL DEFAULT 1, -- 1正常 2取消 3已结束
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted         TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_course_schedule_time (start_time, end_time),
    INDEX idx_course_schedule_course (course_id),
    INDEX idx_cs_coach (coach_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS gym_course_booking (
    id                BIGINT PRIMARY KEY AUTO_INCREMENT,
    schedule_id       BIGINT NOT NULL,
    member_id         BIGINT NOT NULL,
    booking_time      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status            TINYINT NOT NULL DEFAULT 1, -- 1已预约 2已取消 3已签到 4缺席
    checkin_time      DATETIME,
    cancel_time       DATETIME,
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted           TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_booking_member (member_id, booking_time),
    INDEX idx_booking_schedule (schedule_id),
    CONSTRAINT uk_booking_member_schedule UNIQUE (schedule_id, member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS gym_course_review (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    schedule_id     BIGINT NOT NULL,
    member_id       BIGINT NOT NULL,
    rating          TINYINT NOT NULL,          -- 1-5星
    comment         VARCHAR(500),
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted         TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_review_schedule (schedule_id),
    INDEX idx_review_member (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================
-- 器材/物联网模块
-- ============================

CREATE TABLE IF NOT EXISTS gym_equipment (
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    equipment_code VARCHAR(50) NOT NULL UNIQUE, -- 与设备/传感器上报使用的唯一编码
    name           VARCHAR(100) NOT NULL,
    type           VARCHAR(50),     -- 跑步机/椭圆机等
    location       VARCHAR(100),    -- 場館/区域
    status         TINYINT NOT NULL DEFAULT 1, -- 1正常 2故障 3维护中 4停用
    install_date   DATE,
    last_online_at DATETIME,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted        TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS gym_equipment_sensor (
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    equipment_id   BIGINT NOT NULL,
    sensor_code    VARCHAR(100) NOT NULL,     -- 传感器编码
    sensor_type    VARCHAR(50) NOT NULL,      -- 温度/震动/心率等
    unit           VARCHAR(20),               -- 单位: ℃, bpm等
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted        TINYINT(1) NOT NULL DEFAULT 0,
    UNIQUE (equipment_id, sensor_code),
    INDEX idx_sensor_equipment (equipment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS gym_equipment_data (
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    equipment_id   BIGINT NOT NULL,
    sensor_code    VARCHAR(100) NOT NULL,
    value          VARCHAR(50) NOT NULL,
    reported_at    DATETIME NOT NULL,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_equipment_data_eq_time (equipment_id, reported_at),
    INDEX idx_equipment_data_sensor (sensor_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS gym_equipment_fault (
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    equipment_id   BIGINT NOT NULL,
    reported_by    BIGINT,                  -- 会员/员工ID，可为空（自动检测）
    fault_type     VARCHAR(100),
    description    VARCHAR(500),
    fault_level    TINYINT DEFAULT 1,       -- 严重程度
    status         TINYINT NOT NULL DEFAULT 1, -- 1待处理 2处理中 3已解决 4已关闭
    reported_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at    DATETIME,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted        TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_fault_equipment (equipment_id, reported_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS gym_equipment_maintenance (
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    equipment_id   BIGINT NOT NULL,
    fault_id       BIGINT,
    maintenance_no VARCHAR(50) NOT NULL UNIQUE,
    assigned_to    BIGINT,                 -- 维护人员ID(可与sys_user关联)
    plan_time      DATETIME,
    start_time     DATETIME,
    end_time       DATETIME,
    status         TINYINT NOT NULL DEFAULT 1, -- 1待处理 2处理中 3已完成 4已取消
    remark         VARCHAR(500),
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted        TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_maint_equipment (equipment_id),
    INDEX idx_maint_fault (fault_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
