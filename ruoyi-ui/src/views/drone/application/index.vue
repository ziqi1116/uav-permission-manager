<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="申请单号" prop="applicationNo">
        <el-input v-model="queryParams.applicationNo" placeholder="请输入" clearable style="width: 180px" @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择" clearable style="width: 120px">
          <el-option v-for="dict in dict.type.flight_application_status" :key="dict.value" :label="dict.label" :value="dict.value" />
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
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd" v-hasPermi="['drone:application:add']">新增申请</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="el-icon-edit" size="mini" :disabled="single" @click="handleUpdate" v-hasPermi="['drone:application:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete" v-hasPermi="['drone:application:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-download" size="mini" @click="handleExport" v-hasPermi="['drone:application:export']">导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="list" row-key="id" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
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
      <el-table-column label="状态" align="center" prop="status" width="90">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.flight_application_status" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="140">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)" v-hasPermi="['drone:application:edit']">修改</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)" v-hasPermi="['drone:application:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" :visible.sync="open" width="620px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="申请单号" prop="applicationNo">
          <el-input v-model="form.applicationNo" placeholder="留空自动生成" readonly />
        </el-form-item>
        <el-form-item label="无人机" prop="droneId">
          <el-select v-model="form.droneId" placeholder="请选择无人机" filterable style="width:100%">
            <el-option v-for="d in droneList" :key="d.id" :label="d.droneName + ' (' + d.serialNumber + ')'" :value="d.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="飞行区域" prop="flightArea">
          <el-input v-model="form.flightArea" type="textarea" placeholder="请输入飞行区域" />
        </el-form-item>
        <el-form-item label="申请高度(m)" prop="flightHeight">
          <el-input-number v-model="form.flightHeight" :min="0" :max="1000" style="width:100%" />
        </el-form-item>
        <el-form-item label="计划开始时间" prop="startTime">
          <el-date-picker v-model="form.startTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="选择开始时间" style="width:100%" />
        </el-form-item>
        <el-form-item label="计划结束时间" prop="endTime">
          <el-date-picker v-model="form.endTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="选择结束时间" style="width:100%" />
        </el-form-item>
        <el-form-item label="飞行目的" prop="purpose">
          <el-input v-model="form.purpose" type="textarea" placeholder="请输入飞行目的" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listApplication, getApplication, addApplication, updateApplication, delApplication, genApplicationNo } from '@/api/drone/application'
import { listDroneInfo } from '@/api/drone/droneInfo'

export default {
  name: 'FlightApplication',
  dicts: ['flight_application_status'],
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      list: [],
      droneList: [],
      dateRange: [],
      title: '',
      open: false,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        applicationNo: undefined,
        status: undefined
      },
      form: {},
      rules: {
        droneId: [{ required: true, message: '请选择无人机', trigger: 'change' }],
        flightArea: [{ required: true, message: '飞行区域不能为空', trigger: 'blur' }],
        startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
        endTime: [{ required: true, message: '请选择结束时间', trigger: 'change' }]
      }
    }
  },
  created() {
    this.getList()
    this.loadDrones()
  },
  methods: {
    loadDrones() {
      listDroneInfo({ pageNum: 1, pageSize: 500 }).then(r => {
        this.droneList = r.rows || []
      })
    },
    getList() {
      this.loading = true
      listApplication(this.addDateRange(this.queryParams, this.dateRange)).then(response => {
        this.list = response.rows
        this.total = response.total
        this.loading = false
      })
    },
    cancel() {
      this.open = false
      this.reset()
    },
    reset() {
      this.form = {
        id: undefined,
        applicationNo: undefined,
        droneId: undefined,
        flightArea: undefined,
        flightHeight: 0,
        startTime: undefined,
        endTime: undefined,
        purpose: undefined
      }
      this.resetForm('form')
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
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      genApplicationNo().then(r => {
        this.form.applicationNo = r.data
        this.open = true
        this.title = '新增飞行申请'
      })
    },
    handleUpdate(row) {
      let id
      if (row && row.id != null) {
        id = row.id
      } else if (this.ids.length === 1) {
        id = this.ids[0]
      }
      if (id == null || id === '') {
        this.$message.warning(this.ids.length !== 1 ? '请选择一条记录' : '记录ID无效')
        return
      }
      this.reset()
      getApplication(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = '修改飞行申请'
      })
    },
    submitForm() {
      this.$refs['form'].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateApplication(this.form).then(() => {
              this.$modal.msgSuccess('修改成功')
              this.open = false
              this.getList()
            })
          } else {
            addApplication(this.form).then(() => {
              this.$modal.msgSuccess('提交成功')
              this.open = false
              this.getList()
            })
          }
        }
      })
    },
    handleDelete(row) {
      const ids = row.id || this.ids
      const idStr = Array.isArray(ids) ? ids.join(',') : ids
      this.$modal.confirm('是否确认删除？').then(() => delApplication(idStr)).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    },
    handleExport() {
      this.download('drone/application/export', { ...this.queryParams, ...this.addDateRange(this.queryParams, this.dateRange) }, `application_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>
