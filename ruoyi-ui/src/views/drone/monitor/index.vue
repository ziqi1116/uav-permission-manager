<template>
  <div class="monitor-map-page">
    <div class="panel-left">
      <div class="panel-header">
        <span class="panel-title">飞行任务</span>
        <el-button type="primary" size="mini" icon="el-icon-refresh" @click="loadTaskList">刷新</el-button>
      </div>
      <div class="task-list" v-loading="taskLoading">
        <div
          v-for="t in taskList"
          :key="t.permissionId"
          :class="['task-item', { active: selectedPermissionId === t.permissionId }]"
          @click="handleClickTask(t)"
        >
          <div class="task-name">{{ t.droneName || '-' }} / {{ t.applicationNo || '-' }}</div>
          <div class="task-area">{{ t.flightArea || '-' }}</div>
          <el-tag :type="taskStatusType(t)" size="mini" class="task-tag">{{ taskStatusLabel(t) }}</el-tag>
        </div>
        <div v-if="!taskLoading && taskList.length === 0" class="empty-tip">暂无飞行任务</div>
      </div>
      <div class="replay-bar" v-if="selectedPermissionId && trackPoints.length > 0">
        <div class="replay-controls">
          <el-button :type="replayPlaying ? 'warning' : 'primary'" size="mini" @click="toggleReplay">
            {{ replayPlaying ? '暂停' : '播放' }}
          </el-button>
          <span class="replay-progress">{{ replayIndex + 1 }} / {{ trackPoints.length }}</span>
        </div>
        <el-slider v-model="replayIndex" :min="0" :max="Math.max(0, trackPoints.length - 1)" :show-tooltip="false" @change="onReplaySliderChange" />
      </div>
    </div>
    <div class="panel-right">
      <div id="amap-container" class="amap-container"></div>
      <div v-if="mapLoadStatus === 'loading'" class="map-mask">地图加载中...</div>
      <div v-else-if="mapLoadStatus === 'no_key'" class="map-mask">请在 .env 中配置 VUE_APP_AMAP_KEY</div>
      <div v-else-if="mapLoadStatus === 'error'" class="map-mask">地图加载失败</div>
    </div>
  </div>
</template>

<script>
import { getTaskList, getTrack, getViolationPoints } from '@/api/drone/monitor'
import { getAmapKey, loadAMapWithRetry } from '@/utils/loadAMap'

const REFRESH_INTERVAL = 8000
const REPLAY_INTERVAL_MS = 150
const DEFAULT_ZOOM = 15

export default {
  name: 'FlightMonitorMap',
  data() {
    return {
      taskLoading: false,
      taskList: [],
      selectedPermissionId: null,
      mapLoadStatus: 'loading',
      map: null,
      AMap: null,
      polyline: null,
      startMarker: null,
      endMarker: null,
      currentMarker: null,
      violationMarkers: [],
      trackPoints: [],
      violationPoints: [],
      refreshTimer: null,
      replayTimer: null,
      replayIndex: 0,
      replayPlaying: false
    }
  },
  mounted() {
    if (!getAmapKey()) {
      this.mapLoadStatus = 'no_key'
      this.$message.warning('请在 .env 中配置 VUE_APP_AMAP_KEY')
      return
    }
    this.initMap()
  },
  beforeDestroy() {
    this.clearReplayTimer()
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
      this.refreshTimer = null
    }
    this.clearMapOverlays()
    this.map = null
    this.polyline = null
    this.startMarker = null
    this.endMarker = null
    this.currentMarker = null
    this.violationMarkers = []
  },
  methods: {
    initMap() {
      this.mapLoadStatus = 'loading'
      loadAMapWithRetry(this.$message)
        .then((AMap) => {
          try {
            this.AMap = AMap
            this.map = new AMap.Map('amap-container', {
              zoom: 11,
              center: [114.3, 30.5],
              viewMode: '3D'
            })
            this.map.on('complete', () => {
              this.$nextTick(() => this.map && this.map.resize && this.map.resize())
            })
            this.mapLoadStatus = 'ready'
            this.loadTaskList()
            this.refreshTimer = setInterval(() => this.loadTaskList(), REFRESH_INTERVAL)
          } catch (e) {
            this.mapLoadStatus = 'error'
            this.$message.error('地图初始化失败')
          }
        })
        .catch(() => {
          this.mapLoadStatus = 'error'
        })
    },
    loadTaskList() {
      this.taskLoading = true
      getTaskList({ pageNum: 1, pageSize: 50 })
        .then((res) => {
          this.taskList = (res.rows || []).map((r) => ({
            permissionId: r.permissionId,
            droneName: r.droneName,
            applicationNo: r.applicationNo,
            flightArea: r.flightArea,
            permissionStatus: r.permissionStatus,
            approvedStartTime: r.approvedStartTime,
            approvedEndTime: r.approvedEndTime
          }))
          if (this.taskList.length > 0 && !this.selectedPermissionId) {
            this.handleClickTask(this.taskList[0])
          }
        })
        .catch(() => {
          this.taskList = []
        })
        .finally(() => {
          this.taskLoading = false
        })
    },
    taskStatusLabel(t) {
      if (t.permissionStatus === '0') return '正常'
      if (t.permissionStatus === '1' || t.permissionStatus === '2') return '已结束'
      return '正常'
    },
    taskStatusType(t) {
      if (t.permissionStatus === '0') return 'success'
      return 'info'
    },
    handleClickTask(task) {
      this.selectedPermissionId = task.permissionId
      this.clearReplayTimer()
      this.replayPlaying = false
      this.replayIndex = 0
      this.loadTrackAndViolation(task.permissionId)
    },
    loadTrackAndViolation(permissionId) {
      this.trackPoints = []
      this.violationPoints = []
      this.clearMapOverlays()
      if (!this.map || !this.AMap || !permissionId) return
      Promise.all([
        getTrack(permissionId, { pageNum: 1, pageSize: 500 }),
        getViolationPoints(permissionId)
      ]).then(([trackRes, violationRes]) => {
        const list = Array.isArray(trackRes) ? trackRes : (trackRes.data || trackRes || [])
        const trackList = list.filter((p) => p != null && p.longitude != null && p.latitude != null)
        const path = trackList.map((p) => [Number(p.longitude), Number(p.latitude)])
        if (!path || path.length === 0) {
          this.$message.warning('当前任务暂无轨迹数据')
          return
        }
        this.trackPoints = trackList
        const rawViolations = Array.isArray(violationRes) ? violationRes : (violationRes.data || violationRes || [])
        this.violationPoints = rawViolations.filter((v) => v != null && v.longitude != null && v.latitude != null)
        try {
          this.drawTrack(path)
          this.drawStartEndMarkers(path)
          this.drawViolationMarkers()
          this.centerMapOnTask(path)
          this.updateReplayMarker(this.replayIndex)
        } catch (e) {
          this.$message.error('地图绘制失败')
        }
      }).catch(() => {
        this.trackPoints = []
        this.violationPoints = []
        this.$message.warning('加载轨迹或违规点失败')
      })
    },
    clearMapOverlays() {
      try {
        if (this.map && typeof this.map.clearMap === 'function') {
          this.map.clearMap()
        } else {
          if (this.polyline) { this.polyline.setMap(null); this.polyline = null }
          if (this.startMarker) { this.startMarker.setMap(null); this.startMarker = null }
          if (this.endMarker) { this.endMarker.setMap(null); this.endMarker = null }
          if (this.currentMarker) { this.currentMarker.setMap(null); this.currentMarker = null }
          this.violationMarkers.forEach((m) => m && m.setMap && m.setMap(null))
          this.violationMarkers = []
        }
      } catch (e) {
        // ignore
      }
    },
    drawTrack(path) {
      if (!this.AMap || !this.map || !path || path.length < 2) return
      const opts = {
        path: path,
        strokeColor: '#409EFF',
        strokeWeight: 4,
        strokeStyle: 'solid',
        lineJoin: 'round',
        map: this.map
      }
      if (path.length > 2) opts.geodesic = true
      this.polyline = new this.AMap.Polyline(opts)
    },
    drawStartEndMarkers(path) {
      if (!this.AMap || !this.map || !path || path.length === 0) return
      const start = path[0]
      if (start && start.length >= 2) {
        this.startMarker = new this.AMap.Marker({
          position: [Number(start[0]), Number(start[1])],
          map: this.map,
          content: this.createStartMarkerContent(),
          title: '起点'
        })
      }
      if (path.length > 1) {
        const end = path[path.length - 1]
        if (end && end.length >= 2) {
          this.endMarker = new this.AMap.Marker({
            position: [Number(end[0]), Number(end[1])],
            map: this.map,
            content: this.createEndMarkerContent(),
            title: '终点'
          })
        }
      }
    },
    createStartMarkerContent() {
      const div = document.createElement('div')
      div.style.cssText = 'width:24px;height:24px;border-radius:50%;background:#67C23A;border:2px solid #fff;box-shadow:0 1px 4px rgba(0,0,0,.3);'
      return div
    },
    createEndMarkerContent() {
      const div = document.createElement('div')
      div.style.cssText = 'width:24px;height:24px;border-radius:50%;background:#E6A23C;border:2px solid #fff;box-shadow:0 1px 4px rgba(0,0,0,.3);'
      return div
    },
    drawViolationMarkers() {
      if (!this.AMap || !this.map) return
      this.violationPoints.forEach((v) => {
        const lng = Number(v.longitude)
        const lat = Number(v.latitude)
        if (isNaN(lng) || isNaN(lat)) return
        const marker = new this.AMap.Marker({
          position: [lng, lat],
          map: this.map,
          content: this.createRedMarkerContent(),
          title: v.violationType || '违规'
        })
        this.violationMarkers.push(marker)
      })
    },
    createRedMarkerContent() {
      const div = document.createElement('div')
      div.style.cssText = 'width:20px;height:20px;border-radius:50%;background:#F56C6C;border:2px solid #fff;box-shadow:0 1px 4px rgba(0,0,0,.3);'
      return div
    },
    centerMapOnTask(path) {
      if (!this.map || !path || path.length === 0) return
      try {
        const start = path[0]
        if (start && start.length >= 2) {
          const lng = Number(start[0])
          const lat = Number(start[1])
          if (!isNaN(lng) && !isNaN(lat)) {
            this.map.setCenter([lng, lat])
            this.map.setZoom(DEFAULT_ZOOM)
          }
        }
      } catch (e) {
        this.$message.error('地图居中失败')
      }
    },
    updateReplayMarker(index) {
      if (!this.AMap || !this.map || !this.trackPoints.length) return
      if (this.currentMarker) this.currentMarker.setMap(null)
      const p = this.trackPoints[index]
      if (!p) return
      const lng = Number(p.longitude)
      const lat = Number(p.latitude)
      if (isNaN(lng) || isNaN(lat)) return
      this.currentMarker = new this.AMap.Marker({
        position: [lng, lat],
        map: this.map,
        content: this.createCurrentMarkerContent(),
        title: '当前'
      })
    },
    createCurrentMarkerContent() {
      const div = document.createElement('div')
      div.style.cssText = 'width:28px;height:28px;border-radius:50%;background:#409EFF;border:3px solid #fff;box-shadow:0 1px 4px rgba(0,0,0,.3);'
      return div
    },
    toggleReplay() {
      if (this.replayPlaying) {
        this.clearReplayTimer()
        return
      }
      if (this.replayIndex >= this.trackPoints.length - 1) this.replayIndex = 0
      this.replayPlaying = true
      const step = () => {
        if (!this.replayPlaying || !this.trackPoints.length) return
        this.replayIndex++
        if (this.replayIndex >= this.trackPoints.length) {
          this.replayPlaying = false
          this.clearReplayTimer()
          return
        }
        this.updateReplayMarker(this.replayIndex)
        this.replayTimer = setTimeout(step, REPLAY_INTERVAL_MS)
      }
      this.replayTimer = setTimeout(step, REPLAY_INTERVAL_MS)
    },
    clearReplayTimer() {
      this.replayPlaying = false
      if (this.replayTimer) {
        clearTimeout(this.replayTimer)
        this.replayTimer = null
      }
    },
    onReplaySliderChange(val) {
      this.replayIndex = val
      this.updateReplayMarker(val)
    }
  }
}
</script>

<style scoped lang="scss">
.monitor-map-page {
  display: flex;
  height: 100%;
  min-height: calc(100vh - 84px);
  overflow: hidden;
}
.panel-left {
  width: 30%;
  min-width: 260px;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-right: 1px solid #e8e8e8;
}
.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  border-bottom: 1px solid #e8e8e8;
  .panel-title { font-size: 15px; font-weight: 600; color: #303133; }
}
.task-list {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}
.task-item {
  padding: 12px;
  margin-bottom: 8px;
  border-radius: 6px;
  cursor: pointer;
  background: #fafafa;
  border: 1px solid #eee;
  &.active {
    background: #ecf5ff;
    border-color: #409EFF;
  }
}
.task-name { font-weight: 600; color: #303133; margin-bottom: 4px; font-size: 13px; }
.task-area { font-size: 12px; color: #606266; margin-bottom: 6px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.task-tag { margin-top: 4px; }
.empty-tip { padding: 24px; text-align: center; color: #909399; font-size: 14px; }
.replay-bar {
  padding: 12px;
  border-top: 1px solid #e8e8e8;
  .replay-controls { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
  .replay-progress { font-size: 12px; color: #909399; }
}
.panel-right {
  flex: 1;
  position: relative;
  min-width: 0;
}
.amap-container { width: 100%; height: 100%; }
.map-mask {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  display: flex; align-items: center; justify-content: center;
  background: #f0f2f5; color: #909399; font-size: 14px;
}
</style>
