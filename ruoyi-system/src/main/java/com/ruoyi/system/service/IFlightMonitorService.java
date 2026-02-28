package com.ruoyi.system.service;

import java.util.List;
import java.util.Map;
import com.ruoyi.system.domain.FlightMonitor;

/**
 * 飞行监控 服务层
 */
public interface IFlightMonitorService {

    FlightMonitor selectFlightMonitorById(Long id);

    List<FlightMonitor> selectFlightMonitorList(FlightMonitor flightMonitor);

    int insertFlightMonitor(FlightMonitor flightMonitor);

    int updateFlightMonitor(FlightMonitor flightMonitor);

    int deleteFlightMonitorByIds(Long[] ids);

    /** 当前飞行任务（有效权限+最新位置，用于地图大屏） */
    List<Map<String, Object>> selectCurrentTaskList();

    /** 某权限的轨迹点（用于地图折线） */
    List<Map<String, Object>> selectMonitorPointsByPermissionId(Long permissionId);

    /** 分页：飞行任务列表（applicantId 为 null 时查全部，非 null 时仅查该申请人） */
    List<Map<String, Object>> selectTaskListPage(Long applicantId);

    /** 某权限轨迹（按时间升序，支持分页） */
    List<Map<String, Object>> selectTrackByPermissionId(Long permissionId, Integer pageNum, Integer pageSize);

    /** 某权限的违规点列表（地图红色 marker） */
    List<Map<String, Object>> selectViolationPointsByPermissionId(Long permissionId);
}
