-- ----------------------------
-- 无人机飞行权限管理与审批系统 - 业务表结构 (MySQL 8.0, InnoDB, utf8mb4)
-- ----------------------------
SET NAMES utf8mb4;

-- ----------------------------
-- 1、无人机信息表
-- ----------------------------
DROP TABLE IF EXISTS drone_info;
CREATE TABLE drone_info (
  id              BIGINT          NOT NULL AUTO_INCREMENT    COMMENT '主键ID',
  drone_name      VARCHAR(100)    NOT NULL                   COMMENT '无人机名称',
  drone_model     VARCHAR(100)    DEFAULT ''                 COMMENT '机型型号',
  serial_number   VARCHAR(100)    NOT NULL                   COMMENT '序列号（唯一）',
  owner_id        BIGINT          DEFAULT NULL               COMMENT '所属用户ID（外键 sys_user.user_id）',
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

-- ----------------------------
-- 2、飞行申请表
-- ----------------------------
DROP TABLE IF EXISTS flight_application;
CREATE TABLE flight_application (
  id               BIGINT          NOT NULL AUTO_INCREMENT    COMMENT '主键ID',
  application_no   VARCHAR(64)     NOT NULL                   COMMENT '申请单号（自动生成）',
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

-- ----------------------------
-- 3、飞行权限表
-- ----------------------------
DROP TABLE IF EXISTS flight_permission;
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

-- ----------------------------
-- 4、飞行监控表
-- ----------------------------
DROP TABLE IF EXISTS flight_monitor;
CREATE TABLE flight_monitor (
  id                 BIGINT          NOT NULL AUTO_INCREMENT    COMMENT '主键ID',
  permission_id       BIGINT          NOT NULL                   COMMENT '关联权限ID',
  real_time_location VARCHAR(200)   DEFAULT ''                 COMMENT '实时位置',
  current_height     INT             DEFAULT 0                  COMMENT '当前高度(m)',
  warning_flag       CHAR(1)         DEFAULT '0'                COMMENT '告警标志（0正常 1告警）',
  create_by          VARCHAR(64)     DEFAULT ''                 COMMENT '创建者',
  create_time        DATETIME                                   COMMENT '创建时间',
  PRIMARY KEY (id),
  KEY idx_permission_id (permission_id),
  KEY idx_create_time (create_time),
  KEY idx_warning_flag (warning_flag),
  CONSTRAINT fk_monitor_permission FOREIGN KEY (permission_id) REFERENCES flight_permission (id) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='飞行监控表';

-- ----------------------------
-- 5、违规记录表
-- ----------------------------
DROP TABLE IF EXISTS violation_record;
CREATE TABLE violation_record (
  id             BIGINT          NOT NULL AUTO_INCREMENT    COMMENT '主键ID',
  permission_id  BIGINT          NOT NULL                   COMMENT '关联权限ID',
  violation_type VARCHAR(50)     NOT NULL                   COMMENT '违规类型',
  description    VARCHAR(1000)  DEFAULT ''                 COMMENT '违规描述',
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

-- ----------------------------
-- 字典类型（无人机/飞行相关）
-- ----------------------------
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark) VALUES
('无人机状态', 'drone_status', '0', 'admin', sysdate(), '无人机状态'),
('申请状态', 'flight_application_status', '0', 'admin', sysdate(), '飞行申请状态'),
('权限状态', 'flight_permission_status', '0', 'admin', sysdate(), '飞行权限状态'),
('告警标志', 'flight_warning_flag', '0', 'admin', sysdate(), '飞行监控告警'),
('违规类型', 'violation_type', '0', 'admin', sysdate(), '违规类型'),
('违规处理状态', 'violation_handle_status', '0', 'admin', sysdate(), '违规处理状态');

-- ----------------------------
-- 字典数据
-- ----------------------------
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, list_class, is_default, status, create_by, create_time, remark) VALUES
(1, '正常', '0', 'drone_status', 'primary', 'Y', '0', 'admin', sysdate(), ''),
(2, '停用', '1', 'drone_status', 'danger', 'N', '0', 'admin', sysdate(), ''),
(1, '待审批', '0', 'flight_application_status', 'warning', 'Y', '0', 'admin', sysdate(), ''),
(2, '已通过', '1', 'flight_application_status', 'success', 'N', '0', 'admin', sysdate(), ''),
(3, '已驳回', '2', 'flight_application_status', 'danger', 'N', '0', 'admin', sysdate(), ''),
(1, '有效', '0', 'flight_permission_status', 'primary', 'Y', '0', 'admin', sysdate(), ''),
(2, '已过期', '1', 'flight_permission_status', 'info', 'N', '0', 'admin', sysdate(), ''),
(3, '已撤销', '2', 'flight_permission_status', 'danger', 'N', '0', 'admin', sysdate(), ''),
(1, '正常', '0', 'flight_warning_flag', 'primary', 'Y', '0', 'admin', sysdate(), ''),
(2, '告警', '1', 'flight_warning_flag', 'danger', 'N', '0', 'admin', sysdate(), ''),
(1, '越界飞行', 'out_of_bounds', 'violation_type', 'danger', 'N', '0', 'admin', sysdate(), ''),
(2, '超高度', 'over_height', 'violation_type', 'warning', 'N', '0', 'admin', sysdate(), ''),
(3, '超时飞行', 'over_time', 'violation_type', 'warning', 'N', '0', 'admin', sysdate(), ''),
(4, '禁飞区', 'no_fly_zone', 'violation_type', 'danger', 'N', '0', 'admin', sysdate(), ''),
(5, '其他', 'other', 'violation_type', 'info', 'N', '0', 'admin', sysdate(), ''),
(1, '待处理', '0', 'violation_handle_status', 'warning', 'Y', '0', 'admin', sysdate(), ''),
(2, '已处理', '1', 'violation_handle_status', 'success', 'N', '0', 'admin', sysdate(), '');

-- ----------------------------
-- 角色（审批人员、飞行申请用户）- 若已有则仅插入新角色
-- ----------------------------
INSERT INTO sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark) VALUES
('审批人员', 'approver', 3, '2', 1, 1, '0', '0', 'admin', sysdate(), '飞行申请审批权限'),
('飞行申请用户', 'flight_user', 4, '5', 1, 1, '0', '0', 'admin', sysdate(), '仅能操作自己的申请与无人机');

-- 获取刚插入的角色ID（假设 3=审批人员, 4=飞行申请用户，根据实际自增可能不同，下面菜单用 2000+ 的父菜单ID）
-- 若需绑定菜单给角色，在菜单插入后执行 sys_role_menu 的插入。

-- ----------------------------
-- 菜单（无人机飞行权限管理 - 一级目录）
-- ----------------------------
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('无人机飞行管理', 0, 5, 'drone', NULL, '', '', 1, 0, 'M', '0', '0', '', 'guide', 'admin', sysdate(), '无人机飞行权限与审批');
SET @parent_id = LAST_INSERT_ID();

-- 无人机管理
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('无人机管理', @parent_id, 1, 'droneInfo', 'drone/droneInfo/index', '', '', 1, 0, 'C', '0', '0', 'drone:droneInfo:list', 'peoples', 'admin', sysdate(), '');
SET @drone_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('无人机查询', @drone_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:droneInfo:query', '#', 'admin', sysdate(), ''),
('无人机新增', @drone_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:droneInfo:add', '#', 'admin', sysdate(), ''),
('无人机修改', @drone_menu, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:droneInfo:edit', '#', 'admin', sysdate(), ''),
('无人机删除', @drone_menu, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:droneInfo:remove', '#', 'admin', sysdate(), ''),
('无人机导出', @drone_menu, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:droneInfo:export', '#', 'admin', sysdate(), '');

-- 飞行申请
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('飞行申请', @parent_id, 2, 'application', 'drone/application/index', '', '', 1, 0, 'C', '0', '0', 'drone:application:list', 'form', 'admin', sysdate(), '');
SET @app_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('申请查询', @app_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:application:query', '#', 'admin', sysdate(), ''),
('申请新增', @app_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:application:add', '#', 'admin', sysdate(), ''),
('申请修改', @app_menu, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:application:edit', '#', 'admin', sysdate(), ''),
('申请删除', @app_menu, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:application:remove', '#', 'admin', sysdate(), ''),
('申请导出', @app_menu, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:application:export', '#', 'admin', sysdate(), '');

-- 审批管理
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('审批管理', @parent_id, 3, 'approve', 'drone/approve/index', '', '', 1, 0, 'C', '0', '0', 'drone:approve:list', 'edit', 'admin', sysdate(), '');
SET @approve_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('审批查询', @approve_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:approve:query', '#', 'admin', sysdate(), ''),
('审批通过', @approve_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:approve:approve', '#', 'admin', sysdate(), ''),
('审批驳回', @approve_menu, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:approve:reject', '#', 'admin', sysdate(), ''),
('审批导出', @approve_menu, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:approve:export', '#', 'admin', sysdate(), '');

-- 权限查看
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('权限查看', @parent_id, 4, 'permission', 'drone/permission/index', '', '', 1, 0, 'C', '0', '0', 'drone:permission:list', 'validCode', 'admin', sysdate(), '');
SET @perm_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('权限查询', @perm_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:permission:query', '#', 'admin', sysdate(), ''),
('权限导出', @perm_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:permission:export', '#', 'admin', sysdate(), '');

-- 监控管理
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('监控管理', @parent_id, 5, 'monitor', 'drone/monitor/index', '', '', 1, 0, 'C', '0', '0', 'drone:monitor:list', 'monitor', 'admin', sysdate(), '');
SET @monitor_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('监控查询', @monitor_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:monitor:query', '#', 'admin', sysdate(), ''),
('监控新增', @monitor_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:monitor:add', '#', 'admin', sysdate(), ''),
('监控导出', @monitor_menu, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:monitor:export', '#', 'admin', sysdate(), '');

-- 违规管理
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('违规管理', @parent_id, 6, 'violation', 'drone/violation/index', '', '', 1, 0, 'C', '0', '0', 'drone:violation:list', 'bug', 'admin', sysdate(), '');
SET @violation_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('违规查询', @violation_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:violation:query', '#', 'admin', sysdate(), ''),
('违规处理', @violation_menu, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:violation:edit', '#', 'admin', sysdate(), ''),
('违规导出', @violation_menu, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:violation:export', '#', 'admin', sysdate(), '');

-- 统计报表
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('统计报表', @parent_id, 7, 'statistics', 'drone/statistics/index', '', '', 1, 0, 'C', '0', '0', 'drone:statistics:list', 'chart', 'admin', sysdate(), '');
SET @stats_menu = LAST_INSERT_ID();
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark) VALUES
('统计查询', @stats_menu, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'drone:statistics:query', '#', 'admin', sysdate(), '');

-- ----------------------------
-- 角色与菜单关联（请在系统管理-角色管理中为「审批人员」「飞行申请用户」分配上述菜单）
-- 或执行以下语句（将 2000 替换为实际「无人机飞行管理」目录的 menu_id）：
-- INSERT INTO sys_role_menu (role_id, menu_id) SELECT role_id, menu_id FROM sys_role, sys_menu WHERE role_key IN ('approver','flight_user') AND (sys_menu.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path='drone' AND parent_id=0) t) OR sys_menu.menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path='drone' AND parent_id=0) t));
