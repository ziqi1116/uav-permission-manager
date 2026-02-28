package com.ruoyi.system.service.impl;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.github.pagehelper.PageHelper;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.FlightMonitor;
import com.ruoyi.system.mapper.FlightMonitorMapper;
import com.ruoyi.system.mapper.FlightPermissionMapper;
import com.ruoyi.system.mapper.ViolationRecordMapper;
import com.ruoyi.system.service.IFlightMonitorService;

@Service
public class FlightMonitorServiceImpl implements IFlightMonitorService {

    @Autowired
    private FlightMonitorMapper flightMonitorMapper;
    @Autowired
    private ViolationRecordMapper violationRecordMapper;
    @Autowired
    private FlightPermissionMapper flightPermissionMapper;

    @Override
    public FlightMonitor selectFlightMonitorById(Long id) {
        return flightMonitorMapper.selectFlightMonitorById(id);
    }

    @Override
    public List<FlightMonitor> selectFlightMonitorList(FlightMonitor flightMonitor) {
        return flightMonitorMapper.selectFlightMonitorList(flightMonitor);
    }

    @Override
    public int insertFlightMonitor(FlightMonitor flightMonitor) {
        return flightMonitorMapper.insertFlightMonitor(flightMonitor);
    }

    @Override
    public int updateFlightMonitor(FlightMonitor flightMonitor) {
        return flightMonitorMapper.updateFlightMonitor(flightMonitor);
    }

    @Override
    public int deleteFlightMonitorByIds(Long[] ids) {
        return flightMonitorMapper.deleteFlightMonitorByIds(ids);
    }

    @Override
    public List<Map<String, Object>> selectCurrentTaskList() {
        return flightMonitorMapper.selectCurrentTaskList();
    }

    @Override
    public List<Map<String, Object>> selectMonitorPointsByPermissionId(Long permissionId) {
        return flightMonitorMapper.selectMonitorPointsByPermissionId(permissionId);
    }

    @Override
    public List<Map<String, Object>> selectTaskListPage(Long applicantId) {
        return flightMonitorMapper.selectTaskListPage(applicantId);
    }

    @Override
    public List<Map<String, Object>> selectTrackByPermissionId(Long permissionId, Integer pageNum, Integer pageSize) {
        checkPermissionOwnership(permissionId);
        if (pageNum != null && pageSize != null && pageSize > 0) {
            PageHelper.startPage(pageNum, Math.min(pageSize, 500));
        }
        return flightMonitorMapper.selectTrackByPermissionId(permissionId);
    }

    @Override
    public List<Map<String, Object>> selectViolationPointsByPermissionId(Long permissionId) {
        checkPermissionOwnership(permissionId);
        return violationRecordMapper.selectViolationPointsByPermissionId(permissionId);
    }

    /** 非管理员只能访问本人申请产生的权限（防越权） */
    private void checkPermissionOwnership(Long permissionId) {
        if (SecurityUtils.isAdmin()) {
            return;
        }
        Long applicantId = flightPermissionMapper.selectApplicantIdByPermissionId(permissionId);
        if (applicantId == null || !applicantId.equals(SecurityUtils.getUserId())) {
            throw new ServiceException("无权限查看该飞行任务数据");
        }
    }
}
