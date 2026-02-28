package com.ruoyi.system.service;

import java.util.List;
import java.util.Map;

/**
 * 飞行统计 服务层（ECharts 数据）
 */
public interface IFlightStatisticsService {

    /**
     * 飞行申请数量统计（按日期，柱状图）。applicantId 非空时仅统计该申请人
     */
    List<Map<String, Object>> selectApplicationCountByDate(String beginTime, String endTime, Long applicantId);

    /**
     * 空域/区域使用情况（饼图）。applicantId 非空时仅统计该申请人
     */
    List<Map<String, Object>> selectAreaUsage(Long applicantId);

    /**
     * 违规次数统计（按日期，折线图）。applicantId 非空时仅统计该申请人权限下的违规
     */
    List<Map<String, Object>> selectViolationCountByDate(String beginTime, String endTime, Long applicantId);

    /**
     * 首页仪表盘：今日申请数、今日通过数、当前飞行任务数、累计违规数。applicantId 非空时仅统计该申请人
     */
    Map<String, Long> selectDashboardStats(Long applicantId);
}
