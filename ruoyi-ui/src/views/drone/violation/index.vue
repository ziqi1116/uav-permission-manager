<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="违规类型" prop="violationType">
        <el-select v-model="queryParams.violationType" placeholder="请选择" clearable style="width: 140px">
          <el-option v-for="dict in dict.type.violation_type" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="处理状态" prop="handleStatus">
        <el-select v-model="queryParams.handleStatus" placeholder="请选择" clearable style="width: 120px">
          <el-option v-for="dict in dict.type.violation_handle_status" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd" v-hasPermi="['drone:violation:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-download" size="mini" @click="handleExport" v-hasPermi="['drone:violation:export']">导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="list">
      <el-table-column label="序号" type="index" width="50" align="center" />
      <el-table-column label="申请单号" align="center" prop="applicationNo" width="160" :show-overflow-tooltip="true" />
      <el-table-column label="权限ID" align="center" prop="permissionId" width="80" />
      <el-table-column label="违规类型" align="center" prop="violationType" width="100">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.violation_type" :value="scope.row.violationType" />
        </template>
      </el-table-column>
      <el-table-column label="违规描述" align="center" prop="description" :show-overflow-tooltip="true" />
      <el-table-column label="处理状态" align="center" prop="handleStatus" width="90">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.violation_handle_status" :value="scope.row.handleStatus" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template slot-scope="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="100">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)" v-hasPermi="['drone:violation:edit']">处理</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" :visible.sync="open" width="560px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="权限ID" prop="permissionId">
          <el-input v-model.number="form.permissionId" placeholder="请输入权限ID" />
        </el-form-item>
        <el-form-item label="违规类型" prop="violationType">
          <el-select v-model="form.violationType" placeholder="请选择" style="width:100%">
            <el-option v-for="dict in dict.type.violation_type" :key="dict.value" :label="dict.label" :value="dict.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="违规描述" prop="description">
          <el-input v-model="form.description" type="textarea" rows="3" placeholder="请输入" />
        </el-form-item>
        <el-form-item label="处理状态" prop="handleStatus">
          <el-radio-group v-model="form.handleStatus">
            <el-radio v-for="dict in dict.type.violation_handle_status" :key="dict.value" :label="dict.value">{{ dict.label }}</el-radio>
          </el-radio-group>
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
import { listViolation, getViolation, addViolation, updateViolation } from '@/api/drone/violation'

export default {
  name: 'ViolationRecord',
  dicts: ['violation_type', 'violation_handle_status'],
  data() {
    return {
      loading: true,
      showSearch: true,
      total: 0,
      list: [],
      title: '',
      open: false,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        violationType: undefined,
        handleStatus: undefined
      },
      form: {},
      rules: {
        permissionId: [{ required: true, message: '权限ID不能为空', trigger: 'blur' }],
        violationType: [{ required: true, message: '请选择违规类型', trigger: 'change' }]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listViolation(this.queryParams).then(response => {
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
      this.form = { id: undefined, permissionId: undefined, violationType: undefined, description: '', handleStatus: '0' }
      this.resetForm('form')
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '新增违规记录'
    },
    handleUpdate(row) {
      this.reset()
      getViolation(row.id).then(r => {
        this.form = r.data
        this.open = true
        this.title = '处理违规'
      })
    },
    submitForm() {
      this.$refs['form'].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateViolation(this.form).then(() => {
              this.$modal.msgSuccess('处理成功')
              this.open = false
              this.getList()
            })
          } else {
            addViolation(this.form).then(() => {
              this.$modal.msgSuccess('新增成功')
              this.open = false
              this.getList()
            })
          }
        }
      })
    },
    handleExport() {
      this.download('drone/violation/export', { ...this.queryParams }, `violation_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>
