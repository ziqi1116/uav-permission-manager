<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="申请单号" prop="applicationNo">
        <el-input v-model="queryParams.applicationNo" placeholder="请输入" clearable style="width: 180px" @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-download" size="mini" @click="handleExport" v-hasPermi="['drone:approve:export']">导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="list">
      <el-table-column label="序号" type="index" width="50" align="center" />
      <el-table-column label="申请单号" align="center" prop="applicationNo" width="160" :show-overflow-tooltip="true" />
      <el-table-column label="申请人" align="center" prop="applicantName" width="90" />
      <el-table-column label="无人机" align="center" prop="droneName" width="100" />
      <el-table-column label="飞行区域" align="center" prop="flightArea" :show-overflow-tooltip="true" />
      <el-table-column label="申请高度(m)" align="center" prop="flightHeight" width="100" />
      <el-table-column label="开始时间" align="center" prop="startTime" width="160">
        <template slot-scope="scope"><span>{{ parseTime(scope.row.startTime) }}</span></template>
      </el-table-column>
      <el-table-column label="结束时间" align="center" prop="endTime" width="160">
        <template slot-scope="scope"><span>{{ parseTime(scope.row.endTime) }}</span></template>
      </el-table-column>
      <el-table-column label="申请时间" align="center" prop="createTime" width="160">
        <template slot-scope="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200" fixed="right">
        <template slot-scope="scope">
          <el-button size="mini" type="success" plain @click="handleApprove(scope.row)" v-hasPermi="['drone:approve:approve']">通过</el-button>
          <el-button size="mini" type="danger" plain @click="handleReject(scope.row)" v-hasPermi="['drone:approve:reject']">驳回</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="驳回原因" :visible.sync="rejectOpen" width="400px" append-to-body>
      <el-form ref="rejectForm" :model="rejectForm" :rules="rejectRules" label-width="80px">
        <el-form-item label="驳回原因" prop="approveRemark">
          <el-input v-model="rejectForm.approveRemark" type="textarea" rows="4" placeholder="必填" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitReject">确 定</el-button>
        <el-button @click="rejectOpen = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listApprove, approveApplication, rejectApplication } from '@/api/drone/approve'

export default {
  name: 'FlightApprove',
  data() {
    return {
      loading: true,
      showSearch: true,
      total: 0,
      list: [],
      rejectOpen: false,
      currentRow: null,
      rejectForm: { approveRemark: '' },
      rejectRules: {
        approveRemark: [{ required: true, message: '驳回原因不能为空', trigger: 'blur' }]
      },
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        applicationNo: undefined
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listApprove(this.queryParams).then(response => {
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
      this.resetForm('queryForm')
      this.handleQuery()
    },
    handleApprove(row) {
      this.$modal.confirm('确认通过该申请？').then(() => {
        return approveApplication(row.id, { approveRemark: '审批通过' })
      }).then(() => {
        this.$modal.msgSuccess('审批通过')
        this.getList()
      }).catch(() => {})
    },
    handleReject(row) {
      this.currentRow = row
      this.rejectForm.approveRemark = ''
      this.rejectOpen = true
    },
    submitReject() {
      this.$refs['rejectForm'].validate(valid => {
        if (valid && this.currentRow) {
          rejectApplication(this.currentRow.id, { approveRemark: this.rejectForm.approveRemark }).then(() => {
            this.$modal.msgSuccess('已驳回')
            this.rejectOpen = false
            this.getList()
          })
        }
      })
    },
    handleExport() {
      this.download('drone/approve/export', { ...this.queryParams }, `approve_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>
