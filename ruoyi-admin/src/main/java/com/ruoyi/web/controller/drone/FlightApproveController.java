package com.ruoyi.web.controller.drone;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.system.domain.FlightApplication;
import com.ruoyi.system.service.IFlightApplicationService;

/**
 * 审批管理（待审批列表 + 通过/驳回）
 */
@RestController
@RequestMapping("/drone/approve")
public class FlightApproveController extends BaseController {

    @Autowired
    private IFlightApplicationService flightApplicationService;

    @PreAuthorize("@ss.hasPermi('drone:approve:list')")
    @GetMapping("/list")
    public TableDataInfo list(FlightApplication flightApplication) {
        flightApplication.setStatus("0");
        startPage();
        List<FlightApplication> list = flightApplicationService.selectFlightApplicationList(flightApplication);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('drone:approve:export')")
    @Log(title = "审批管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, FlightApplication flightApplication) {
        flightApplication.setStatus("0");
        List<FlightApplication> list = flightApplicationService.selectFlightApplicationList(flightApplication);
        ExcelUtil<FlightApplication> util = new ExcelUtil<>(FlightApplication.class);
        util.exportExcel(response, list, "待审批数据");
    }

    @PreAuthorize("@ss.hasPermi('drone:approve:approve')")
    @Log(title = "审批管理", businessType = BusinessType.UPDATE)
    @PostMapping("/approve/{id}")
    public AjaxResult approve(@PathVariable Long id, @RequestBody(required = false) java.util.Map<String, String> body) {
        String remark = body != null && body.containsKey("approveRemark") ? body.get("approveRemark") : "审批通过";
        flightApplicationService.approve(id, getUserId(), remark);
        return success();
    }

    @PreAuthorize("@ss.hasPermi('drone:approve:reject')")
    @Log(title = "审批管理", businessType = BusinessType.UPDATE)
    @PostMapping("/reject/{id}")
    public AjaxResult reject(@PathVariable Long id, @RequestBody java.util.Map<String, String> body) {
        String remark = body != null ? body.get("approveRemark") : null;
        flightApplicationService.reject(id, getUserId(), remark);
        return success();
    }
}
