<script setup>
import { computed, ref } from "vue";
import "material-icons/iconfont/material-icons.css";
import { getComponentDataTimeframe } from "./utilities/dataTimeframe";
import { timeTerms } from "./utilities/AllTimes";
import { chartTypes } from "./utilities/chartTypes";

import ComponentTag from "./components/ComponentTag.vue";
import TagTooltip from "./components/TagTooltip.vue";


const props = defineProps({
	style: { type: Object, default: () => ({}) },
	mode: {
		type: String,
		default: "default",
		validator: (value) =>
			["default", "large", "map", "half", "halfmap", "preview"].includes(
				value
			),
	},
	config: { type: Object, required: true },
	selectBtn: { type: Boolean, default: false },
	selectBtnDisabled: { type: Boolean, default: false },
	selectBtnList: { type: Array, default: () => ([])  },
	cityTag: { type: Array, default: () => ([]) },
	favoriteBtn: { type: Boolean, default: false },
	isFavorite: { type: Boolean, default: false },
	deleteBtn: { type: Boolean, default: false },
	addBtn: { type: Boolean, default: false },
	infoBtn: { type: Boolean, default: false },
	infoBtnText: { type: String, default: "組件資訊" },
	toggleDisable: { type: Boolean, default: false },
	footer: { type: Boolean, default: true },
	activeCity: { type: String, default: '' },
	toggleOn: { type: Boolean, default: false },
	currentSettings: { type: String, default: "all" },
	generatedPrompt: { type: String, default: "" },
});

const emits = defineEmits([
	"favorite",
	"delete",
	"add",
	"info",
	"toggle",
	"filterByParam",
	"filterByLayer",
	"clearByParamFilter",
	"clearByLayerFilter",
	"fly",
	"changeCity",
	"upload",
]);

const toggleOn = computed({
	get: () => props.toggleOn,
	set: (value) => {
		emits("toggle", value, props.config.map_config);
	},
});

const mousePosition = ref({ x: null, y: null });
const showTagTooltip = ref(false);
const uploadedFiles = ref([]);

// Parses time data into display format
const dataTime = computed(() => {
	if (props.config.time_from === "static") {
		return "固定資料";
	} else if (props.config.time_from === "current") {
		return "即時資料";
	} else if (props.config.time_from === "demo") {
		return "示範靜態資料";
	} else if (props.config.time_from === "maintain") {
		return "維護修復中";
	}
	const { timefrom, timeto } = getComponentDataTimeframe(
		props.config.time_from,
		props.config.time_to,
		true
	);
	if (props.config.time_from === "day_start") {
		return `${timefrom.slice(0, 16)} ~ ${timeto.slice(11, 14)}00`;
	}
	return `${timefrom.slice(0, 10)} ~ ${timeto.slice(0, 10)}`;
});
// Parses update frequency data into display format
const updateFreq = computed(() => {
	if (props.config.update_freq && props.config.update_freq_unit) {
		return `每${props.config.update_freq}${
			timeTerms[props.config.update_freq_unit]
		}更新`;
	} else {
		return "不定期更新";
	}
});

// The style for the tag tooltip
const tooltipPosition = computed(() => {
	if (!mousePosition.value.x || !mousePosition.value.y) {
		return {
			left: "-1000px",
			top: "-1000px",
		};
	}
	return {
		left: `${mousePosition.value.x - 40}px`,
		top: `${mousePosition.value.y - 110}px`,
	};
});


// Updates the location for the tag tooltip
function updateMouseLocation(e) {
	mousePosition.value.x = e.pageX;
	mousePosition.value.y = e.pageY;
}
// Updates whether to show the tag tooltip
function changeShowTagTooltipState(state) {
	showTagTooltip.value = state;
}

function handleUpload(event) {
	const files = Array.from(event.target.files);
	const csvFiles = files.filter(file => file.name.endsWith('.csv'));
	uploadedFiles.value = csvFiles;
	emits('upload', csvFiles);
}
</script>

<template>
  <div
    :class="[
      {
        dashboardcomponent: true,
        mapclosed: mode.includes('map') && !toggleOn,
        mapopen: mode === 'map' && toggleOn,
        halfmapopen: mode === 'halfmap' && toggleOn,
        half: mode === 'half',
        large: mode === 'large',
        preview: mode === 'preview',
      },
    ]"
    :style="style"
  >
    <div v-if="currentSettings === 'prompt'">
      <div v-if="generatedPrompt">
        <label style="font-weight: bold;">建議 SQL Prompt</label>
        <textarea :value="generatedPrompt" readonly style="height: 1000px; max-height: 350px; font-family: monospace; background: #111; color: #fff; margin-top: 4px; overflow-y: auto;"></textarea>
      </div>
    </div>
    <div v-else>
      <!-- Header -->
      <div class="dashboardcomponent-header">
        <!-- Upper Left Corner -->
        <div>
          <h3>
            {{ config.name }}
            <ComponentTag
              v-if="!mode.includes('map')"
              icon=""
              :text="updateFreq"
              mode="small"
            />
            <div
              v-else
              @mouseenter="changeShowTagTooltipState(true)"
              @mousemove="updateMouseLocation"
              @mouseleave="changeShowTagTooltipState(false)"
            >
              <span v-if="config.map_filter && config.map_config">tune</span>
              <span v-if="config.map_config && config.map_config[0]">map</span>
              <span v-if="config.history_config?.range">insights</span>
            </div>
          </h3>
          <p v-if="mode === 'preview'">
            {{ props.config.short_desc }}
          </p>
          <div v-if="!mode.includes('map') || toggleOn">
            <h4 v-if="dataTime === '維護修復中'">
              {{ `${config.source} | ` }}<span>warning</span>
              <h4>{{ `${dataTime}` }}</h4>
              <span>warning</span>
            </h4>
            <h4 v-else>
              {{ `${config.source} | ${dataTime}` }}
            </h4>
            <div
              v-if="mode !== 'preview'"
              class="city-tag-container"
            >
              <ComponentTag
                v-for=" city in props.cityTag"
                :key="city"
                :icon="''"
                :text="city.name"
                :mode="'small'"
                :class="`city-tag-item ${city.value}`"
              />
            </div>
          </div>
        </div>
        <!-- Upper Right Corner -->
        <div
          v-if="['default', 'half', 'preview'].includes(mode)"
          class="dashboardcomponent-header-button"
		  style="margin-bottom: 15px;"
        >
          <button
            v-if="addBtn"
            @click="$emit('add', config.id, config.name)"
          >
            <span>add_circle</span>
          </button>
          <button
            v-if="favoriteBtn"
            :class="{
              isfavorite: isFavorite,
            }"
            @click="$emit('favorite', config.id)"
          >
            <span>favorite</span>
          </button>
          <button
            v-if="deleteBtn"
            class="isDelete"
            @click="$emit('delete', config.id)"
          >
            <span>delete</span>
          </button>
        </div>
        <div
          v-else-if="mode.includes('map')"
          class="dashboardcomponent-header-toggle"
		  style="margin-bottom: 15px;"
        >
          <label class="toggleswitch">
            <input
              v-model="toggleOn"
              type="checkbox"
              :disabled="toggleDisable"
            >
            <span class="toggleswitch-slider" />
          </label>
        </div>
      </div>
      <!-- Chart Type Buttons -->
      <p style="margin-bottom: 15px;">Chart Type: </p>
      <div v-if="(!mode.includes('map') || toggleOn) && mode !== 'preview' && config.chart_config.types.length >= 1" class="dashboardcomponent-control-group">
        <button
          v-for="item in config.chart_config.types"
          :key="`${config.index}-${item}-button`"
          :class="{
            'dashboardcomponent-control-group-button': true,
            'dashboardcomponent-control-group-active': true,
          }"
          @click="changeActiveChart(item)"
        >
          {{ chartTypes[item] }}
        </button>
      </div>
      
      <!-- upload components -->
      <div class="dashboardcomponent-upload-container">
        <div class="dashboardcomponent-upload-square">
          <label>
            <input
              type="file"
              multiple
              accept=".csv"
              @change="handleUpload"
              style="display: none;"
            />
            <span class="material-icons upload-icon">upload_files</span>
            <span class="upload-text">(accept .csv)</span>
          </label>
        </div>

        <!-- 顯示已上傳檔案名稱 -->
        <ul v-if="uploadedFiles.length" class="uploaded-file-list" style="margin-bottom: 15px;">
          <li v-for="file in uploadedFiles" :key="file.name" class="uploaded-file-item">
            <span style="margin-left:4px;">- {{ file.name }}</span>
          </li>
        </ul>
      </div>

      <!-- Footer -->
    </div>
  </div>
  <Teleport to="body">
    <!-- The class "chart-tooltip" could be edited in /assets/styles/chartStyles.css -->
    <TagTooltip
      v-if="showTagTooltip"
      :position="tooltipPosition"
      :has-filter="config.map_filter ? true : false"
      :has-map-layer="
        config.map_config && config.map_config[0] ? true : false
      "
      :has-history="config.history_config?.range ? true : false"
    />
  </Teleport>
</template>

<style scoped lang="scss">
* {
	margin: 0;
	padding: 0;
	font-family: "微軟正黑體", "Microsoft JhengHei", "Droid Sans", "Open Sans",
		"Helvetica";
	overflow: hidden;
}

button {
	border: none;
	background-color: transparent;
}

button:hover {
	cursor: pointer;
}

::-webkit-scrollbar {
	width: 0px;
}

.dashboardcomponent {
	height: 330px;
	max-height: 330px;
	width: calc(100% - var(--font-m) * 2);
	max-width: calc(100% - var(--font-m) * 2);
	display: flex;
	flex-direction: column;
	position: relative;
	padding: var(--font-m);
	border-radius: 5px;
	background-color: var(--color-component-background);
	gap: 20px;

	@media (min-width: 1050px) {
		height: 370px;
		max-height: 370px;
	}

	@media (min-width: 1650px) {
		height: 400px;
		max-height: 400px;
	}

	@media (min-width: 2200px) {
		height: 500px;
		max-height: 500px;
	}

	&-header {
		display: flex;
		justify-content: space-between;
		overflow: visible;

		h3 {
			display: flex;
			font-size: var(--font-m);
			color: var(--color-normal-text);

			.componenttag {
				flex-shrink: 0;
				margin-top: 4px;
			}
		}

		h4 {
			display: flex;
			align-items: center;
			color: var(--color-complement-text);
			font-size: var(--font-s);
			font-weight: 400;
			overflow: visible;

			span {
				margin-left: 4px !important;
				margin: 0 4px;
				color: rgb(237, 90, 90) !important;
				font-size: 1rem;
				font-family: var(--font-icon);
				user-select: none;
			}

			h4 {
				color: rgb(237, 90, 90);
			}
		}

		p {
			color: var(--color-normal-text);
			font-size: var(--font-s);
			font-weight: 400;
		}

		div:first-child {
			div {
				display: flex;
				align-items: center;
			}

			span {
				margin-left: 8px;
				color: var(--color-complement-text);
				font-family: var(--font-icon);
				user-select: none;
			}
		}
		&-button {
			min-width: 48px;
			display: flex;
			justify-content: flex-end;
			align-items: flex-start;

			button span {
				color: var(--color-complement-text);
				font-family: var(--font-icon);
				font-size: calc(
					var(--font-l) *
						var(--font-to-icon)
				);
				transition: color 0.2s;

				&:hover {
					color: white;
				}
			}

			button.isfavorite span {
				color: rgb(255, 65, 44);

				&:hover {
					color: rgb(160, 112, 106);
				}
			}
		}

		&-toggle {
			min-height: var(--font-ms);
			min-width: 2rem;
			margin-top: 4px;
		}

		@media (max-width: 760px) {
			button.isDelete {
				display: none !important;
			}
		}

		@media (min-width: 760px) {
			button.isFlag {
				display: none !important;
			}
		}

		@media (min-width: 759px) {
			button.isUnfavorite {
				display: none !important;
			}
		}
	}

	&-control {
		width: 100%;
		display: flex;
		// justify-content: center;
		align-items: center;
		// position: absolute;
		top: 4.2rem;
		left: 0;
		z-index: 8;
		padding: 8px 0;

		&-group {
			display: flex;
			justify-content: center;
			align-items: center;
			margin: 0 auto;
			transform: translateX(-15%);
			padding: 0 !important;

			&-button {
				margin: 0 2px;
				padding: 4px 4px;
				border-radius: 5px;
				background-color: rgb(77, 77, 77);
				opacity: 0.6;
				color: var(--color-complement-text);
				font-size: var(--font-s);
				text-align: center;
				transition: color 0.2s, opacity 0.2s;
				user-select: none;
	
				&:hover {
					opacity: 1;
					color: white;
				}
			}
	
			&-active {
				background-color: var(--color-complement-text);
				color: white;
			}
		}

		.selectBtn {
			background-color: var(--color-component-background);
			padding: 3px;

			&-disabled {
				cursor: not-allowed;
			}
		}
	}

	&-chart,
	&-loading,
	&-error {
		height: 75%;
		position: relative;
		padding-top: 1%;
		overflow-y: scroll;

		p {
			color: var(--color-border);
		}
	}

	&-loading {
		display: flex;
		align-items: center;
		justify-content: center;

		div {
			width: 2rem;
			height: 2rem;
			border-radius: 50%;
			border: solid 4px var(--color-border);
			border-top: solid 4px var(--color-highlight);
			animation: spin 0.7s ease-in-out infinite;
		}
	}

	&-error {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;

		span {
			color: var(--color-complement-text);
			margin-bottom: 0.5rem;
			font-family: var(--font-icon);
			font-size: 2rem;
		}

		p {
			color: var(--color-complement-text);
		}
	}

	&-footer {
		height: 26px;
		display: flex;
		align-items: center;
		justify-content: space-between;
		overflow: visible;

		div {
			display: flex;
			align-items: center;
		}

		button,
		a {
			display: flex;
			align-items: center;
			transition: opacity 0.2s;

			&:hover {
				opacity: 0.8;
			}

			span {
				margin-left: 4px;
				color: var(--color-highlight);
				font-family: var(--font-icon);
				user-select: none;
			}

			p {
				max-height: 1.2rem;
				color: var(--color-highlight);
				user-select: none;
			}
		}
	}
}

@keyframes spin {
	to {
		transform: rotate(360deg);
	}
}

.large {
	height: 350px;
	max-height: 350px;

	@media (min-width: 820px) {
		height: 380px;
		max-height: 380px;
	}

	@media (min-width: 1200px) {
		height: 420px;
		max-height: 420px;
	}

	@media (min-width: 2200px) {
		height: 520px;
		max-height: 520px;
	}
}

.mapclosed {
	max-height: none;
	height: fit-content;
}

.mapopen {
	max-height: 330px;
	height: 330px;

	&-chart,
	&-loading {
		padding-top: 0%;
		height: 80%;
		position: relative;
		overflow-y: scroll;

		p {
			color: var(--color-border);
		}
	}
}

.half {
	height: 180px;
	max-height: 180px;

	@media (min-width: 1050px) {
		height: 210px;
		max-height: 210px;
	}

	@media (min-width: 1650px) {
		height: 225px;
		max-height: 225px;
	}

	@media (min-width: 2200px) {
		height: 275px;
		max-height: 275px;
	}

	&-chart,
	&-loading {
		height: 60%;
	}
}

.dashboardcomponent-control {
	display: flex;
}

.dashboardcomponent-control-group {
	margin: 0;
}

.halfmapopen {
	height: 200px;
	max-height: 200px;

	&-chart {
		padding-top: 0;
		height: 75%;
	}
}

.preview {
	height: 170px;
	max-height: 170px;

	&-content {
		display: flex;
		justify-content: space-between;

		&-id {
			height: calc(100% - 2px);
			display: flex;
			flex-direction: column;
			justify-content: center;
			padding: 0 4px;
			border-radius: 5px;
			border: 1px dashed var(--color-complement-text);
			white-space: nowrap;
			margin-right: 4px;

			p {
				font-size: var(--font-s);
				color: var(--color-complement-text);
				text-overflow: ellipsis;
			}
		}

		&-charts {
			display: flex;
			column-gap: 4px;
			img {
				width: 40px;
				height: 40px;
				border-radius: 5px;
				background-color: var(
					--color-complement-text
				);
			}
		}
	}
}

.city {
	&-tag {
		&-container {
			margin: 4px 0;
			display: flex;
			gap: 5px;
	
			div:first-child {
				margin-left: 5px;
			}

			&-preview {
				display: flex;
				gap: 4px;
			}
		}
	}
}

.dashboardcomponent-upload-square {
  width: 98%;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-component-background);
  border: 2px dashed var(--color-border);
  border-radius: 8px;
  cursor: pointer;
  margin: 12px 0 0 0;
  transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
  position: relative;
  label {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    gap: 15px;
  }
  .upload-icon {
    font-size: 1rem;
    color: var(--color-highlight);
    user-select: none;
    transition: color 0.2s;
    margin: 0;
  }
  .upload-text {
    font-size: 0.8rem;
    color: var(--color-normal-text);
    user-select: none;
    letter-spacing: 1px;
    font-weight: 500;
    transition: color 0.2s;
    margin: 0;
  }
  &:hover {
    border-color: var(--color-highlight);
    background: rgba(90, 156, 248, 0.08);
    box-shadow: 0 0 8px var(--color-highlight);
    .upload-icon {
      color: white;
    }
    .upload-text {
      color: var(--color-highlight);
    }
  }
}

.uploaded-file-list {
  margin: 8px 0 0 0;
  padding: 0 8px;
  list-style: none;
  font-size: 0.95rem;
  color: var(--color-complement-text);
  text-align: left;
}
.uploaded-file-item {
  display: flex;
  align-items: center;
  margin-bottom: 6px;
  gap: 6px;
}
</style>
