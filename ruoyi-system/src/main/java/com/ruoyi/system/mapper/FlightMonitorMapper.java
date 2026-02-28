package com.ruoyi.system.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.FlightMonitor;

/**
 * 飞行监控 数据层
 */
public interface FlightMonitorMapper {

    FlightMonitor selectFlightMonitorById(Long id);

    List<FlightMonitor> selectFlightMonitorList(FlightMonitor flightMonitor);

    int insertFlightMonitor(FlightMonitor flightMonitor);

    int updateFlightMonitor(FlightMonitor flightMonitor);

    int deleteFlightMonitorById(Long id);

    int deleteFlightMonitorByIds(Long[] ids);

    /** 当前飞行任务（有效权限+最新位置，用于地图） */
    List<Map<String, Object>> selectCurrentTaskList();

    /** 某权限的轨迹点（用于地图折线） */
    List<Map<String, Object>> selectMonitorPointsByPermissionId(@Param("permissionId") Long permissionId);

    /** 分页：飞行任务列表（applicantId 为空查全部，非空仅查该申请人） */
    List<Map<String, Object>> selectTaskListPage(@Param("applicantId") Long applicantId);

    /** 某权限轨迹（longitude, latitude, speed, flight_time, is_violation）按时间升序 */
    List<Map<String, Object>> selectTrackByPermissionId(@Param("permissionId") Long permissionId);
}
