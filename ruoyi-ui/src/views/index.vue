<template>
  <div class="home-page">
    <FlightStatisticsDashboard />
  </div>
</template>

<script>
import FlightStatisticsDashboard from '@/views/drone/statistics/index.vue'

export default {
  name: 'Index',
  components: {
    FlightStatisticsDashboard
  }
}
</script>

<style scoped lang="scss">
.home-page {
  height: 100%;
  min-height: calc(100vh - 84px);
  overflow: auto;
}
</style>
