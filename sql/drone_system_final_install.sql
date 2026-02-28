-- =============================================================================
-- 无人机飞行管理系统 - 最终整合安装脚本（仅含本系统新增/修改内容）
-- 前置条件：已执行 1) 若依基础初始化 SQL（如 ry_20250522.sql）
--           2) 业务表与菜单 SQL（drone_flight.sql）
-- 本脚本可重复执行：菜单/角色/首页修复为幂等；模拟数据与 user1 存在则跳过；ALTER 段重复执行可能报“重复列”可注释
-- =============================================================================
SET NAMES utf8mb4;

-- =============================================================================
-- 一、菜单结构修复
-- =============================================================================

-- 1.1 删除「若依官网」菜单及其 role_menu
DELETE FROM sys_role_menu WHERE menu_id IN (SELECT menu_id FROM sys_menu WHERE path = 'http://ruoyi.vip' OR (menu_name = '若依官网' AND parent_id = 0));
DELETE FROM sys_menu WHERE path = 'http://ruoyi.vip' OR (menu_name = '若依官网' AND parent_id = 0);

-- 1.2 删除「统计报表」及其子按钮、role_menu
SET @stats_id = (SELECT menu_id FROM sys_menu WHERE path = 'statistics' AND menu_type = 'C' LIMIT 1);
DELETE FROM sys_role_menu WHERE menu_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path = 'statistics' OR (parent_id = @stats_id AND @stats_id IS NOT NULL)) t);
DELETE FROM sys_menu WHERE path = 'statistics' OR (parent_id = @stats_id AND @stats_id IS NOT NULL);

-- 1.3 删除「无人机飞行管理」父级，将业务菜单提升为一级（扁平化）
SET @drone_parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'drone' AND parent_id = 0 LIMIT 1);
DELETE FROM sys_role_menu WHERE menu_id = @drone_parent_id;
UPDATE sys_menu SET parent_id = 0, order_num = CASE path WHEN 'droneInfo' THEN 1 WHEN 'application' THEN 2 WHEN 'approve' THEN 3 WHEN 'permission' THEN 4 WHEN 'monitor' THEN 5 WHEN 'violation' THEN 6 ELSE order_num END
WHERE parent_id = @drone_parent_id;
DELETE FROM sys_menu WHERE menu_id = @drone_parent_id;

-- =============================================================================
-- 二、角色结构修复
-- =============================================================================

-- 2.1 若已存在 drone_user 则先删除其关联（便于重复执行时重建权限）
DELETE FROM sys_user_role WHERE role_id IN (SELECT role_id FROM (SELECT role_id FROM sys_role WHERE role_key = 'drone_user') t);
DELETE FROM sys_role_menu WHERE role_id IN (SELECT role_id FROM (SELECT role_id FROM sys_role WHERE role_key = 'drone_user') t);

-- 2.2 不存在则创建「无人机用户」角色
INSERT INTO sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
SELECT '无人机用户', 'drone_user', 5, '5', 1, 1, '0', '0', 'admin', NOW(), '完整业务：首页(个人统计)、无人机管理、飞行申请、飞行权限(只读)、监控(只读)；不可审批、不可违规、不可系统管理'
FROM (SELECT 1) t
WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key = 'drone_user' LIMIT 1);

SET @drone_user_role_id = (SELECT role_id FROM sys_role WHERE role_key = 'drone_user' LIMIT 1);

-- =============================================================================
-- 三、菜单权限分配（drone_user 仅业务菜单，不分配审批/违规/系统管理）
-- =============================================================================

-- 3.1 首页
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT @drone_user_role_id, menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'index' LIMIT 1
WHERE @drone_user_role_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @drone_user_role_id AND menu_id = (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'index' LIMIT 1));

INSERT INTO sys_role_menu (role_id, menu_id)
SELECT @drone_user_role_id, menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'droneInfo' LIMIT 1
WHERE @drone_user_role_id IS NOT NULL AND (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'droneInfo' LIMIT 1) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = @drone_user_role_id AND rm.menu_id = (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'droneInfo' LIMIT 1));

INSERT INTO sys_role_menu (role_id, menu_id) SELECT @drone_user_role_id, m.menu_id FROM sys_menu m
WHERE m.parent_id = (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'droneInfo' LIMIT 1)
  AND (m.perms = 'drone:droneInfo:list' OR m.perms IN ('drone:droneInfo:query','drone:droneInfo:add','drone:droneInfo:edit','drone:droneInfo:remove'))
  AND @drone_user_role_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = @drone_user_role_id AND rm.menu_id = m.menu_id);

INSERT INTO sys_role_menu (role_id, menu_id) SELECT @drone_user_role_id, menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'application' LIMIT 1
WHERE @drone_user_role_id IS NOT NULL AND (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'application' LIMIT 1) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = @drone_user_role_id AND rm.menu_id = (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'application' LIMIT 1));

INSERT INTO sys_role_menu (role_id, menu_id) SELECT @drone_user_role_id, m.menu_id FROM sys_menu m
WHERE m.parent_id = (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'application' LIMIT 1)
  AND (m.perms = 'drone:application:list' OR m.perms IN ('drone:application:query','drone:application:add','drone:application:edit','drone:application:remove'))
  AND @drone_user_role_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = @drone_user_role_id AND rm.menu_id = m.menu_id);

INSERT INTO sys_role_menu (role_id, menu_id) SELECT @drone_user_role_id, menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'permission' LIMIT 1
WHERE @drone_user_role_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = @drone_user_role_id AND rm.menu_id = (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'permission' LIMIT 1));

INSERT INTO sys_role_menu (role_id, menu_id) SELECT @drone_user_role_id, m.menu_id FROM sys_menu m
WHERE m.parent_id = (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'permission' LIMIT 1)
  AND (m.perms = 'drone:permission:list' OR m.perms = 'drone:permission:query')
  AND @drone_user_role_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = @drone_user_role_id AND rm.menu_id = m.menu_id);

INSERT INTO sys_role_menu (role_id, menu_id) SELECT @drone_user_role_id, menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'monitor' LIMIT 1
WHERE @drone_user_role_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = @drone_user_role_id AND rm.menu_id = (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'monitor' LIMIT 1));

INSERT INTO sys_role_menu (role_id, menu_id) SELECT @drone_user_role_id, m.menu_id FROM sys_menu m
WHERE m.parent_id = (SELECT menu_id FROM sys_menu WHERE parent_id = 0 AND path = 'monitor' LIMIT 1)
  AND (m.perms = 'drone:monitor:list' OR m.perms = 'drone:monitor:query')
  AND @drone_user_role_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = @drone_user_role_id AND rm.menu_id = m.menu_id);

-- =============================================================================
-- 四、首页权限修复
-- =============================================================================

-- 4.1 若不存在首页菜单则新增，并保证 parent_id=0、menu_type='C'、status='0'、visible='0'
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '首页', 0, 0, 'index', 'index', '', 'Index', 1, 0, 'C', '0', '0', 'index:view', 'dashboard', 'admin', NOW(), '首页-统计报表'
FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE path = 'index' AND parent_id = 0 LIMIT 1);

UPDATE sys_menu SET parent_id = 0, menu_type = 'C', status = '0', visible = '0' WHERE path = 'index';

-- 4.2 为管理员(role_id=1)分配首页（若未分配）
INSERT INTO sys_role_menu (role_id, menu_id) SELECT 1, menu_id FROM sys_menu WHERE path = 'index' AND parent_id = 0 LIMIT 1
WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = 1 AND menu_id = (SELECT menu_id FROM sys_menu WHERE path = 'index' AND parent_id = 0 LIMIT 1));

-- 4.3 为 drone_user 分配首页（若未分配）
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT @drone_user_role_id, (SELECT menu_id FROM sys_menu WHERE path = 'index' LIMIT 1)
FROM (SELECT 1) t
WHERE @drone_user_role_id IS NOT NULL AND (SELECT menu_id FROM sys_menu WHERE path = 'index' LIMIT 1) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = @drone_user_role_id AND rm.menu_id = (SELECT menu_id FROM sys_menu WHERE path = 'index' LIMIT 1));

-- =============================================================================
-- 五、监控表结构增强（若表已存在但缺字段则追加）
-- 重复执行时若报“Duplicate column name”请注释本段（说明已执行过）
-- =============================================================================

ALTER TABLE flight_monitor ADD COLUMN longitude DOUBLE DEFAULT NULL COMMENT '经度' AFTER real_time_location;
ALTER TABLE flight_monitor ADD COLUMN latitude DOUBLE DEFAULT NULL COMMENT '纬度' AFTER longitude;
ALTER TABLE flight_monitor ADD COLUMN speed DECIMAL(10,2) DEFAULT NULL COMMENT '速度(m/s)' AFTER current_height;
ALTER TABLE flight_monitor ADD COLUMN flight_time DATETIME DEFAULT NULL COMMENT '飞行时间点' AFTER warning_flag;
ALTER TABLE flight_monitor ADD COLUMN is_violation CHAR(1) DEFAULT '0' COMMENT '是否违规（0正常1违规）' AFTER flight_time;
ALTER TABLE flight_monitor ADD INDEX idx_flight_time (flight_time);
ALTER TABLE violation_record ADD COLUMN longitude DOUBLE DEFAULT NULL COMMENT '经度' AFTER description;
ALTER TABLE violation_record ADD COLUMN latitude DOUBLE DEFAULT NULL COMMENT '纬度' AFTER longitude;

-- =============================================================================
-- 六、模拟测试数据（3 条飞行任务，每条 20 条轨迹，含违规点；建议仅执行一次）
-- =============================================================================

SET @admin_id = (SELECT user_id FROM sys_user WHERE user_name = 'admin' LIMIT 1);

INSERT INTO drone_info (drone_name, drone_model, serial_number, owner_id, status, remark, create_by, create_time)
SELECT 'M1-正常', 'Matrice 300', 'SN-FIN-T01', @admin_id, '0', '最终脚本-任务1', 'admin', NOW() FROM (SELECT 1) t
WHERE @admin_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM drone_info WHERE serial_number = 'SN-FIN-T01');
SET @d1 = (SELECT id FROM drone_info WHERE serial_number = 'SN-FIN-T01' LIMIT 1);

INSERT INTO flight_application (application_no, applicant_id, drone_id, flight_area, flight_height, start_time, end_time, purpose, status, approve_user, approve_time, create_by, create_time)
SELECT 'FA-FIN-001', @admin_id, @d1, '武汉东湖A区', 120, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '正常飞行', '1', @admin_id, NOW(), 'admin', NOW()
FROM (SELECT 1) t WHERE @d1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_application WHERE application_no = 'FA-FIN-001');
SET @a1 = (SELECT id FROM flight_application WHERE application_no = 'FA-FIN-001' LIMIT 1);

INSERT INTO flight_permission (application_id, approved_area, approved_height, approved_start_time, approved_end_time, permission_status, create_by, create_time)
SELECT @a1, '东湖A区', 120, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '0', 'admin', NOW() FROM (SELECT 1) t WHERE @a1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_permission WHERE application_id = @a1);
SET @p1 = (SELECT id FROM flight_permission WHERE application_id = @a1 LIMIT 1);

INSERT INTO flight_monitor (permission_id, longitude, latitude, current_height, speed, flight_time, is_violation, create_by, create_time)
SELECT @p1, 114.40 + n*0.01, 30.51, 80 + n*2, 5.0, DATE_ADD(NOW(), INTERVAL n*3 MINUTE), '0', 'system', NOW()
FROM (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
      UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19) nums
WHERE @p1 IS NOT NULL AND (SELECT COUNT(1) FROM flight_monitor WHERE permission_id = @p1) < 20;

INSERT INTO drone_info (drone_name, drone_model, serial_number, owner_id, status, remark, create_by, create_time)
SELECT 'M2-超高', 'Phantom 4', 'SN-FIN-T02', @admin_id, '0', '最终脚本-任务2', 'admin', NOW() FROM (SELECT 1) t
WHERE @admin_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM drone_info WHERE serial_number = 'SN-FIN-T02');
SET @d2 = (SELECT id FROM drone_info WHERE serial_number = 'SN-FIN-T02' LIMIT 1);

INSERT INTO flight_application (application_no, applicant_id, drone_id, flight_area, flight_height, start_time, end_time, purpose, status, approve_user, approve_time, create_by, create_time)
SELECT 'FA-FIN-002', @admin_id, @d2, '武汉东湖B区', 100, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '超高测试', '1', @admin_id, NOW(), 'admin', NOW()
FROM (SELECT 1) t WHERE @d2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_application WHERE application_no = 'FA-FIN-002');
SET @a2 = (SELECT id FROM flight_application WHERE application_no = 'FA-FIN-002' LIMIT 1);

INSERT INTO flight_permission (application_id, approved_area, approved_height, approved_start_time, approved_end_time, permission_status, create_by, create_time)
SELECT @a2, '东湖B区', 100, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '0', 'admin', NOW() FROM (SELECT 1) t WHERE @a2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_permission WHERE application_id = @a2);
SET @p2 = (SELECT id FROM flight_permission WHERE application_id = @a2 LIMIT 1);

INSERT INTO flight_monitor (permission_id, longitude, latitude, current_height, speed, flight_time, is_violation, create_by, create_time)
SELECT @p2, 114.35 + n*0.01, 30.52, LEAST(85 + n*4, 125), 6.0, DATE_ADD(NOW(), INTERVAL n*3 MINUTE), IF(85 + n*4 > 100, '1', '0'), 'system', NOW()
FROM (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
      UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19) nums
WHERE @p2 IS NOT NULL AND (SELECT COUNT(1) FROM flight_monitor WHERE permission_id = @p2) < 20;

INSERT INTO violation_record (permission_id, violation_type, description, longitude, latitude, handle_status, create_by, create_time)
SELECT @p2, 'over_height', '飞行高度超过批准值100m', 114.362, 30.52, '0', 'system', NOW() FROM (SELECT 1) t
WHERE @p2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM violation_record WHERE permission_id = @p2 AND violation_type = 'over_height');

INSERT INTO drone_info (drone_name, drone_model, serial_number, owner_id, status, remark, create_by, create_time)
SELECT 'M3-越界', 'Mavic 3', 'SN-FIN-T03', @admin_id, '0', '最终脚本-任务3', 'admin', NOW() FROM (SELECT 1) t
WHERE @admin_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM drone_info WHERE serial_number = 'SN-FIN-T03');
SET @d3 = (SELECT id FROM drone_info WHERE serial_number = 'SN-FIN-T03' LIMIT 1);

INSERT INTO flight_application (application_no, applicant_id, drone_id, flight_area, flight_height, start_time, end_time, purpose, status, approve_user, approve_time, create_by, create_time)
SELECT 'FA-FIN-003', @admin_id, @d3, '武汉东湖C区', 80, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '越界测试', '1', @admin_id, NOW(), 'admin', NOW()
FROM (SELECT 1) t WHERE @d3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_application WHERE application_no = 'FA-FIN-003');
SET @a3 = (SELECT id FROM flight_application WHERE application_no = 'FA-FIN-003' LIMIT 1);

INSERT INTO flight_permission (application_id, approved_area, approved_height, approved_start_time, approved_end_time, permission_status, create_by, create_time)
SELECT @a3, '东湖C区', 80, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '0', 'admin', NOW() FROM (SELECT 1) t WHERE @a3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_permission WHERE application_id = @a3);
SET @p3 = (SELECT id FROM flight_permission WHERE application_id = @a3 LIMIT 1);

INSERT INTO flight_monitor (permission_id, longitude, latitude, current_height, speed, flight_time, is_violation, create_by, create_time)
SELECT @p3, 114.45 + n*0.015 + IF(n>=12, 0.05, 0), 30.50, 75 + (n MOD 5), 5.5, DATE_ADD(NOW(), INTERVAL n*3 MINUTE), IF(n >= 12 AND n <= 14, '1', '0'), 'system', NOW()
FROM (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
      UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19) nums
WHERE @p3 IS NOT NULL AND (SELECT COUNT(1) FROM flight_monitor WHERE permission_id = @p3) < 20;

INSERT INTO violation_record (permission_id, violation_type, description, longitude, latitude, handle_status, create_by, create_time)
SELECT @p3, 'out_of_bounds', '偏离批准空域', 114.468, 30.50, '0', 'system', NOW() FROM (SELECT 1) t
WHERE @p3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM violation_record WHERE permission_id = @p3 AND violation_type = 'out_of_bounds');

-- =============================================================================
-- 七、测试用户 user1（密码同 admin 默认；需 123456 请在「用户管理」中重置）
-- =============================================================================

INSERT INTO sys_user (dept_id, user_name, nick_name, user_type, email, phonenumber, sex, avatar, password, status, del_flag, create_by, create_time, remark)
SELECT 103, 'user1', '无人机测试用户', '00', 'user1@test.com', '13800000001', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), '普通用户-完整业务权限'
FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name = 'user1');

SET @user1_id = (SELECT user_id FROM sys_user WHERE user_name = 'user1' LIMIT 1);
INSERT INTO sys_user_role (user_id, role_id)
SELECT @user1_id, @drone_user_role_id FROM (SELECT 1) t
WHERE @user1_id IS NOT NULL AND @drone_user_role_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys_user_role WHERE user_id = @user1_id AND role_id = @drone_user_role_id);

-- =============================================================================
-- 结束
-- =============================================================================
