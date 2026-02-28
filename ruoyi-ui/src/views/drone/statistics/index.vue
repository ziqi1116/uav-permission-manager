<template>
  <div class="statistics-dashboard">
    <!-- 顶部：4 个统计卡片 -->
    <div class="dashboard-cards">
      <div class="card-item">
        <div class="card-value">{{ stats.todayApplicationCount }}</div>
        <div class="card-label">今日申请数量</div>
      </div>
      <div class="card-item">
        <div class="card-value">{{ stats.todayApprovedCount }}</div>
        <div class="card-label">审批通过数量</div>
      </div>
      <div class="card-item">
        <div class="card-value">{{ stats.currentFlightCount }}</div>
        <div class="card-label">当前飞行任务数量</div>
      </div>
      <div class="card-item">
        <div class="card-value">{{ stats.totalViolationCount }}</div>
        <div class="card-label">累计违规次数</div>
      </div>
    </div>

    <!-- 中部：左右两栏 -->
    <div class="dashboard-middle">
      <div class="chart-left">
        <div class="chart-title">飞行申请趋势（按日）</div>
        <div ref="chartApplication" class="chart-instance"></div>
      </div>
      <div class="chart-right">
        <div class="chart-title">空域使用占比</div>
        <div ref="chartArea" class="chart-instance"></div>
      </div>
    </div>

    <!-- 底部：违规趋势折线图 -->
    <div class="dashboard-bottom">
      <div class="chart-title">违规趋势（按日）</div>
      <div ref="chartViolation" class="chart-instance"></div>
    </div>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import 'echarts/theme/macarons'
import { getDashboard } from '@/api/drone/statistics'

const statusLabel = { '0': '待审批', '1': '已通过', '2': '已驳回' }

export default {
  name: 'FlightStatisticsDashboard',
  data() {
    return {
      stats: {
        todayApplicationCount: 0,
        todayApprovedCount: 0,
        currentFlightCount: 0,
        totalViolationCount: 0
      },
      chartApplication: null,
      chartArea: null,
      chartViolation: null,
      resizeHandler: null
    }
  },
  mounted() {
    this.initCharts()
    this.resizeHandler = () => {
      this.chartApplication && this.chartApplication.resize()
      this.chartArea && this.chartArea.resize()
      this.chartViolation && this.chartViolation.resize()
    }
    window.addEventListener('resize', this.resizeHandler)
    this.loadData()
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.resizeHandler)
    if (this.chartApplication) this.chartApplication.dispose()
    if (this.chartArea) this.chartArea.dispose()
    if (this.chartViolation) this.chartViolation.dispose()
  },
  methods: {
    initCharts() {
      this.chartApplication = echarts.init(this.$refs.chartApplication, 'macarons')
      this.chartArea = echarts.init(this.$refs.chartArea, 'macarons')
      this.chartViolation = echarts.init(this.$refs.chartViolation, 'macarons')
    },
    loadData() {
      const today = new Date()
      const end = today.toISOString().slice(0, 10)
      const begin = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10)
      getDashboard(begin, end).then(res => {
        const data = res.data || {}
        const ds = data.dashboardStats || {}
        this.stats = {
          todayApplicationCount: ds.todayApplicationCount != null ? ds.todayApplicationCount : 0,
          todayApprovedCount: ds.todayApprovedCount != null ? ds.todayApprovedCount : 0,
          currentFlightCount: ds.currentFlightCount != null ? ds.currentFlightCount : 0,
          totalViolationCount: ds.totalViolationCount != null ? ds.totalViolationCount : 0
        }
        this.renderApplication(data.applicationCount || [])
        this.renderArea(data.areaUsage || [])
        this.renderViolation(data.violationCount || [])
      }).catch(() => {
        this.renderApplication([])
        this.renderArea([])
        this.renderViolation([])
      })
    },
    renderApplication(list) {
      const xData = list.map(i => i.dateStr)
      const yData = list.map(i => i.count)
      this.chartApplication.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: xData, axisLabel: { rotate: 30 } },
        yAxis: { type: 'value', name: '数量' },
        series: [{ name: '申请数', type: 'bar', data: yData, itemStyle: { color: '#409EFF' } }]
      })
    },
    renderArea(list) {
      const data = list.map(i => ({
        name: statusLabel[i.name] || i.name,
        value: i.value
      }))
      this.chartArea.setOption({
        tooltip: { trigger: 'item' },
        legend: { orient: 'vertical', left: 'left' },
        series: [{ type: 'pie', radius: '60%', data: data }]
      })
    },
    renderViolation(list) {
      const xData = list.map(i => i.dateStr)
      const yData = list.map(i => i.count)
      this.chartViolation.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: xData, axisLabel: { rotate: 30 } },
        yAxis: { type: 'value', name: '违规次数' },
        series: [{ name: '违规次数', type: 'line', data: yData, smooth: true, itemStyle: { color: '#F56C6C' } }]
      })
    }
  }
}
</script>

<style scoped lang="scss">
.statistics-dashboard {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: calc(100vh - 84px);
  padding: 16px;
  box-sizing: border-box;
  background: #f0f2f5;
  overflow: auto;
}
.dashboard-cards {
  display: flex;
  flex: 0 0 auto;
  gap: 16px;
  margin-bottom: 16px;
  .card-item {
    flex: 1;
    min-width: 0;
    padding: 20px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 1px 4px rgba(0,0,0,.08);
    text-align: center;
  }
  .card-value {
    font-size: 28px;
    font-weight: 600;
    color: #303133;
  }
  .card-label {
    font-size: 14px;
    color: #909399;
    margin-top: 8px;
  }
}
.dashboard-middle {
  display: flex;
  flex: 1;
  min-height: 320px;
  gap: 16px;
  margin-bottom: 16px;
  .chart-left, .chart-right {
    flex: 1;
    min-width: 0;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 1px 4px rgba(0,0,0,.08);
    padding: 16px;
    display: flex;
    flex-direction: column;
  }
  .chart-left { flex: 1; }
  .chart-right { flex: 1; }
  .chart-title {
    font-size: 14px;
    color: #606266;
    margin-bottom: 8px;
  }
  .chart-instance {
    flex: 1;
    min-height: 280px;
  }
}
.dashboard-bottom {
  flex: 0 0 auto;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,.08);
  padding: 16px;
  min-height: 320px;
  .chart-title {
    font-size: 14px;
    color: #606266;
    margin-bottom: 8px;
  }
  .chart-instance {
    height: 280px;
  }
}
</style>
