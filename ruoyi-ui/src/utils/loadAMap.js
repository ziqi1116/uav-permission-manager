/**
 * 高德地图 JS API 安全加载
 * - 动态加载 script，不阻塞页面
 * - 检测 window.AMap，避免重复加载
 * - 超时与重试，加载失败 message.warning
 */

const AMAP_SCRIPT_URL = 'https://webapi.amap.com/maps?v=2.0'
const LOAD_TIMEOUT = 15000
const MAX_RETRY = 2

/** 安全获取环境变量，避免 process.env 未定义 */
function getAmapKey() {
  try {
    if (typeof process !== 'undefined' && process.env && process.env.VUE_APP_AMAP_KEY != null) {
      return String(process.env.VUE_APP_AMAP_KEY).trim()
    }
  } catch (e) {
    // ignore
  }
  return ''
}

/** 是否已存在同源 script，避免重复插入 */
function hasAmapScript() {
  const scripts = document.getElementsByTagName('script')
  for (let i = 0; i < scripts.length; i++) {
    if (scripts[i].src && scripts[i].src.indexOf('webapi.amap.com') !== -1) {
      return true
    }
  }
  return false
}

/**
 * 加载高德地图 API
 * @returns {Promise<typeof window.AMap>}
 */
function loadAMap() {
  if (typeof window === 'undefined') {
    return Promise.reject(new Error('非浏览器环境'))
  }
  if (window.AMap) {
    return Promise.resolve(window.AMap)
  }

  const key = getAmapKey()
  if (!key) {
    return Promise.reject(new Error('NO_KEY'))
  }

  return new Promise((resolve, reject) => {
    const url = `${AMAP_SCRIPT_URL}&key=${key}`
    if (hasAmapScript()) {
      const checkExist = setInterval(() => {
        if (window.AMap) {
          clearInterval(checkExist)
          resolve(window.AMap)
        }
      }, 100)
      setTimeout(() => {
        clearInterval(checkExist)
        if (!window.AMap) reject(new Error('高德地图加载超时'))
      }, LOAD_TIMEOUT)
      return
    }

    const script = document.createElement('script')
    script.type = 'text/javascript'
    script.src = url
    script.async = true

    let timeoutId = null
    const cleanup = () => {
      if (timeoutId) clearTimeout(timeoutId)
      script.onload = null
      script.onerror = null
    }

    script.onload = () => {
      cleanup()
      if (window.AMap) {
        resolve(window.AMap)
      } else {
        reject(new Error('高德地图加载异常'))
      }
    }
    script.onerror = () => {
      cleanup()
      reject(new Error('高德地图脚本加载失败'))
    }

    timeoutId = setTimeout(() => {
      cleanup()
      reject(new Error('高德地图加载超时'))
    }, LOAD_TIMEOUT)

    document.head.appendChild(script)
  })
}

/**
 * 带重试的加载（最多 2 次）
 * @param {import('element-ui').Message} message - Element Message 实例，用于 warning
 * @returns {Promise<typeof window.AMap>}
 */
export function loadAMapWithRetry(message) {
  const msg = message || (typeof window !== 'undefined' && window.$message) || null
  const warn = (text) => {
    if (msg && msg.warning) msg.warning(text)
  }

  function tryLoad(attempt) {
    return loadAMap().catch((e) => {
      if (e && e.message === 'NO_KEY') {
        warn('请在 .env 中配置 VUE_APP_AMAP_KEY（高德地图 Key）')
        return Promise.reject(e)
      }
      if (attempt < MAX_RETRY) {
        warn(`高德地图加载失败，正在重试 (${attempt}/${MAX_RETRY})...`)
        return tryLoad(attempt + 1)
      }
      warn('高德地图加载失败，请检查 VUE_APP_AMAP_KEY 或网络')
      return Promise.reject(e)
    })
  }
  return tryLoad(1)
}

export { getAmapKey, loadAMap }
