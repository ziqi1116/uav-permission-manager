package com.ruoyi.system.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.FlightStatisticsMapper;
import com.ruoyi.system.service.IFlightStatisticsService;

@Service
public class FlightStatisticsServiceImpl implements IFlightStatisticsService {

    @Autowired
    private FlightStatisticsMapper flightStatisticsMapper;

    @Override
    public List<Map<String, Object>> selectApplicationCountByDate(String beginTime, String endTime, Long applicantId) {
        return flightStatisticsMapper.selectApplicationCountByDate(beginTime, endTime, applicantId);
    }

    @Override
    public List<Map<String, Object>> selectAreaUsage(Long applicantId) {
        return flightStatisticsMapper.selectAreaUsage(applicantId);
    }

    @Override
    public List<Map<String, Object>> selectViolationCountByDate(String beginTime, String endTime, Long applicantId) {
        return flightStatisticsMapper.selectViolationCountByDate(beginTime, endTime, applicantId);
    }

    @Override
    public Map<String, Long> selectDashboardStats(Long applicantId) {
        Map<String, Long> map = new HashMap<>();
        map.put("todayApplicationCount", flightStatisticsMapper.selectTodayApplicationCount(applicantId));
        map.put("todayApprovedCount", flightStatisticsMapper.selectTodayApprovedCount(applicantId));
        map.put("currentFlightCount", flightStatisticsMapper.selectCurrentFlightCount(applicantId));
        map.put("totalViolationCount", flightStatisticsMapper.selectTotalViolationCount(applicantId));
        return map;
    }
}
