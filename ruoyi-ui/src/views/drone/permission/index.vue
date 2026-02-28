<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="权限状态" prop="permissionStatus">
        <el-select v-model="queryParams.permissionStatus" placeholder="请选择" clearable style="width: 120px">
          <el-option v-for="dict in dict.type.flight_permission_status" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="创建时间" prop="dateRange">
        <el-date-picker v-model="dateRange" style="width: 240px" value-format="yyyy-MM-dd" type="daterange" range-separator="-" start-placeholder="开始" end-placeholder="结束" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-download" size="mini" @click="handleExport" v-hasPermi="['drone:permission:export']">导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="list">
      <el-table-column label="序号" type="index" width="50" align="center" />
      <el-table-column label="申请单号" align="center" prop="applicationNo" width="160" :show-overflow-tooltip="true" />
      <el-table-column label="申请人" align="center" prop="applicantName" width="90" />
      <el-table-column label="批准区域" align="center" prop="approvedArea" :show-overflow-tooltip="true" />
      <el-table-column label="批准高度(m)" align="center" prop="approvedHeight" width="110" />
      <el-table-column label="批准开始时间" align="center" prop="approvedStartTime" width="160">
        <template slot-scope="scope"><span>{{ parseTime(scope.row.approvedStartTime) }}</span></template>
      </el-table-column>
      <el-table-column label="批准结束时间" align="center" prop="approvedEndTime" width="160">
        <template slot-scope="scope"><span>{{ parseTime(scope.row.approvedEndTime) }}</span></template>
      </el-table-column>
      <el-table-column label="权限状态" align="center" prop="permissionStatus" width="90">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.flight_permission_status" :value="scope.row.permissionStatus" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template slot-scope="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script>
import { listPermission } from '@/api/drone/permission'

export default {
  name: 'FlightPermission',
  dicts: ['flight_permission_status'],
  data() {
    return {
      loading: true,
      showSearch: true,
      total: 0,
      list: [],
      dateRange: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        permissionStatus: undefined
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listPermission(this.addDateRange(this.queryParams, this.dateRange)).then(response => {
        this.list = response.rows
        this.total = response.total
        this.loading = false
      })
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.dateRange = []
      this.resetForm('queryForm')
      this.handleQuery()
    },
    handleExport() {
      this.download('drone/permission/export', { ...this.queryParams, ...this.addDateRange(this.queryParams, this.dateRange) }, `permission_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>
