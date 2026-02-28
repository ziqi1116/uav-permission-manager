package com.ruoyi.web.controller.drone;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.system.domain.FlightMonitor;
import com.ruoyi.system.service.IFlightMonitorService;

/**
 * 飞行监控
 */
@RestController
@RequestMapping("/drone/monitor")
public class FlightMonitorController extends BaseController {

    @Autowired
    private IFlightMonitorService flightMonitorService;

    private void applyDataScope(FlightMonitor flightMonitor) {
        if (SecurityUtils.isAdmin(getUserId())) return;
        if (flightMonitor.getParams() == null) flightMonitor.setParams(new java.util.HashMap<>());
        flightMonitor.getParams().put("applicantId", getUserId());
    }

    @PreAuthorize("@ss.hasPermi('drone:monitor:list')")
    @GetMapping("/list")
    public TableDataInfo list(FlightMonitor flightMonitor) {
        applyDataScope(flightMonitor);
        startPage();
        List<FlightMonitor> list = flightMonitorService.selectFlightMonitorList(flightMonitor);
        return getDataTable(list);
    }

    @Log(title = "飞行监控", businessType = BusinessType.EXPORT)
    @PreAuthorize("@ss.hasPermi('drone:monitor:export')")
    @PostMapping("/export")
    public void export(HttpServletResponse response, FlightMonitor flightMonitor) {
        applyDataScope(flightMonitor);
        List<FlightMonitor> list = flightMonitorService.selectFlightMonitorList(flightMonitor);
        ExcelUtil<FlightMonitor> util = new ExcelUtil<>(FlightMonitor.class);
        util.exportExcel(response, list, "飞行监控数据");
    }

    @PreAuthorize("@ss.hasPermi('drone:monitor:query')")
    @GetMapping("/{id}")
    public AjaxResult getInfo(@PathVariable Long id) {
        return success(flightMonitorService.selectFlightMonitorById(id));
    }

    @PreAuthorize("@ss.hasPermi('drone:monitor:add')")
    @Log(title = "飞行监控", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody FlightMonitor flightMonitor) {
        flightMonitor.setCreateBy(getUsername());
        return toAjax(flightMonitorService.insertFlightMonitor(flightMonitor));
    }

    @PreAuthorize("@ss.hasPermi('drone:monitor:edit')")
    @Log(title = "飞行监控", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody FlightMonitor flightMonitor) {
        return toAjax(flightMonitorService.updateFlightMonitor(flightMonitor));
    }

    @PreAuthorize("@ss.hasPermi('drone:monitor:remove')")
    @Log(title = "飞行监控", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids) {
        return toAjax(flightMonitorService.deleteFlightMonitorByIds(ids));
    }

    /** 当前飞行任务列表（有效权限+最新位置，用于地图） */
    @PreAuthorize("@ss.hasPermi('drone:monitor:list')")
    @GetMapping("/currentTasks")
    public AjaxResult currentTasks() {
        List<Map<String, Object>> list = flightMonitorService.selectCurrentTaskList();
        return success(list);
    }

    /** 某权限的轨迹点（用于地图折线） */
    @PreAuthorize("@ss.hasPermi('drone:monitor:query')")
    @GetMapping("/trajectory/{permissionId}")
    public AjaxResult trajectory(@PathVariable Long permissionId) {
        List<Map<String, Object>> list = flightMonitorService.selectMonitorPointsByPermissionId(permissionId);
        return success(list);
    }

    /** 分页：飞行任务列表（多任务轨迹监控）；非管理员仅看本人申请的任务 */
    @PreAuthorize("@ss.hasPermi('drone:monitor:list')")
    @GetMapping("/task/list")
    public TableDataInfo taskList() {
        startPage();
        Long applicantId = SecurityUtils.isAdmin(getUserId()) ? null : getUserId();
        List<Map<String, Object>> list = flightMonitorService.selectTaskListPage(applicantId);
        return getDataTable(list);
    }

    /** 某权限轨迹（longitude, latitude, speed, flight_time, is_violation），按时间升序，支持分页 */
    @PreAuthorize("@ss.hasPermi('drone:monitor:query')")
    @GetMapping("/track/{permissionId}")
    public AjaxResult track(@PathVariable Long permissionId,
                            @RequestParam(required = false) Integer pageNum,
                            @RequestParam(required = false) Integer pageSize) {
        List<Map<String, Object>> list = flightMonitorService.selectTrackByPermissionId(permissionId, pageNum, pageSize);
        return success(list);
    }

    /** 某权限违规点（地图红色 marker） */
    @PreAuthorize("@ss.hasPermi('drone:monitor:query')")
    @GetMapping("/violation/{permissionId}")
    public AjaxResult violation(@PathVariable Long permissionId) {
        List<Map<String, Object>> list = flightMonitorService.selectViolationPointsByPermissionId(permissionId);
        return success(list);
    }
}
