package com.ruoyi.web.controller.drone;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.domain.entity.SysRole;
import com.ruoyi.system.domain.FlightPermission;
import com.ruoyi.system.service.IFlightPermissionService;

@RestController
@RequestMapping("/drone/permission")
public class FlightPermissionController extends BaseController {

    @Autowired
    private IFlightPermissionService flightPermissionService;

    private void applyDataScope(FlightPermission flightPermission) {
        if (SecurityUtils.isAdmin(getUserId())) return;
        List<SysRole> roles = SecurityUtils.getLoginUser().getUser().getRoles();
        if (roles == null) return;
        List<String> roleKeys = roles.stream().map(SysRole::getRoleKey).collect(java.util.stream.Collectors.toList());
        if (roleKeys.contains("drone_user") || (roleKeys.contains("flight_user") && !roleKeys.contains("approver"))) {
            flightPermission.setApplicantId(getUserId());
        }
    }

    @PreAuthorize("@ss.hasPermi('drone:permission:list')")
    @GetMapping("/list")
    public TableDataInfo list(FlightPermission flightPermission) {
        applyDataScope(flightPermission);
        startPage();
        List<FlightPermission> list = flightPermissionService.selectFlightPermissionList(flightPermission);
        return getDataTable(list);
    }

    @Log(title = "飞行权限", businessType = BusinessType.EXPORT)
    @PreAuthorize("@ss.hasPermi('drone:permission:export')")
    @PostMapping("/export")
    public void export(HttpServletResponse response, FlightPermission flightPermission) {
        applyDataScope(flightPermission);
        List<FlightPermission> list = flightPermissionService.selectFlightPermissionList(flightPermission);
        ExcelUtil<FlightPermission> util = new ExcelUtil<>(FlightPermission.class);
        util.exportExcel(response, list, "飞行权限数据");
    }

    @PreAuthorize("@ss.hasPermi('drone:permission:query')")
    @GetMapping("/{id}")
    public AjaxResult getInfo(@PathVariable Long id) {
        FlightPermission perm = flightPermissionService.selectFlightPermissionById(id);
        if (perm == null) return error("权限记录不存在");
        if (!SecurityUtils.isAdmin(getUserId()) && !getUserId().equals(perm.getApplicantId())) {
            return error("无权限查看该飞行权限");
        }
        return success(perm);
    }
}
