package com.ruoyi.web.controller.drone;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.service.IFlightStatisticsService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 飞行统计（ECharts）
 */
@RestController
@RequestMapping("/drone/statistics")
public class FlightStatisticsController extends BaseController {

    @Autowired
    private IFlightStatisticsService flightStatisticsService;

    @PreAuthorize("@ss.hasPermi('drone:statistics:list')")
    @GetMapping("/applicationCount")
    public AjaxResult applicationCount(
            @RequestParam(required = false) String beginTime,
            @RequestParam(required = false) String endTime) {
        Long applicantId = SecurityUtils.isAdmin(getUserId()) ? null : getUserId();
        List<Map<String, Object>> list = flightStatisticsService.selectApplicationCountByDate(beginTime, endTime, applicantId);
        return success(list);
    }

    @PreAuthorize("@ss.hasPermi('drone:statistics:list')")
    @GetMapping("/areaUsage")
    public AjaxResult areaUsage() {
        Long applicantId = SecurityUtils.isAdmin(getUserId()) ? null : getUserId();
        List<Map<String, Object>> list = flightStatisticsService.selectAreaUsage(applicantId);
        return success(list);
    }

    @PreAuthorize("@ss.hasPermi('drone:statistics:list')")
    @GetMapping("/violationCount")
    public AjaxResult violationCount(
            @RequestParam(required = false) String beginTime,
            @RequestParam(required = false) String endTime) {
        Long applicantId = SecurityUtils.isAdmin(getUserId()) ? null : getUserId();
        List<Map<String, Object>> list = flightStatisticsService.selectViolationCountByDate(beginTime, endTime, applicantId);
        return success(list);
    }

    @PreAuthorize("@ss.hasPermi('drone:statistics:query')")
    @GetMapping("/all")
    public AjaxResult all(
            @RequestParam(required = false) String beginTime,
            @RequestParam(required = false) String endTime) {
        Long applicantId = SecurityUtils.isAdmin(getUserId()) ? null : getUserId();
        Map<String, Object> data = new HashMap<>();
        data.put("applicationCount", flightStatisticsService.selectApplicationCountByDate(beginTime, endTime, applicantId));
        data.put("areaUsage", flightStatisticsService.selectAreaUsage(applicantId));
        data.put("violationCount", flightStatisticsService.selectViolationCountByDate(beginTime, endTime, applicantId));
        return success(data);
    }

    /** 首页大屏：4 个统计卡片 + 图表数据。admin 统计全部，普通用户仅统计本人(applicant_id=当前用户)。支持 index:view / drone:statistics:view / drone:statistics:query 任一即可 */
    @PreAuthorize("@ss.hasPermi('drone:statistics:query') or @ss.hasPermi('index:view') or @ss.hasPermi('drone:statistics:view')")
    @GetMapping("/dashboard")
    public AjaxResult dashboard(
            @RequestParam(required = false) String beginTime,
            @RequestParam(required = false) String endTime) {
        Long applicantId = SecurityUtils.isAdmin(getUserId()) ? null : getUserId();
        Map<String, Object> data = new HashMap<>();
        data.put("dashboardStats", flightStatisticsService.selectDashboardStats(applicantId));
        data.put("applicationCount", flightStatisticsService.selectApplicationCountByDate(beginTime, endTime, applicantId));
        data.put("areaUsage", flightStatisticsService.selectAreaUsage(applicantId));
        data.put("violationCount", flightStatisticsService.selectViolationCountByDate(beginTime, endTime, applicantId));
        return success(data);
    }
}
