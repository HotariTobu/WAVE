class_name EditorPhysicsLayer

const BRIDGE_VERTEX = 1
const BRIDGE_SEGMENTS = BRIDGE_VERTEX << 1
const BRIDGE = BRIDGE_VERTEX | BRIDGE_SEGMENTS
const LANE_VERTEX = BRIDGE_SEGMENTS << 1
const LANE_SEGMENTS = LANE_VERTEX << 1
const LANE = LANE_VERTEX | LANE_SEGMENTS
const STOPLIGHT_SECTOR = LANE_SEGMENTS << 1
const STOPLIGHT_CORE = STOPLIGHT_SECTOR << 1
const STOPLIGHT = STOPLIGHT_SECTOR | STOPLIGHT_CORE
const SELECTABLE = BRIDGE | LANE | STOPLIGHT
