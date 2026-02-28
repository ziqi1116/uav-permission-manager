package com.ruoyi.web.controller.drone;

import java.util.List;
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
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.domain.entity.SysRole;
import com.ruoyi.system.domain.FlightApplication;
import com.ruoyi.system.service.IFlightApplicationService;

/**
 * 飞行申请
 */
@RestController
@RequestMapping("/drone/application")
public class FlightApplicationController extends BaseController {

    @Autowired
    private IFlightApplicationService flightApplicationService;

    private void applyDataScope(FlightApplication flightApplication) {
        if (SecurityUtils.isAdmin(getUserId())) return;
        List<SysRole> roles = SecurityUtils.getLoginUser().getUser().getRoles();
        if (roles == null) return;
        List<String> roleKeys = roles.stream().map(SysRole::getRoleKey).collect(java.util.stream.Collectors.toList());
        if (roleKeys.contains("drone_user") || (roleKeys.contains("flight_user") && !roleKeys.contains("approver"))) {
            flightApplication.setApplicantId(getUserId());
        }
    }

    @PreAuthorize("@ss.hasPermi('drone:application:list')")
    @GetMapping("/list")
    public TableDataInfo list(FlightApplication flightApplication) {
        applyDataScope(flightApplication);
        startPage();
        List<FlightApplication> list = flightApplicationService.selectFlightApplicationList(flightApplication);
        return getDataTable(list);
    }

    @Log(title = "飞行申请", businessType = BusinessType.EXPORT)
    @PreAuthorize("@ss.hasPermi('drone:application:export')")
    @PostMapping("/export")
    public void export(HttpServletResponse response, FlightApplication flightApplication) {
        applyDataScope(flightApplication);
        List<FlightApplication> list = flightApplicationService.selectFlightApplicationList(flightApplication);
        ExcelUtil<FlightApplication> util = new ExcelUtil<>(FlightApplication.class);
        util.exportExcel(response, list, "飞行申请数据");
    }

    @PreAuthorize("@ss.hasPermi('drone:application:query')")
    @GetMapping("/{id}")
    public AjaxResult getInfo(@PathVariable Long id) {
        return success(flightApplicationService.selectFlightApplicationById(id));
    }

    @PreAuthorize("@ss.hasPermi('drone:application:add')")
    @Log(title = "飞行申请", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody FlightApplication flightApplication) {
        flightApplication.setApplicantId(getUserId());
        flightApplication.setCreateBy(getUsername());
        return toAjax(flightApplicationService.insertFlightApplication(flightApplication));
    }

    @PreAuthorize("@ss.hasPermi('drone:application:edit')")
    @Log(title = "飞行申请", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody FlightApplication flightApplication) {
        if (!SecurityUtils.isAdmin(getUserId())) {
            FlightApplication existing = flightApplicationService.selectFlightApplicationById(flightApplication.getId());
            if (existing == null || !getUserId().equals(existing.getApplicantId())) {
                return error("无权限修改该申请");
            }
            if (!"0".equals(existing.getStatus())) {
                return error("仅待审批状态的申请可修改");
            }
        }
        flightApplication.setUpdateBy(getUsername());
        return toAjax(flightApplicationService.updateFlightApplication(flightApplication));
    }

    @PreAuthorize("@ss.hasPermi('drone:application:remove')")
    @Log(title = "飞行申请", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids) {
        if (!SecurityUtils.isAdmin(getUserId())) {
            for (Long id : ids) {
                FlightApplication existing = flightApplicationService.selectFlightApplicationById(id);
                if (existing != null && !getUserId().equals(existing.getApplicantId())) {
                    return error("无权限删除部分申请，请仅选择本人待审批申请");
                }
                if (existing != null && !"0".equals(existing.getStatus())) {
                    return error("仅待审批状态的申请可删除");
                }
            }
        }
        return toAjax(flightApplicationService.deleteFlightApplicationByIds(ids));
    }

    @PreAuthorize("@ss.hasPermi('drone:application:add')")
    @GetMapping("/genApplicationNo")
    public AjaxResult genApplicationNo() {
        return success(flightApplicationService.generateApplicationNo());
    }
}
