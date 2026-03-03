-- =============================================================================
-- 无人机飞行权限管理与审批系统 - 一键安装脚本（整合版）
-- 前置条件：已执行若依基础 SQL（如 ry_20250522.sql 或项目要求的若依初始化脚本）
-- 本脚本包含：业务表、字典、菜单、角色、drone_user 权限、首页、表结构增强、模拟数据、测试用户 user1
-- 可重复执行：表会 DROP 后重建；菜单/角色/权限为幂等；模拟数据与 user1 存在则跳过；ALTER 重复执行若报“重复列”请注释该段
-- =============================================================================
SET NAMES utf8mb4;

-- =============================================================================
-- 一、业务表
-- =============================================================================
DROP TABLE IF EXISTS flight_monitor;
DROP TABLE IF EXISTS violation_record;
DROP TABLE IF EXISTS flight_permission;
DROP TABLE IF EXISTS flight_application;
DROP TABLE IF EXISTS drone_info;

CREATE TABLE drone_info (
  id              BIGINT          NOT NULL AUTO_INCREMENT    COMMENT '主键ID',
  drone_name      VARCHAR(100)    NOT NULL                   COMMENT '无人机名称',
  drone_model     VARCHAR(100)    DEFAULT ''                 COMMENT '机型型号',
  serial_number   VARCHAR(100)    NOT NULL                   COMMENT '序列号（唯一）',
  owner_id        BIGINT          DEFAULT NULL               COMMENT '所属用户ID',
  status          CHAR(1)         DEFAULT '0'                COMMENT '状态（0正常 1停用）',
  remark          VARCHAR(500)   DEFAULT NULL               COMMENT '备注',
  create_by       VARCHAR(64)     DEFAULT ''                 COMMENT '创建者',
  create_time     DATETIME                                   COMMENT '创建时间',
  update_by       VARCHAR(64)     DEFAULT ''                 COMMENT '更新者',
  update_time     DATETIME                                   COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_serial_number (serial_number),
  KEY idx_owner_id (owner_id),
  KEY idx_status (status),
  CONSTRAINT fk_drone_owner FOREIGN KEY (owner_id) REFERENCES sys_user (user_id) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='无人机信息表';

CREATE TABLE flight_application (
  id               BIGINT          NOT NULL AUTO_INCREMENT    COMMENT '主键ID',
  application_no   VARCHAR(64)     NOT NULL                   COMMENT '申请单号',
  applicant_id     BIGINT          NOT NULL                   COMMENT '申请人ID',
  drone_id         BIGINT          NOT NULL                   COMMENT '无人机ID',
  flight_area      VARCHAR(500)    NOT NULL                   COMMENT '飞行区域',
  flight_height    INT             DEFAULT 0                  COMMENT '申请飞行高度(m)',
  start_time       DATETIME        NOT NULL                   COMMENT '计划开始时间',
  end_time         DATETIME        NOT NULL                   COMMENT '计划结束时间',
  purpose          VARCHAR(500)   DEFAULT ''                 COMMENT '飞行目的',
  status           CHAR(1)         DEFAULT '0'                COMMENT '状态（0待审批 1已通过 2已驳回）',
  approve_user     BIGINT          DEFAULT NULL               COMMENT '审批人ID',
  approve_time     DATETIME        DEFAULT NULL               COMMENT '审批时间',
  approve_remark   VARCHAR(500)   DEFAULT NULL               COMMENT '审批意见/驳回原因',
  second_approve_user BIGINT       DEFAULT NULL               COMMENT '二次审批人（预留）',
  second_approve_time DATETIME     DEFAULT NULL               COMMENT '二次审批时间（预留）',
  create_by        VARCHAR(64)     DEFAULT ''                 COMMENT '创建者',
  create_time      DATETIME                                   COMMENT '创建时间',
  update_by        VARCHAR(64)     DEFAULT ''                 COMMENT '更新者',
  update_time      DATETIME                                   COMMENT '更新时间',
  remark           VARCHAR(500)   DEFAULT NULL                COMMENT '备注',
  PRIMARY KEY (id),
  UNIQUE KEY uk_application_no (application_no),
  KEY idx_applicant_id (applicant_id),
  KEY idx_drone_id (drone_id),
  KEY idx_status (status),
  KEY idx_create_time (create_time),
  CONSTRAINT fk_application_applicant FOREIGN KEY (applicant_id) REFERENCES sys_user (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_application_drone FOREIGN KEY (drone_id) REFERENCES drone_info (id) ON DELETE CASCADE,
  CONSTRAINT fk_application_approve_user FOREIGN KEY (approve_user) REFERENCES sys_user (user_id) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='飞行申请表';

CREATE TABLE flight_permission (
  id                   BIGINT          NOT NULL AUTO_INCREMENT    COMMENT '主键ID',
  application_id       BIGINT          NOT NULL                   COMMENT '关联申请ID',
  approved_area        VARCHAR(500)    NOT NULL                   COMMENT '批准飞行区域',
  approved_height      INT             DEFAULT 0                  COMMENT '批准飞行高度(m)',
  approved_start_time  DATETIME        NOT NULL                   COMMENT '批准开始时间',
  approved_end_time    DATETIME        NOT NULL                   COMMENT '批准结束时间',
  permission_status    CHAR(1)         DEFAULT '0'                COMMENT '权限状态（0有效 1已过期 2已撤销）',
  create_by            VARCHAR(64)     DEFAULT ''                 COMMENT '创建者',
  create_time          DATETIME                                   COMMENT '创建时间',
  update_by            VARCHAR(64)     DEFAULT ''                 COMMENT '更新者',
  update_time          DATETIME                                   COMMENT '更新时间',
  remark               VARCHAR(500)   DEFAULT NULL                COMMENT '备注',
  PRIMARY KEY (id),
  KEY idx_application_id (application_id),
  KEY idx_permission_status (permission_status),
  KEY idx_approved_time (approved_start_time, approved_end_time),
  CONSTRAINT fk_permission_application FOREIGN KEY (application_id) REFERENCES flight_application (id) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='飞行权限表';

CREATE TABLE flight_monitor (
  id                 BIGINT          NOT NULL AUTO_INCREMENT    COMMENT '主键ID',
  permission_id       BIGINT          NOT NULL                   COMMENT '关联权限ID',
  real_time_location VARCHAR(200)   DEFAULT ''                 COMMENT '实时位置',
  longitude          DOUBLE          DEFAULT NULL               COMMENT '经度',
  latitude           DOUBLE          DEFAULT NULL               COMMENT '纬度',
  current_height     INT             DEFAULT 0                  COMMENT '当前高度(m)',
  speed              DECIMAL(10,2)   DEFAULT NULL               COMMENT '速度(m/s)',
  warning_flag       CHAR(1)         DEFAULT '0'                COMMENT '告警标志（0正常 1告警）',
  flight_time        DATETIME        DEFAULT NULL               COMMENT '飞行时间点',
  is_violation       CHAR(1)         DEFAULT '0'                COMMENT '是否违规（0正常1违规）',
  create_by          VARCHAR(64)     DEFAULT ''                 COMMENT '创建者',
  create_time        DATETIME                                   COMMENT '创建时间',
  PRIMARY KEY (id),
  KEY idx_permission_id (permission_id),
  KEY idx_create_time (create_time),
  KEY idx_flight_time (flight_time),
  KEY idx_warning_flag (warning_flag),
  CONSTRAINT fk_monitor_permission FOREIGN KEY (permission_id) REFERENCES flight_permission (id) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='飞行监控表';

CREATE TABLE violation_record (
  id             BIGINT          NOT NULL AUTO_INCREMENT    COMMENT '主键ID',
  permission_id  BIGINT          NOT NULL                   COMMENT '关联权限ID',
  violation_type VARCHAR(50)     NOT NULL                   COMMENT '违规类型',
  description    VARCHAR(1000)  DEFAULT ''                 COMMENT '违规描述',
  longitude      DOUBLE          DEFAULT NULL               COMMENT '经度',
  latitude       DOUBLE          DEFAULT NULL               COMMENT '纬度',
  handle_status  CHAR(1)         DEFAULT '0'                COMMENT '处理状态（0待处理 1已处理）',
  create_by      VARCHAR(64)     DEFAULT ''                 COMMENT '创建者',
  create_time    DATETIME                                   COMMENT '创建时间',
  update_by      VARCHAR(64)     DEFAULT ''                 COMMENT '更新者',
  update_time    DATETIME                                   COMMENT '更新时间',
  remark         VARCHAR(500)   DEFAULT NULL                COMMENT '备注',
  PRIMARY KEY (id),
  KEY idx_permission_id (permission_id),
  KEY idx_handle_status (handle_status),
  KEY idx_create_time (create_time),
  CONSTRAINT fk_violation_permission FOREIGN KEY (permission_id) REFERENCES flight_permission (id) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='违规记录表';

-- =============================================================================
-- 二、字典
-- =============================================================================
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT * FROM (SELECT '无人机状态' AS dict_name, 'drone_status' AS dict_type, '0' AS status, 'admin' AS create_by, sysdate() AS create_time, '无人机状态' AS remark
UNION SELECT '申请状态', 'flight_application_status', '0', 'admin', sysdate(), '飞行申请状态'
UNION SELECT '权限状态', 'flight_permission_status', '0', 'admin', sysdate(), '飞行权限状态'
UNION SELECT '告警标志', 'flight_warning_flag', '0', 'admin', sysdate(), '飞行监控告警'
UNION SELECT '违规类型', 'violation_type', '0', 'admin', sysdate(), '违规类型'
UNION SELECT '违规处理状态', 'violation_handle_status', '0', 'admin', sysdate(), '违规处理状态') t
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type = t.dict_type);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, list_class, is_default, status, create_by, create_time, remark)
SELECT 1, '正常', '0', 'drone_status', 'primary', 'Y', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'drone_status' AND dict_value = '0')
UNION ALL SELECT 2, '停用', '1', 'drone_status', 'danger', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'drone_status' AND dict_value = '1')
UNION ALL SELECT 1, '待审批', '0', 'flight_application_status', 'warning', 'Y', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'flight_application_status' AND dict_value = '0')
UNION ALL SELECT 2, '已通过', '1', 'flight_application_status', 'success', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'flight_application_status' AND dict_value = '1')
UNION ALL SELECT 3, '已驳回', '2', 'flight_application_status', 'danger', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'flight_application_status' AND dict_value = '2')
UNION ALL SELECT 1, '有效', '0', 'flight_permission_status', 'primary', 'Y', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'flight_permission_status' AND dict_value = '0')
UNION ALL SELECT 2, '已过期', '1', 'flight_permission_status', 'info', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'flight_permission_status' AND dict_value = '1')
UNION ALL SELECT 3, '已撤销', '2', 'flight_permission_status', 'danger', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'flight_permission_status' AND dict_value = '2')
UNION ALL SELECT 1, '正常', '0', 'flight_warning_flag', 'primary', 'Y', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'flight_warning_flag' AND dict_value = '0')
UNION ALL SELECT 2, '告警', '1', 'flight_warning_flag', 'danger', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'flight_warning_flag' AND dict_value = '1')
UNION ALL SELECT 1, '越界飞行', 'out_of_bounds', 'violation_type', 'danger', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'violation_type' AND dict_value = 'out_of_bounds')
UNION ALL SELECT 2, '超高度', 'over_height', 'violation_type', 'warning', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'violation_type' AND dict_value = 'over_height')
UNION ALL SELECT 3, '超时飞行', 'over_time', 'violation_type', 'warning', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'violation_type' AND dict_value = 'over_time')
UNION ALL SELECT 4, '禁飞区', 'no_fly_zone', 'violation_type', 'danger', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'violation_type' AND dict_value = 'no_fly_zone')
UNION ALL SELECT 5, '其他', 'other', 'violation_type', 'info', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'violation_type' AND dict_value = 'other')
UNION ALL SELECT 1, '待处理', '0', 'violation_handle_status', 'warning', 'Y', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'violation_handle_status' AND dict_value = '0')
UNION ALL SELECT 2, '已处理', '1', 'violation_handle_status', 'success', 'N', '0', 'admin', sysdate(), '' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'violation_handle_status' AND dict_value = '1');

-- =============================================================================
-- 三、角色（审批人员、飞行申请用户、无人机用户）
-- =============================================================================
INSERT INTO sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
SELECT '审批人员', 'approver', 3, '2', 1, 1, '0', '0', 'admin', sysdate(), '飞行申请审批权限' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key = 'approver');
INSERT INTO sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
SELECT '飞行申请用户', 'flight_user', 4, '5', 1, 1, '0', '0', 'admin', sysdate(), '仅能操作自己的申请与无人机' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key = 'flight_user');
INSERT INTO sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
SELECT '无人机用户', 'drone_user', 5, '5', 1, 1, '0', '0', 'admin', sysdate(), '完整业务：首页、无人机管理、飞行申请、权限查看、监控管理' FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key = 'drone_user');

-- =============================================================================
-- 四、菜单（先建父级「无人机飞行管理」，再扁平化并清理）
-- =============================================================================
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('无人机飞行管理', 0, 5, 'drone', NULL, '', '', 1, 0, 'M', '0', '0', '', 'guide', 'admin', sysdate(), '无人机飞行权限与审批');
SET @parent_id = LAST_INSERT_ID();

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('无人机管理', @parent_id, 1, 'droneInfo', 'drone/droneInfo/index', '', '', 1, 0, 'C', '0', '0', 'drone:droneInfo:list', 'peoples', 'admin', sysdate(), '');
SET @drone_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('无人机查询', @drone_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:droneInfo:query', '#', 'admin', sysdate(), ''),
('无人机新增', @drone_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:droneInfo:add', '#', 'admin', sysdate(), ''),
('无人机修改', @drone_menu, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:droneInfo:edit', '#', 'admin', sysdate(), ''),
('无人机删除', @drone_menu, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:droneInfo:remove', '#', 'admin', sysdate(), ''),
('无人机导出', @drone_menu, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:droneInfo:export', '#', 'admin', sysdate(), '');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('飞行申请', @parent_id, 2, 'application', 'drone/application/index', '', '', 1, 0, 'C', '0', '0', 'drone:application:list', 'form', 'admin', sysdate(), '');
SET @app_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('申请查询', @app_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:application:query', '#', 'admin', sysdate(), ''),
('申请新增', @app_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:application:add', '#', 'admin', sysdate(), ''),
('申请修改', @app_menu, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:application:edit', '#', 'admin', sysdate(), ''),
('申请删除', @app_menu, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:application:remove', '#', 'admin', sysdate(), ''),
('申请导出', @app_menu, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:application:export', '#', 'admin', sysdate(), '');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('审批管理', @parent_id, 3, 'approve', 'drone/approve/index', '', '', 1, 0, 'C', '0', '0', 'drone:approve:list', 'edit', 'admin', sysdate(), '');
SET @approve_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('审批查询', @approve_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:approve:query', '#', 'admin', sysdate(), ''),
('审批通过', @approve_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:approve:approve', '#', 'admin', sysdate(), ''),
('审批驳回', @approve_menu, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:approve:reject', '#', 'admin', sysdate(), ''),
('审批导出', @approve_menu, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:approve:export', '#', 'admin', sysdate(), '');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('权限查看', @parent_id, 4, 'permission', 'drone/permission/index', '', '', 1, 0, 'C', '0', '0', 'drone:permission:list', 'validCode', 'admin', sysdate(), '');
SET @perm_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('权限查询', @perm_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:permission:query', '#', 'admin', sysdate(), ''),
('权限导出', @perm_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:permission:export', '#', 'admin', sysdate(), '');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('监控管理', @parent_id, 5, 'monitor', 'drone/monitor/index', '', '', 1, 0, 'C', '0', '0', 'drone:monitor:list', 'monitor', 'admin', sysdate(), '');
SET @monitor_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('监控查询', @monitor_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:monitor:query', '#', 'admin', sysdate(), ''),
('监控新增', @monitor_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:monitor:add', '#', 'admin', sysdate(), ''),
('监控导出', @monitor_menu, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:monitor:export', '#', 'admin', sysdate(), '');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('违规管理', @parent_id, 6, 'violation', 'drone/violation/index', '', '', 1, 0, 'C', '0', '0', 'drone:violation:list', 'bug', 'admin', sysdate(), '');
SET @violation_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('违规查询', @violation_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:violation:query', '#', 'admin', sysdate(), ''),
('违规处理', @violation_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:violation:edit', '#', 'admin', sysdate(), ''),
('违规导出', @violation_menu, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:violation:export', '#', 'admin', sysdate(), '');

-- 删除若依官网、统计报表；删除「无人机飞行管理」父级并扁平化业务菜单
DELETE FROM sys_role_menu WHERE menu_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path = 'http://ruoyi.vip' OR (menu_name = '若依官网' AND parent_id = 0)) t);
DELETE FROM sys_menu WHERE path = 'http://ruoyi.vip' OR (menu_name = '若依官网' AND parent_id = 0);
SET @stats_id = (SELECT menu_id FROM sys_menu WHERE path = 'statistics' AND menu_type = 'C' LIMIT 1);
DELETE FROM sys_role_menu WHERE menu_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path = 'statistics' OR (parent_id = @stats_id AND @stats_id IS NOT NULL)) t);
DELETE FROM sys_menu WHERE path = 'statistics' OR (parent_id = @stats_id AND @stats_id IS NOT NULL);
SET @drone_parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'drone' AND parent_id = 0 LIMIT 1);
DELETE FROM sys_role_menu WHERE menu_id = @drone_parent_id;
UPDATE sys_menu SET parent_id = 0, order_num = CASE path WHEN 'droneInfo' THEN 1 WHEN 'application' THEN 2 WHEN 'approve' THEN 3 WHEN 'permission' THEN 4 WHEN 'monitor' THEN 5 WHEN 'violation' THEN 6 ELSE order_num END WHERE parent_id = @drone_parent_id;
DELETE FROM sys_menu WHERE menu_id = @drone_parent_id;

-- =============================================================================
-- 五、首页菜单及管理员分配
-- =============================================================================
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '首页', 0, 0, 'index', 'index', '', 'Index', 1, 0, 'C', '0', '0', 'index:view', 'dashboard', 'admin', NOW(), '首页-统计报表'
FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE path = 'index' AND parent_id = 0 LIMIT 1);
UPDATE sys_menu SET parent_id = 0, menu_type = 'C', status = '0', visible = '0' WHERE path = 'index';
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT 1, menu_id FROM sys_menu WHERE path = 'index' AND parent_id = 0 LIMIT 1;

-- =============================================================================
-- 六、drone_user 角色菜单（按 path 查找，兼容扁平化前后）
-- =============================================================================
SET @rid = (SELECT role_id FROM sys_role WHERE role_key = 'drone_user' LIMIT 1);
SET @mid_index     = (SELECT menu_id FROM sys_menu WHERE path = 'index' LIMIT 1);
SET @mid_droneInfo = (SELECT menu_id FROM sys_menu WHERE path = 'droneInfo' AND menu_type IN ('C','M') LIMIT 1);
SET @mid_application = (SELECT menu_id FROM sys_menu WHERE path = 'application' AND menu_type IN ('C','M') LIMIT 1);
SET @mid_permission = (SELECT menu_id FROM sys_menu WHERE path = 'permission' AND menu_type IN ('C','M') LIMIT 1);
SET @mid_monitor   = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND menu_type IN ('C','M') LIMIT 1);

INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT @rid, @mid_index FROM (SELECT 1) t WHERE @rid IS NOT NULL AND @mid_index IS NOT NULL;
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT @rid, @mid_droneInfo FROM (SELECT 1) t WHERE @rid IS NOT NULL AND @mid_droneInfo IS NOT NULL;
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT @rid, m.menu_id FROM sys_menu m WHERE m.parent_id = @mid_droneInfo AND @rid IS NOT NULL;
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT @rid, @mid_application FROM (SELECT 1) t WHERE @rid IS NOT NULL AND @mid_application IS NOT NULL;
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT @rid, m.menu_id FROM sys_menu m WHERE m.parent_id = @mid_application AND @rid IS NOT NULL;
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT @rid, @mid_permission FROM (SELECT 1) t WHERE @rid IS NOT NULL AND @mid_permission IS NOT NULL;
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT @rid, m.menu_id FROM sys_menu m WHERE m.parent_id = @mid_permission AND @rid IS NOT NULL;
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT @rid, @mid_monitor FROM (SELECT 1) t WHERE @rid IS NOT NULL AND @mid_monitor IS NOT NULL;
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT @rid, m.menu_id FROM sys_menu m WHERE m.parent_id = @mid_monitor AND @rid IS NOT NULL;

-- =============================================================================
-- 七、监控表结构增强（若表已存在且含这些列则跳过；重复执行报“Duplicate column”时注释本段）
-- =============================================================================
-- ALTER TABLE flight_monitor ADD COLUMN longitude DOUBLE DEFAULT NULL COMMENT '经度' AFTER real_time_location;
-- ALTER TABLE flight_monitor ADD COLUMN latitude DOUBLE DEFAULT NULL COMMENT '纬度' AFTER longitude;
-- ALTER TABLE flight_monitor ADD COLUMN speed DECIMAL(10,2) DEFAULT NULL COMMENT '速度(m/s)' AFTER current_height;
-- ALTER TABLE flight_monitor ADD COLUMN flight_time DATETIME DEFAULT NULL COMMENT '飞行时间点' AFTER warning_flag;
-- ALTER TABLE flight_monitor ADD COLUMN is_violation CHAR(1) DEFAULT '0' COMMENT '是否违规' AFTER flight_time;
-- ALTER TABLE flight_monitor ADD INDEX idx_flight_time (flight_time);
-- ALTER TABLE violation_record ADD COLUMN longitude DOUBLE DEFAULT NULL COMMENT '经度' AFTER description;
-- ALTER TABLE violation_record ADD COLUMN latitude DOUBLE DEFAULT NULL COMMENT '纬度' AFTER longitude;

-- =============================================================================
-- 八、模拟测试数据（存在则跳过）
-- =============================================================================
SET @admin_id = (SELECT user_id FROM sys_user WHERE user_name = 'admin' LIMIT 1);

INSERT INTO drone_info (drone_name, drone_model, serial_number, owner_id, status, remark, create_by, create_time)
SELECT 'M1-正常', 'Matrice 300', 'SN-FIN-T01', @admin_id, '0', '任务1', 'admin', NOW() FROM (SELECT 1) t WHERE @admin_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM drone_info WHERE serial_number = 'SN-FIN-T01');
SET @d1 = (SELECT id FROM drone_info WHERE serial_number = 'SN-FIN-T01' LIMIT 1);
INSERT INTO flight_application (application_no, applicant_id, drone_id, flight_area, flight_height, start_time, end_time, purpose, status, approve_user, approve_time, create_by, create_time)
SELECT 'FA-FIN-001', @admin_id, @d1, '武汉东湖A区', 120, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '正常飞行', '1', @admin_id, NOW(), 'admin', NOW() FROM (SELECT 1) t WHERE @d1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_application WHERE application_no = 'FA-FIN-001');
SET @a1 = (SELECT id FROM flight_application WHERE application_no = 'FA-FIN-001' LIMIT 1);
INSERT INTO flight_permission (application_id, approved_area, approved_height, approved_start_time, approved_end_time, permission_status, create_by, create_time)
SELECT @a1, '东湖A区', 120, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '0', 'admin', NOW() FROM (SELECT 1) t WHERE @a1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_permission WHERE application_id = @a1);
SET @p1 = (SELECT id FROM flight_permission WHERE application_id = @a1 LIMIT 1);
INSERT INTO flight_monitor (permission_id, longitude, latitude, current_height, speed, flight_time, is_violation, create_by, create_time)
SELECT @p1, 114.40 + n*0.01, 30.51, 80 + n*2, 5.0, DATE_ADD(NOW(), INTERVAL n*3 MINUTE), '0', 'system', NOW()
FROM (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19) nums
WHERE @p1 IS NOT NULL AND (SELECT COUNT(1) FROM flight_monitor WHERE permission_id = @p1) < 20;

INSERT INTO drone_info (drone_name, drone_model, serial_number, owner_id, status, remark, create_by, create_time)
SELECT 'M2-超高', 'Phantom 4', 'SN-FIN-T02', @admin_id, '0', '任务2', 'admin', NOW() FROM (SELECT 1) t WHERE @admin_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM drone_info WHERE serial_number = 'SN-FIN-T02');
SET @d2 = (SELECT id FROM drone_info WHERE serial_number = 'SN-FIN-T02' LIMIT 1);
INSERT INTO flight_application (application_no, applicant_id, drone_id, flight_area, flight_height, start_time, end_time, purpose, status, approve_user, approve_time, create_by, create_time)
SELECT 'FA-FIN-002', @admin_id, @d2, '武汉东湖B区', 100, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '超高测试', '1', @admin_id, NOW(), 'admin', NOW() FROM (SELECT 1) t WHERE @d2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_application WHERE application_no = 'FA-FIN-002');
SET @a2 = (SELECT id FROM flight_application WHERE application_no = 'FA-FIN-002' LIMIT 1);
INSERT INTO flight_permission (application_id, approved_area, approved_height, approved_start_time, approved_end_time, permission_status, create_by, create_time)
SELECT @a2, '东湖B区', 100, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '0', 'admin', NOW() FROM (SELECT 1) t WHERE @a2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_permission WHERE application_id = @a2);
SET @p2 = (SELECT id FROM flight_permission WHERE application_id = @a2 LIMIT 1);
INSERT INTO flight_monitor (permission_id, longitude, latitude, current_height, speed, flight_time, is_violation, create_by, create_time)
SELECT @p2, 114.35 + n*0.01, 30.52, LEAST(85 + n*4, 125), 6.0, DATE_ADD(NOW(), INTERVAL n*3 MINUTE), IF(85 + n*4 > 100, '1', '0'), 'system', NOW()
FROM (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19) nums
WHERE @p2 IS NOT NULL AND (SELECT COUNT(1) FROM flight_monitor WHERE permission_id = @p2) < 20;
INSERT INTO violation_record (permission_id, violation_type, description, longitude, latitude, handle_status, create_by, create_time)
SELECT @p2, 'over_height', '飞行高度超过批准值100m', 114.362, 30.52, '0', 'system', NOW() FROM (SELECT 1) t WHERE @p2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM violation_record WHERE permission_id = @p2 AND violation_type = 'over_height');

INSERT INTO drone_info (drone_name, drone_model, serial_number, owner_id, status, remark, create_by, create_time)
SELECT 'M3-越界', 'Mavic 3', 'SN-FIN-T03', @admin_id, '0', '任务3', 'admin', NOW() FROM (SELECT 1) t WHERE @admin_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM drone_info WHERE serial_number = 'SN-FIN-T03');
SET @d3 = (SELECT id FROM drone_info WHERE serial_number = 'SN-FIN-T03' LIMIT 1);
INSERT INTO flight_application (application_no, applicant_id, drone_id, flight_area, flight_height, start_time, end_time, purpose, status, approve_user, approve_time, create_by, create_time)
SELECT 'FA-FIN-003', @admin_id, @d3, '武汉东湖C区', 80, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '越界测试', '1', @admin_id, NOW(), 'admin', NOW() FROM (SELECT 1) t WHERE @d3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_application WHERE application_no = 'FA-FIN-003');
SET @a3 = (SELECT id FROM flight_application WHERE application_no = 'FA-FIN-003' LIMIT 1);
INSERT INTO flight_permission (application_id, approved_area, approved_height, approved_start_time, approved_end_time, permission_status, create_by, create_time)
SELECT @a3, '东湖C区', 80, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), '0', 'admin', NOW() FROM (SELECT 1) t WHERE @a3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM flight_permission WHERE application_id = @a3);
SET @p3 = (SELECT id FROM flight_permission WHERE application_id = @a3 LIMIT 1);
INSERT INTO flight_monitor (permission_id, longitude, latitude, current_height, speed, flight_time, is_violation, create_by, create_time)
SELECT @p3, 114.45 + n*0.015 + IF(n>=12, 0.05, 0), 30.50, 75 + (n MOD 5), 5.5, DATE_ADD(NOW(), INTERVAL n*3 MINUTE), IF(n >= 12 AND n <= 14, '1', '0'), 'system', NOW()
FROM (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19) nums
WHERE @p3 IS NOT NULL AND (SELECT COUNT(1) FROM flight_monitor WHERE permission_id = @p3) < 20;
INSERT INTO violation_record (permission_id, violation_type, description, longitude, latitude, handle_status, create_by, create_time)
SELECT @p3, 'out_of_bounds', '偏离批准空域', 114.468, 30.50, '0', 'system', NOW() FROM (SELECT 1) t WHERE @p3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM violation_record WHERE permission_id = @p3 AND violation_type = 'out_of_bounds');

-- =============================================================================
-- 九、测试用户 user1（密码同 admin 默认；需 123456 请在用户管理中重置）
-- =============================================================================
INSERT INTO sys_user (dept_id, user_name, nick_name, user_type, email, phonenumber, sex, avatar, password, status, del_flag, create_by, create_time, remark)
SELECT 103, 'user1', '无人机测试用户', '00', 'user1@test.com', '13800000001', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), '普通用户'
FROM (SELECT 1) t WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name = 'user1');
SET @uid = (SELECT user_id FROM sys_user WHERE user_name = 'user1' LIMIT 1);
INSERT IGNORE INTO sys_user_role (user_id, role_id) SELECT @uid, @rid FROM (SELECT 1) t WHERE @uid IS NOT NULL AND @rid IS NOT NULL;

-- =============================================================================
-- 结束。执行顺序建议：1) 若依基础 SQL  2) 本脚本 drone_install.sql
-- =============================================================================
