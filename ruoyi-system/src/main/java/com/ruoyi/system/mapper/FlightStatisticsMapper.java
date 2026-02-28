package com.ruoyi.system.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

/**
 * 飞行统计 数据层
 */
public interface FlightStatisticsMapper {

    List<Map<String, Object>> selectApplicationCountByDate(@Param("beginTime") String beginTime, @Param("endTime") String endTime, @Param("applicantId") Long applicantId);

    List<Map<String, Object>> selectAreaUsage(@Param("applicantId") Long applicantId);

    List<Map<String, Object>> selectViolationCountByDate(@Param("beginTime") String beginTime, @Param("endTime") String endTime, @Param("applicantId") Long applicantId);

    long selectTodayApplicationCount(@Param("applicantId") Long applicantId);

    long selectTodayApprovedCount(@Param("applicantId") Long applicantId);

    long selectCurrentFlightCount(@Param("applicantId") Long applicantId);

    long selectTotalViolationCount(@Param("applicantId") Long applicantId);
}
