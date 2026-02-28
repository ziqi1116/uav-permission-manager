package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.domain.FlightPermission;
import com.ruoyi.system.mapper.FlightPermissionMapper;
import com.ruoyi.system.service.IFlightPermissionService;

@Service
public class FlightPermissionServiceImpl implements IFlightPermissionService {

    @Autowired
    private FlightPermissionMapper flightPermissionMapper;

    @Override
    public FlightPermission selectFlightPermissionById(Long id) {
        return flightPermissionMapper.selectFlightPermissionById(id);
    }

    @Override
    public List<FlightPermission> selectFlightPermissionList(FlightPermission flightPermission) {
        return flightPermissionMapper.selectFlightPermissionList(flightPermission);
    }

    @Override
    public int insertFlightPermission(FlightPermission flightPermission) {
        return flightPermissionMapper.insertFlightPermission(flightPermission);
    }

    @Override
    public int updateFlightPermission(FlightPermission flightPermission) {
        return flightPermissionMapper.updateFlightPermission(flightPermission);
    }

    @Override
    public int deleteFlightPermissionByIds(Long[] ids) {
        return flightPermissionMapper.deleteFlightPermissionByIds(ids);
    }
}
