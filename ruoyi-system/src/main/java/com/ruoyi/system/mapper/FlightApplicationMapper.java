package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.FlightApplication;

/**
 * 飞行申请 数据层
 */
public interface FlightApplicationMapper {

    FlightApplication selectFlightApplicationById(Long id);

    List<FlightApplication> selectFlightApplicationList(FlightApplication flightApplication);

    FlightApplication selectByApplicationNo(String applicationNo);

    int insertFlightApplication(FlightApplication flightApplication);

    int updateFlightApplication(FlightApplication flightApplication);

    int deleteFlightApplicationById(Long id);

    int deleteFlightApplicationByIds(Long[] ids);
}
