-- 健身房管理系统 测试数据（MySQL 8）
-- 说明：
-- - 默认密码：123456（BCrypt）
-- - 建议在测试库执行；会按 username/equipment_code 等做清理后重建

SET NAMES utf8mb4;

-- ----------------------------
-- 1) 清理（仅清理本脚本涉及的数据）
-- ----------------------------
DELETE FROM gym_course_review WHERE member_id IN (1001) OR schedule_id IN (3001,3002,3003);
DELETE FROM gym_course_booking WHERE member_id IN (1001) OR schedule_id IN (3001,3002,3003);
DELETE FROM gym_course_schedule WHERE id IN (3001,3002,3003);
DELETE FROM gym_course WHERE id IN (2001,2002,2003);
DELETE FROM gym_coach WHERE id IN (1101,1102);
DELETE FROM gym_member WHERE id IN (1001,1002);
DELETE FROM gym_equipment WHERE equipment_code IN ('EQ-TM-001','EQ-EL-001','EQ-BK-001');
DELETE FROM sys_user WHERE username IN ('admin','coach_lee','coach_chen','member_li','member_zhang');

-- ----------------------------
-- 2) 用户（sys_user）
-- user_type: 1会员 2教练 3管理员
-- ----------------------------
-- BCrypt(123456) = $2a$10$QIIzlSSmcS1/6hem/hMMYu7MkiF7B4VbZAgglocxXPGmE59pzrrKO
INSERT INTO sys_user (id, username, password, nickname, phone, status, user_type, deleted)
VALUES
  (1,  'admin',       '$2a$10$QIIzlSSmcS1/6hem/hMMYu7MkiF7B4VbZAgglocxXPGmE59pzrrKO', '管理员', '13800000000', 1, 3, 0),
  (11, 'coach_lee',   '$2a$10$QIIzlSSmcS1/6hem/hMMYu7MkiF7B4VbZAgglocxXPGmE59pzrrKO', '李教练', '13800000011', 1, 2, 0),
  (12, 'coach_chen',  '$2a$10$QIIzlSSmcS1/6hem/hMMYu7MkiF7B4VbZAgglocxXPGmE59pzrrKO', '陈教练', '13800000012', 1, 2, 0),
  (21, 'member_li',   '$2a$10$QIIzlSSmcS1/6hem/hMMYu7MkiF7B4VbZAgglocxXPGmE59pzrrKO', '李雷',   '13800000021', 1, 1, 0),
  (22, 'member_zhang','$2a$10$QIIzlSSmcS1/6hem/hMMYu7MkiF7B4VbZAgglocxXPGmE59pzrrKO', '张三',   '13800000022', 1, 1, 0);

-- ----------------------------
-- 3) 教练（gym_coach）
-- ----------------------------
INSERT INTO gym_coach (id, user_id, title, intro, years_exp, specialty, rating, deleted)
VALUES
  (1101, 11, '高级私教', '擅长增肌塑形与力量训练', 6, '增肌/力量/塑形', 4.9, 0),
  (1102, 12, '团课教练', '擅长燃脂与HIIT团课',     4, '燃脂/HIIT/有氧', 4.8, 0);

-- ----------------------------
-- 4) 会员（gym_member）
-- ----------------------------
INSERT INTO gym_member (id, user_id, gender, join_date, level, remark, deleted)
VALUES
  (1001, 21, 1, CURDATE(), 2, '测试会员A', 0),
  (1002, 22, 2, CURDATE(), 1, '测试会员B', 0);

-- ----------------------------
-- 5) 课程（gym_course）
-- ----------------------------
INSERT INTO gym_course (id, name, cover_url, description, max_participants, duration_min, difficulty, coach_id, deleted)
VALUES
  (2001, '力量训练入门', NULL, '全身基础力量与动作模式训练', 20, 60, 1, 1101, 0),
  (2002, 'HIIT燃脂团课', NULL, '高强度间歇训练，提升心肺与燃脂效率', 30, 45, 2, 1102, 0),
  (2003, '核心稳定训练', NULL, '核心力量与稳定性提升', 25, 50, 1, 1101, 0);

-- ----------------------------
-- 6) 课程排期（gym_course_schedule）
-- status: 1正常 2取消 3已结束
-- ----------------------------
INSERT INTO gym_course_schedule (id, course_id, coach_id, room, start_time, end_time, capacity, booked_count, status, deleted)
VALUES
  (3001, 2001, 1101, 'A馆-团课室1', DATE_ADD(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 1 DAY) + INTERVAL 60 MINUTE, 20, 0, 1, 0),
  (3002, 2002, 1102, 'A馆-团课室2', DATE_ADD(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 2 DAY) + INTERVAL 45 MINUTE, 30, 0, 1, 0),
  (3003, 2003, 1101, 'A馆-团课室1', DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL 3 DAY) + INTERVAL 50 MINUTE, 25, 0, 1, 0);

-- ----------------------------
-- 7) 器材（gym_equipment）
-- status: 1正常 2故障 3维护中 4停用
-- ----------------------------
INSERT INTO gym_equipment (equipment_code, name, type, location, status, install_date, deleted)
VALUES
  ('EQ-TM-001', '跑步机-01', '跑步机', 'A馆-有氧区', 1, '2025-01-10', 0),
  ('EQ-EL-001', '椭圆机-01', '椭圆机', 'A馆-有氧区', 1, '2025-02-15', 0),
  ('EQ-BK-001', '动感单车-01', '动感单车', 'A馆-单车区', 3, '2024-12-01', 0);

